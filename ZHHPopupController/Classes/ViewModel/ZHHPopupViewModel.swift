//
//  ZHHPopupViewModel.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 内部配置模型：集中保存弹窗的遮罩、布局、动画、交互等参数，并提供布局/离屏位置的计算
final class ZHHPopupViewModel {
    /// 遮罩类型（默认黑色半透明）
    var maskType: ZHHPopupMaskType = .blackOpacity
    /// 遮罩透明度（默认 0.35，仅对 `.blackOpacity` 生效）
    var maskAlpha: CGFloat = 0.35
    /// 内容视图的静止位置（默认居中）
    var layoutType: ZHHPopupLayoutType = .center
    /// 展示动画类型（默认淡入）
    var presentationStyle: ZHHPopupSlideStyle = .fade
    /// 消失动画类型（不设置则沿用展示动画）
    var dismissalStyle: ZHHPopupSlideStyle?
    /// 多弹窗叠放层级（默认 normal）
    var windowLevel: ZHHPopupWindowLevel = .normal
    /// transform 展示动画的起始缩放（默认 0.5）
    var presentationTransformScale: CGFloat = 0.5
    /// transform 消失动画的结束缩放（默认 0.5）
    var dismissalTransformScale: CGFloat = 0.5
    /// 点击背景是否关闭（默认开启）
    var dismissOnMaskTouched: Bool = true
    /// 点击内容是否关闭（默认关闭）
    var dismissOnContentTouched: Bool = false
    /// 自动关闭延迟（<=0 表示不自动关闭）
    var dismissAfterDelay: TimeInterval = 0
    /// 是否启用拖拽关闭
    var panGestureEnabled: Bool = false
    /// 是否允许拖拽触发关闭（默认允许；关闭后只回弹不消失）
    var panDismissEnabled: Bool = true
    /// 拖拽关闭阈值比例（默认 0.5）
    var panDismissRatio: CGFloat = 0.5
    /// 布局偏移（用于微调，默认 0）
    var offsetSpacing: CGFloat = 0
    /// 键盘联动时额外留白（默认 0）
    var keyboardOffsetSpacing: CGFloat = 0
    /// 是否跟随键盘 frame 变化（默认关闭）
    var keyboardChangeFollowed: Bool = false
    /// 展示时是否同步第一响应者（默认关闭）
    var syncFirstResponderWithPresentation: Bool = false
    /// 关闭动画是否使用弹性（默认关闭）
    var dismissBounced: Bool = false

    /// 获取实际消失动画：优先使用 dismissalStyle，否则沿用 presentationStyle
    func effectiveDismissalSlideStyle() -> ZHHPopupSlideStyle {
        dismissalStyle ?? presentationStyle
    }

    /// 计算内容视图的最终静止中心点（用于展示完成后的目标位置）
    func finalRestingCenter(maskBounds: CGRect, contentSize: CGSize) -> CGPoint {
        let mx = maskBounds.midX
        let my = maskBounds.midY
        switch layoutType {
        case .top:
            return CGPoint(x: mx, y: contentSize.height / 2 + offsetSpacing)
        case .left:
            return CGPoint(x: contentSize.width / 2 + offsetSpacing, y: my)
        case .bottom:
            return CGPoint(x: mx, y: maskBounds.maxY - contentSize.height / 2 - offsetSpacing)
        case .right:
            return CGPoint(x: maskBounds.maxX - contentSize.width / 2 - offsetSpacing, y: my)
        case .center:
            return CGPoint(x: mx, y: my + offsetSpacing)
        case .custom:
            return CGPoint(x: mx, y: my + offsetSpacing)
        case .aboveCenter:
            return CGPoint(x: mx, y: my - contentSize.height / 2 + offsetSpacing)
        case .belowCenter:
            return CGPoint(x: mx, y: my + contentSize.height / 2 + offsetSpacing)
        }
    }

    /// 计算内容视图的离屏中心点（用于 slide 动画的起始/结束位置）
    func offscreenCenter(for slideStyle: ZHHPopupSlideStyle, maskBounds: CGRect, contentSize: CGSize, resting: CGPoint) -> CGPoint {
        let w = contentSize.width
        let h = contentSize.height
        let mh = maskBounds.height
        let mw = maskBounds.width
        switch slideStyle {
        case .fromTop:
            // 从上方离屏
            return CGPoint(x: resting.x, y: -h / 2)
        case .fromLeft:
            // 从左侧离屏
            return CGPoint(x: -w / 2, y: resting.y)
        case .fromBottom:
            // 从下方离屏
            return CGPoint(x: resting.x, y: mh + h / 2)
        case .fromRight:
            // 从右侧离屏
            return CGPoint(x: mw + w / 2, y: resting.y)
        case .fade, .transform:
            // fade/transform 不依赖离屏位置
            return resting
        }
    }
}
