//
//  ZHHPopupController.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 弹窗控制器：管理内容视图的展示/消失、遮罩、手势交互、键盘联动等能力
@objc public protocol ZHHPopupControllerDelegate: AnyObject {
    /// 弹窗即将展示
    @objc optional func popupControllerWillPresent(_ popupController: ZHHPopupController)
    /// 弹窗已完成展示
    @objc optional func popupControllerDidPresent(_ popupController: ZHHPopupController)
    /// 弹窗即将消失
    @objc optional func popupControllerWillDismiss(_ popupController: ZHHPopupController)
    /// 弹窗已完成消失
    @objc optional func popupControllerDidDismiss(_ popupController: ZHHPopupController)
}

/// 核心弹窗对象：持有内容视图与配置，实际呈现由 `ZHHPopupContainerView` 承载
public final class ZHHPopupController: NSObject {
    /// 需要被弹出的内容视图
    public private(set) var contentView: UIView
    /// 内部展示状态（对外通过 `isPresenting` 只读暴露）
    internal var isPresentingInternal = false
    /// 是否处于展示中
    public var isPresenting: Bool { isPresentingInternal }
    /// 生命周期代理（与 block 回调互斥：如果设置了 block，则优先 block）
    public weak var delegate: ZHHPopupControllerDelegate?

    /// 内部状态与计算（遮罩/布局/动画参数等）
    let viewModel = ZHHPopupViewModel()

    /// 弹窗承载容器（由 `UIView.presentPopupController` 创建并管理）
    weak var hostingContainer: ZHHPopupContainerView?
    /// 遮罩视图（由 maskType 决定外观与交互）
    internal var maskView: UIView?

    /// 点击背景手势（是否触发关闭由 `dismissOnMaskTouched` 控制）
    internal let tapGesture = UITapGestureRecognizer()
    /// 点击内容手势（是否触发关闭由 `dismissOnContentTouched` 控制）
    internal let contentTapGesture = UITapGestureRecognizer()
    /// 拖拽手势（是否启用由 `panGestureEnabled` 控制）
    internal let panGesture = UIPanGestureRecognizer()

    /// 自动关闭任务
    internal var dismissWorkItem: DispatchWorkItem?
    /// 键盘通知监听 token
    internal var keyboardObservers: [NSObjectProtocol] = []
    /// 键盘是否可见（用于禁用拖拽等交互）
    internal var isKeyboardVisible = false
    /// 居中拖拽时的方向标记：true=竖向，false=横向
    internal var directionalVertical = false
    /// 居中拖拽时是否已锁定方向
    internal var isDirectionLocked = false
    /// 底部拖拽：开始时内容视图中心点（用于累计 translation）
    internal var bottomPanBaseCenter: CGPoint = .zero
    /// 底部拖拽：开始时遮罩透明度（用于拖拽过程中同步渐变）
    internal var bottomPanBaseMaskAlpha: CGFloat = 1

    /// 非底部拖拽：开始时内容视图中心点（用于累计 translation）
    internal var panBaseCenter: CGPoint = .zero
    /// 非底部拖拽：开始时遮罩透明度（用于拖拽过程中同步渐变）
    internal var panBaseMaskAlpha: CGFloat = 1

    /// 默认关闭行为（内部点击/拖拽/自动关闭都会走这里，便于外部替换）
    public var defaultDismissBlock: ((ZHHPopupController) -> Void)?
    /// 即将展示回调
    public var willPresentBlock: ((ZHHPopupController) -> Void)?
    /// 已完成展示回调
    public var didPresentBlock: ((ZHHPopupController) -> Void)?
    /// 即将消失回调
    public var willDismissBlock: ((ZHHPopupController) -> Void)?
    /// 已完成消失回调
    public var didDismissBlock: ((ZHHPopupController) -> Void)?

