//
//  ZHHPopupController+Keyboard.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 键盘监听与联动：在弹窗展示期间，根据键盘的隐藏/高度变化调整内容视图位置
extension ZHHPopupController {
    /// 绑定键盘通知（只绑定一次）
    internal func bindKeyboardNotifications() {
        guard keyboardObservers.isEmpty else { return }
        let center = NotificationCenter.default
        let hide = center.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: .main) { [weak self] n in
            self?.keyboardWillHide(n)
        }
        let change = center.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: .main) { [weak self] n in
            self?.keyboardWillChangeFrame(n)
        }
        keyboardObservers = [hide, change]
    }

    /// 解绑键盘通知
    internal func unbindKeyboardNotifications() {
        let center = NotificationCenter.default
        keyboardObservers.forEach { center.removeObserver($0) }
        keyboardObservers = []
    }

    /// 键盘即将隐藏：内容视图回到静止位置
    private func keyboardWillHide(_ notification: Notification) {
        isKeyboardVisible = false
        guard isPresentingInternal, let info = notification.userInfo else { return }
        // 跟随系统键盘动画参数，保持视觉一致
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.contentView.center = self.restingCenter()
        })
    }

    /// 键盘 frame 变化：计算遮罩坐标系下的键盘位置，确保内容视图不被遮挡
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let info = notification.userInfo,
              let begin = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
              let end = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let mask = maskView else { return }
        // 过滤无效变化（首次/重复回调、或高度为 0 的情况）
        guard begin.size.height > 0, abs(begin.minY - end.minY) > 0.01 else { return }
        // 转换到遮罩视图坐标系，便于计算覆盖关系
        let converted = mask.convert(end, from: nil)
        let keyboardHeight = mask.bounds.height - converted.minY
        guard keyboardHeight > 0 else { return }
        isKeyboardVisible = true
        // originY：内容视图底边超过键盘顶边的重叠量
        let originY = contentView.frame.maxY - converted.minY
        // keyboardOffsetSpacing：额外留白（避免贴得太近）
        let newCenter = CGPoint(x: contentView.center.x, y: contentView.center.y - originY - viewModel.keyboardOffsetSpacing)
        let duration = (info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curve = (info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        let options = UIView.AnimationOptions(rawValue: curve << 16)
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            self.contentView.center = newCenter
        })
    }
}
