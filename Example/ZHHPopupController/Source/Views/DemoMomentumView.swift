//
//  DemoMomentumView.swift
//  ZHHPopupController_Example
//

import UIKit

final class DemoMomentumPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
    }
}

final class DemoMomentumView: UIView {
    /// 半开位置：用于「半开 <-> 全开」两态切换（例如 y = height * 0.6）
    var closedTransform: CGAffineTransform = .identity {
        didSet { transform = closedTransform }
    }
    /// 关闭位置：用于「半开状态下继续下拉 -> 关闭」的动画终点（通常 y = height）
    var dismissTransform: CGAffineTransform = .identity
    /// 触发关闭时回调（外部一般在这里调用 popupController.dismiss()）
    var onDismiss: (() -> Void)?

    /// 当前是否处于全开（transform = .identity）
    private(set) var isOpen = false
    private var animator = UIViewPropertyAnimator()
    private var animationProgress: CGFloat = 0
    /// 半开状态下开始下拉关闭时的起始 transform（用于累计 dy）
    private var dismissStartTransform: CGAffineTransform = .identity
    /// 是否处于「半开下拉关闭」拖拽模式
    private var isDismissDragging = false

    private func syncOpenStateFromTransform() {
        // 只关心 y 位移：接近 0 认为全开
        isOpen = abs(transform.ty) < 0.5
    }

    private func syncTransformFromPresentationLayer() {
        if let p = layer.presentation() {
            transform = p.affineTransform()
        }
        layer.removeAllAnimations()
    }

    private func finishAnimatorToCurrentIfNeeded() {
        if animator.state != .inactive {
            animator.stopAnimation(false)
            animator.finishAnimation(at: .current)
        }
    }

    private func settle(to target: CGAffineTransform, completion: (() -> Void)? = nil) {
        finishAnimatorToCurrentIfNeeded()
        let timingParameters = UISpringTimingParameters(mass: 1, stiffness: 260, damping: 34, initialVelocity: .zero)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            self.transform = target
        }
        animator.addCompletion { _ in
            self.syncOpenStateFromTransform()
            completion?()
        }
        animator.startAnimation()
    }

    private lazy var panRecognizer: DemoMomentumPanGestureRecognizer = {
        let pan = DemoMomentumPanGestureRecognizer()
        pan.addTarget(self, action: #selector(panned))
        return pan
    }()

    private lazy var handleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 1, alpha: 0.5)
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizer(panRecognizer)
        backgroundColor = .systemOrange
        layer.cornerRadius = 30
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        addSubview(handleView)
        handleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            handleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 50),
            handleView.heightAnchor.constraint(equalToConstant: 6),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }
}

extension DemoMomentumView {
    @objc private func panned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            finishAnimatorToCurrentIfNeeded()
            syncTransformFromPresentationLayer()
            dismissStartTransform = transform
            isDismissDragging = false
            syncOpenStateFromTransform()
            // 每次开始拖拽都重新创建 animator，避免停在中间时 animator 处于不可用状态
            startAnimationIfNeeded(reset: true)
            animator.pauseAnimation()
            animationProgress = animator.fractionComplete
        case .changed:
            // 半开状态下向下拖：优先走「下拉关闭」分支（跟手移动，不走两态切换 animator）
            if !isOpen, recognizer.translation(in: self).y > 0 {
                isDismissDragging = true
                if animator.isRunning { animator.pauseAnimation() }
                let dy = recognizer.translation(in: self).y
                let maxDy = max(0, dismissTransform.ty - dismissStartTransform.ty)
                let useDy = min(dy, maxDy)
                transform = dismissStartTransform.translatedBy(x: 0, y: useDy)
                break
            }
            // 从「下拉关闭」反向回到两态切换：需要重建 animator，避免停在中间
            if isDismissDragging {
                isDismissDragging = false
                transform = closedTransform
                syncOpenStateFromTransform()
                dismissStartTransform = closedTransform
                recognizer.setTranslation(.zero, in: self)
                startAnimationIfNeeded(reset: true)
                animator.pauseAnimation()
                animationProgress = animator.fractionComplete
            }
            // 其它情况：走「半开 <-> 全开」两态切换（通过 fractionComplete 跟手）
            var fraction = -recognizer.translation(in: self).y / closedTransform.ty
            if isOpen { fraction *= -1 }
            if animator.isReversed { fraction *= -1 }
            let target = fraction + animationProgress
            animator.fractionComplete = min(1, max(0, target))
        case .ended, .cancelled:
            let yVelocity = recognizer.velocity(in: self).y
            // 半开状态下已经被下拉到超过半开位置：判定是否需要关闭，否则回弹到半开
            if !isOpen, transform.ty > closedTransform.ty {
                let dragged = transform.ty - closedTransform.ty
                let threshold = max(10, bounds.height * 0.15)
                let needDismiss = dragged > threshold || yVelocity > 1200
                if needDismiss {
                    settle(to: dismissTransform) {
                        self.onDismiss?()
                    }
                } else {
                    settle(to: closedTransform, completion: nil)
                }
                break
            }
            // 两态切换结束：根据速度决定最终落点（向下倾向收起到半开，向上倾向全开）
            let translationY = recognizer.translation(in: self).y
            let threshold = max(10, closedTransform.ty * 0.35)
            if isOpen {
                // 大屏 -> 小屏：按「下拉距离」判定，未满足则回到大屏
                let draggedDown = max(0, translationY)
                let needGoClosed = draggedDown > threshold || yVelocity > 1200
                animator.isReversed = !needGoClosed
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            } else {
                // 小屏 -> 大屏：按「上拉距离」判定，未满足则回到小屏
                let draggedUp = max(0, -translationY)
                let needGoOpen = draggedUp > threshold || yVelocity < -1200
                animator.isReversed = !needGoOpen
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                break
            }
        default:
            break
        }
    }

    private func startAnimationIfNeeded() {
        startAnimationIfNeeded(reset: false)
    }

    private func startAnimationIfNeeded(reset: Bool) {
        // animator 偶尔会在 stop/complete 后进入不可交互状态，所以允许强制重建
        if animator.isRunning { animator.stopAnimation(false); animator.finishAnimation(at: .current) }
        if !reset, animator.state != .inactive { return }
        let timingParameters = UISpringTimingParameters(mass: 1, stiffness: 320, damping: 40, initialVelocity: .zero)
        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timingParameters)
        animator.addAnimations {
            self.transform = self.isOpen ? self.closedTransform : .identity
        }
        animator.addCompletion { position in
            self.syncOpenStateFromTransform()
        }
        animator.startAnimation()
    }
}