    /// 遮罩类型（变更时会重建遮罩视图）
    public var maskType: ZHHPopupMaskType {
        get { viewModel.maskType }
        set {
            guard viewModel.maskType != newValue else { return }
            viewModel.maskType = newValue
            rebuildMaskIfNeeded()
        }
    }

    /// 遮罩透明度（仅对 `.blackOpacity` 生效）
    public var maskAlpha: CGFloat {
        get { viewModel.maskAlpha }
        set {
            guard abs(viewModel.maskAlpha - newValue) > 0.0001 else { return }
            viewModel.maskAlpha = newValue
            if maskView != nil, viewModel.maskType == .blackOpacity {
                maskView?.backgroundColor = UIColor.black.withAlphaComponent(newValue)
                return
            }
            rebuildMaskIfNeeded()
        }
    }

    /// 内容视图的静止位置
    public var layoutType: ZHHPopupLayoutType {
        get { viewModel.layoutType }
        set { viewModel.layoutType = newValue }
    }

    /// 展示动画类型
    public var presentationStyle: ZHHPopupSlideStyle {
        get { viewModel.presentationStyle }
        set { viewModel.presentationStyle = newValue }
    }

    /// 消失动画类型（不设置则沿用展示动画）
    public var dismissalStyle: ZHHPopupSlideStyle? {
        get { viewModel.dismissalStyle }
        set { viewModel.dismissalStyle = newValue }
    }

    /// 多弹窗叠放层级（用于排序插入）
    public var windowLevel: ZHHPopupWindowLevel {
        get { viewModel.windowLevel }
        set { viewModel.windowLevel = newValue }
    }

    /// transform 展示动画的起始缩放（仅 `.transform` 生效）
    public var presentationTransformScale: CGFloat {
        get { viewModel.presentationTransformScale }
        set { viewModel.presentationTransformScale = newValue }
    }

    /// transform 消失动画的结束缩放（仅 `.transform` 生效）
    public var dismissalTransformScale: CGFloat {
        get { viewModel.dismissalTransformScale }
        set { viewModel.dismissalTransformScale = newValue }
    }

    /// 点击背景是否关闭
    public var dismissOnMaskTouched: Bool {
        get { viewModel.dismissOnMaskTouched }
        set { viewModel.dismissOnMaskTouched = newValue }
    }

    /// 点击内容是否关闭（启用后会给 contentView 绑定 tap 手势）
    public var dismissOnContentTouched: Bool {
        get { viewModel.dismissOnContentTouched }
        set {
            guard viewModel.dismissOnContentTouched != newValue else { return }
            viewModel.dismissOnContentTouched = newValue
            syncContentTapGesture()
        }
    }

    /// 自动关闭延迟（<=0 表示不自动关闭）
    public var dismissAfterDelay: TimeInterval {
        get { viewModel.dismissAfterDelay }
        set { viewModel.dismissAfterDelay = newValue }
    }

    /// 关闭动画是否使用弹性（spring）
    public var dismissBounced: Bool {
        get { viewModel.dismissBounced }
        set { viewModel.dismissBounced = newValue }
    }

    /// 是否启用拖拽关闭
    public var panGestureEnabled: Bool {
        get { viewModel.panGestureEnabled }
        set {
            guard viewModel.panGestureEnabled != newValue else { return }
            viewModel.panGestureEnabled = newValue
            syncPanGesture()
        }
    }

    /// 拖拽关闭阈值比例（越大越难触发关闭）
    public var panDismissRatio: CGFloat {
        get { viewModel.panDismissRatio }
        set { viewModel.panDismissRatio = newValue }
    }

    /// 是否允许拖拽触发关闭（默认开启；关闭后拖拽手势不生效）
    public var panDismissEnabled: Bool {
        get { viewModel.panDismissEnabled }
        set { viewModel.panDismissEnabled = newValue }
    }

    /// 底部拖拽句柄高度：仅当触点落在内容视图顶部区域时才允许拖拽关闭（默认 32）
    public var bottomPanHandleHeight: CGFloat = 32

