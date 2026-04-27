//
//  ZHHPopupController+Convenience.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

extension ZHHPopupController {
    /// 获取当前前台 Scene 的可用 window（优先 keyWindow，其次可见 window）
    public var keyWindow: UIWindow? {
        // iOS 15+：优先从前台激活的 WindowScene 中查找
        for scene in UIApplication.shared.connectedScenes {
            guard scene.activationState == .foregroundActive, let windowScene = scene as? UIWindowScene else { continue }
            if let key = windowScene.windows.first(where: { $0.isKeyWindow }) {
                return key
            }
            if let visible = windowScene.windows.first(where: { !$0.isHidden && $0.alpha > 0 }) {
                return visible
            }
            if let first = windowScene.windows.first {
                return first
            }
        }
        return nil
    }

    /// 直接展示到当前 keyWindow（默认动画参数）
    public func show() {
        keyWindow?.presentPopupController(self, completion: nil)
    }

    /// 展示到指定宿主 view（默认动画参数）
    public func show(in view: UIView, completion: (() -> Void)? = nil) {
        view.presentPopupController(self, completion: completion)
    }

    /// 展示到指定宿主 view（指定动画时长）
    public func show(in view: UIView, duration: TimeInterval, completion: (() -> Void)? = nil) {
        view.presentPopupController(self, duration: duration, completion: completion)
    }

    /// 展示到指定宿主 view（可选弹性动画）
    public func show(in view: UIView, duration: TimeInterval, bounced: Bool, completion: (() -> Void)? = nil) {
        view.presentPopupController(self, duration: duration, bounced: bounced, completion: completion)
    }

    /// 展示到指定宿主 view（完整参数）
    public func show(in view: UIView, duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, bounced: Bool, completion: (() -> Void)? = nil) {
        view.presentPopupController(self, duration: duration, delay: delay, options: options, bounced: bounced, completion: completion)
    }

    /// 关闭弹窗（默认动画参数）
    public func dismiss() {
        hostingContainer?.dismiss(self, duration: 0.25, delay: 0, options: .curveEaseOut, completion: nil)
    }

    /// 关闭弹窗（指定动画时长）
    public func dismiss(duration: TimeInterval, completion: (() -> Void)? = nil) {
        hostingContainer?.dismiss(self, duration: duration, delay: 0, options: .curveEaseOut, completion: completion)
    }

    /// 关闭弹窗（完整参数）
    public func dismiss(duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, completion: (() -> Void)? = nil) {
        hostingContainer?.dismiss(self, duration: duration, delay: delay, options: options, completion: completion)
    }
}
