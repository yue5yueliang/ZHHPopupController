//
//  UIView+ZHHPopupController.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 在任意 `UIView` 上展示/关闭 `ZHHPopupController` 的便捷入口
extension UIView {
    /// 已存在的弹窗容器（若尚未创建则为 nil）
    private var popupContainerIfLoaded: ZHHPopupContainerView? {
        subviews.first(where: { $0.tag == ZHHPopupContainerView.containerTag }) as? ZHHPopupContainerView
    }

    /// 确保当前 view 上存在弹窗容器；若已存在则复用并置顶
    private func ensurePopupContainer() -> ZHHPopupContainerView {
        if let existing = popupContainerIfLoaded {
            bringSubview(toFront: existing)
            return existing
        }
        let container = ZHHPopupContainerView(frame: bounds)
        container.tag = ZHHPopupContainerView.containerTag
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(container)
        return container
    }

    /// 展示弹窗（默认动画时长 0.25）
    public func presentPopupController(_ popupController: ZHHPopupController, completion: (() -> Void)? = nil) {
        presentPopupController(popupController, duration: 0.25, completion: completion)
    }

    /// 展示弹窗（指定动画时长）
    public func presentPopupController(_ popupController: ZHHPopupController, duration: TimeInterval, completion: (() -> Void)? = nil) {
        presentPopupController(popupController, duration: duration, bounced: false, completion: completion)
    }

    /// 展示弹窗（可选弹性动画）
    public func presentPopupController(_ popupController: ZHHPopupController, duration: TimeInterval, bounced: Bool, completion: (() -> Void)? = nil) {
        presentPopupController(popupController, duration: duration, delay: 0, options: .curveLinear, bounced: bounced, completion: completion)
    }

    /// 展示弹窗（完整参数）
    public func presentPopupController(_ popupController: ZHHPopupController, duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, bounced: Bool, completion: (() -> Void)? = nil) {
        let container = ensurePopupContainer()
        container.present(popupController, duration: duration, delay: delay, options: options, bounced: bounced, completion: completion)
    }

    /// 关闭弹窗（默认动画时长 0.25）
    public func dismissPopupController(_ popupController: ZHHPopupController, completion: (() -> Void)? = nil) {
        dismissPopupController(popupController, duration: 0.25, completion: completion)
    }

    /// 关闭弹窗（指定动画时长）
    public func dismissPopupController(_ popupController: ZHHPopupController, duration: TimeInterval, completion: (() -> Void)? = nil) {
        dismissPopupController(popupController, duration: duration, delay: 0, options: .curveEaseOut, completion: completion)
    }

    /// 关闭弹窗（完整参数）
    public func dismissPopupController(_ popupController: ZHHPopupController, duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, completion: (() -> Void)? = nil) {
        guard let container = popupContainerIfLoaded else { return }
        container.dismiss(popupController, duration: duration, delay: delay, options: options, completion: completion)
    }
}