    /// 底部拖拽是否允许全区域触发（默认关闭；开启后内容视图内任意位置都可下拉关闭，UIControl/UIScrollView 仍不接管）
    public var bottomPanFullScreenEnabled: Bool = false

    /// 布局偏移（用于微调）
    public var offsetSpacing: CGFloat {
        get { viewModel.offsetSpacing }
        set { viewModel.offsetSpacing = newValue }
    }

    /// 键盘联动时额外留白
    public var keyboardOffsetSpacing: CGFloat {
        get { viewModel.keyboardOffsetSpacing }
        set { viewModel.keyboardOffsetSpacing = newValue }
    }

    /// 是否跟随键盘 frame 变化调整内容位置
    public var keyboardChangeFollowed: Bool {
        get { viewModel.keyboardChangeFollowed }
        set {
            guard viewModel.keyboardChangeFollowed != newValue else { return }
            viewModel.keyboardChangeFollowed = newValue
            if newValue {
                bindKeyboardNotifications()
            } else {
                unbindKeyboardNotifications()
            }
        }
    }

    /// 展示时是否同步第一响应者（用于弹出时直接聚焦输入框）
    public var syncFirstResponderWithPresentation: Bool {
        get { viewModel.syncFirstResponderWithPresentation }
        set { viewModel.syncFirstResponderWithPresentation = newValue }
    }

    @available(*, unavailable)
    public override init() {
        contentView = UIView(frame: .zero)
        super.init()
    }

