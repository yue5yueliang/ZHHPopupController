//
//  ZHHPopupContainerView.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 弹窗承载容器：统一管理遮罩与内容视图的层级、以及多弹窗的叠放顺序
final class ZHHPopupContainerView: UIView {
    /// 用于快速查找容器的标记
    static let containerTag = 0x5A48_4850

    /// 当前正在展示的弹窗列表
    private var popups: [ZHHPopupController] = []

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 只有点击在容器自身“空白区域”时，才考虑是否需要透传触摸
        let view = super.hitTest(point, with: event)
        guard view === self else { return view }
        // 取最高层级弹窗，决定是否允许背景交互
        let top = popups.max(by: { $0.windowLevel.rawValue < $1.windowLevel.rawValue })
        if top?.maskType == ZHHPopupMaskType.none {
            // maskType = none 时，容器不拦截触摸，让事件落到下层视图
            return nil
        }
        return view
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 容器始终铺满宿主视图
        frame = superview?.bounds ?? bounds
    }

    func present(_ popup: ZHHPopupController, duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, bounced: Bool, completion: (() -> Void)?) {
        guard !popup.isPresentingInternal else { return }
        // 建立弹窗与容器的关联关系
        popup.attachHostingContainer(self)
        // 按 windowLevel 排序，保证层级插入正确
        let sorted = popups.sorted { $0.windowLevel.rawValue < $1.windowLevel.rawValue }
        if sorted.isEmpty {
            popup.installInHost(below: nil)
        } else if let last = sorted.last, popup.windowLevel.rawValue >= last.windowLevel.rawValue {
            popup.installInHost(below: nil)
        } else if let anchor = sorted.first(where: { popup.windowLevel.rawValue < $0.windowLevel.rawValue }) {
            popup.installInHost(below: anchor.maskView)
        } else {
            popup.installInHost(below: nil)
        }
        if !popups.contains(where: { $0 === popup }) {
            popups.append(popup)
        }
        // 执行展示动画
        popup.performPresent(duration: duration, delay: delay, options: options, bounced: bounced, completion: completion)
    }

    func dismiss(_ popup: ZHHPopupController, duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, completion: (() -> Void)?) {
        guard popups.contains(where: { $0 === popup }) else { return }
        // 执行消失动画，结束后移除并在无弹窗时销毁容器
        popup.performDismiss(duration: duration, delay: delay, options: options, onComplete: { [weak self] in
            self?.popups.removeAll { $0 === popup }
            if self?.popups.isEmpty == true {
                self?.removeFromSuperview()
            }
            completion?()
        })
    }
}