    public init(view: UIView, size: CGSize) {
        let useSize = size == .zero ? view.bounds.size : size
        contentView = view
        super.init()
        // 统一由 popupController 持有 contentView 的尺寸
        view.frame = CGRect(origin: .zero, size: useSize)
        // 默认关闭行为：调用自身 dismiss
        defaultDismissBlock = { [weak self] _ in self?.dismiss() }
        // 手势挂载
        tapGesture.addTarget(self, action: #selector(ZHHPopupController.handleTapGesture(_:)))
        tapGesture.delegate = self
        contentTapGesture.addTarget(self, action: #selector(ZHHPopupController.handleContentTapGesture(_:)))
        contentTapGesture.delegate = self
        panGesture.addTarget(self, action: #selector(ZHHPopupController.handlePanGesture(_:)))
        panGesture.delegate = self
    }

    deinit {
        unbindKeyboardNotifications()
        dismissWorkItem?.cancel()
    }

    internal func attachHostingContainer(_ container: ZHHPopupContainerView) {
        // 容器由 UIView 扩展创建，弹窗只做弱引用关联
        hostingContainer = container
    }

    internal func installInHost(below anchor: UIView?) {
        guard let container = hostingContainer else { return }
        // 确保遮罩存在
        ensureMaskView(bounds: container.bounds)
        guard let mask = maskView else { return }
        if let anchor {
            container.insertSubview(mask, belowSubview: anchor)
            container.insertSubview(contentView, aboveSubview: mask)
        } else {
            container.addSubview(mask)
            container.addSubview(contentView)
        }
        // 同步手势绑定
        syncPanGesture()
        syncContentTapGesture()
    }

    internal func ensureMaskView(bounds: CGRect) {
        if maskView == nil {
            // 首次创建遮罩
            let m = UIView(frame: bounds)
            m.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            applyMaskAppearance(to: m)
            m.addGestureRecognizer(tapGesture)
            maskView = m
            syncPanGesture()
            return
        }
        maskView?.frame = bounds
    }

    internal func applyMaskAppearance(to view: UIView) {
        // 重建外观前先清空子视图（避免 blur 叠加）
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = .clear
        // maskType = none 时，不拦截触摸（触摸透传由容器 hitTest 决定）
        view.isUserInteractionEnabled = viewModel.maskType != .none
        switch viewModel.maskType {
        case .darkBlur:
            addBlur(.dark, to: view)
        case .lightBlur:
            addBlur(.light, to: view)
        case .extraLightBlur:
            addBlur(.extraLight, to: view)
        case .white:
            view.backgroundColor = .white
        case .clear:
            view.backgroundColor = .clear
        case .blackOpacity:
            view.backgroundColor = UIColor.black.withAlphaComponent(viewModel.maskAlpha)
        case .none:
            view.backgroundColor = .clear
        }
    }

    private func addBlur(_ style: UIBlurEffect.Style, to container: UIView) {
        let effect = UIBlurEffect(style: style)
        let blur = UIVisualEffectView(effect: effect)
        blur.frame = container.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.insertSubview(blur, at: 0)
    }

    internal func rebuildMaskIfNeeded() {
        guard let mask = maskView, let container = hostingContainer, mask.superview == container, contentView.superview == container else {
            return
        }
        // 通过移除并重新创建遮罩，确保 blur / 背景色等外观切换一致
        let alpha = mask.alpha
        mask.removeGestureRecognizer(tapGesture)
        detachPanFromContent()
        mask.removeFromSuperview()
        maskView = nil
        ensureMaskView(bounds: container.bounds)
        maskView?.alpha = alpha
        guard let newMask = maskView else { return }
        container.insertSubview(newMask, belowSubview: contentView)
        newMask.addGestureRecognizer(tapGesture)
        syncPanGesture()
    }

    internal func syncPanGesture() {
        // 先移除，再按配置决定是否重新添加
        detachPanFromContent()
        guard viewModel.panGestureEnabled, maskView != nil else { return }
        if contentView.gestureRecognizers?.contains(panGesture) != true {
            contentView.addGestureRecognizer(panGesture)
        }
    }

    internal func syncContentTapGesture() {
        // 先移除，再按配置决定是否重新添加
        if contentView.gestureRecognizers?.contains(contentTapGesture) == true {
            contentView.removeGestureRecognizer(contentTapGesture)
        }
        guard viewModel.dismissOnContentTouched else { return }
        if contentView.gestureRecognizers?.contains(contentTapGesture) != true {
            contentView.addGestureRecognizer(contentTapGesture)
        }
    }

    private func detachPanFromContent() {
        if contentView.gestureRecognizers?.contains(panGesture) == true {
            contentView.removeGestureRecognizer(panGesture)
        }
    }

    internal func removePresentedHierarchy() {
        // 结束展示后清理：手势、内容视图、遮罩视图
        if let m = maskView {
            m.removeGestureRecognizer(tapGesture)
        }
        detachPanFromContent()
        if contentView.gestureRecognizers?.contains(contentTapGesture) == true {
            contentView.removeGestureRecognizer(contentTapGesture)
        }
        contentView.removeFromSuperview()
        maskView?.removeFromSuperview()
        maskView = nil
    }

    internal func cancelDismissWorkItem() {
        dismissWorkItem?.cancel()
        dismissWorkItem = nil
    }

    internal func restingCenter() -> CGPoint {
        // 内容视图最终静止中心点（由布局计算）
        guard let mask = maskView else { return .zero }
        return viewModel.finalRestingCenter(maskBounds: mask.bounds, contentSize: contentView.bounds.size)
    }

    internal func offscreenCenter(for slide: ZHHPopupSlideStyle) -> CGPoint {
        // 内容视图起始/结束的离屏中心点（用于 slide 动画）
        guard let mask = maskView else { return .zero }
        let rest = restingCenter()
        return viewModel.offscreenCenter(for: slide, maskBounds: mask.bounds, contentSize: contentView.bounds.size, resting: rest)
    }

    internal func scheduleDismissAfterDelay() {
        // 按配置调度自动关闭任务
        cancelDismissWorkItem()
        let delay = viewModel.dismissAfterDelay
        guard delay > 0 else { return }
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.defaultDismissBlock?(self)
        }
        dismissWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }
}
