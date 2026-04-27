//
//  ZHHPopupController+Animation.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

extension ZHHPopupController {
    internal func performPresent(duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, bounced: Bool, completion: (() -> Void)?) {
        guard !isPresentingInternal else { return }
        maskView?.alpha = 0
        applyTakeSlideStyle(viewModel.presentationStyle, scale: viewModel.presentationTransformScale)
        contentView.center = offscreenCenter(for: viewModel.presentationStyle)
        let finished: () -> Void = { [weak self] in
            guard let self else { return }
            self.isPresentingInternal = true
            self.notifyDidPresent()
            self.scheduleDismissAfterDelay()
            completion?()
        }
        if viewModel.keyboardChangeFollowed && viewModel.syncFirstResponderWithPresentation {
            contentView.center = restingCenter()
            notifyWillPresent()
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                self.maskView?.alpha = 1
                self.applyFinalSlideStyle()
            }, completion: { _ in finished() })
            return
        }
        notifyWillPresent()
        if bounced {
            UIView.animate(withDuration: duration * 0.25, delay: delay, options: options, animations: {
                self.maskView?.alpha = 1
            })
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.25, options: options, animations: {
                self.applyFinalSlideStyle()
                self.contentView.center = self.restingCenter()
            }, completion: { _ in finished() })
        } else {
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
                self.maskView?.alpha = 1
                self.applyFinalSlideStyle()
                self.contentView.center = self.restingCenter()
            }, completion: { _ in finished() })
        }
    }

    internal func performDismiss(duration: TimeInterval, delay: TimeInterval, options: UIView.AnimationOptions, onComplete: (() -> Void)?) {
        guard isPresentingInternal else { return }
        cancelDismissWorkItem()
        isPresentingInternal = false
        notifyWillDismiss()
        let dismissStyle = viewModel.effectiveDismissalSlideStyle()
        let animations = {
            self.applyTakeSlideStyle(dismissStyle, scale: self.viewModel.dismissalTransformScale)
            self.contentView.center = self.offscreenCenter(for: dismissStyle)
            self.maskView?.alpha = 0
        }
        let completionBlock: (Bool) -> Void = { _ in
            self.applyFinalSlideStyle()
            self.removePresentedHierarchy()
            self.notifyDidDismiss()
            onComplete?()
        }
        if viewModel.dismissBounced {
            UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.35, options: options, animations: animations, completion: completionBlock)
        } else {
            UIView.animate(withDuration: duration, delay: delay, options: options, animations: animations, completion: completionBlock)
        }
    }

    private func applyTakeSlideStyle(_ style: ZHHPopupSlideStyle, scale: CGFloat) {
        switch style {
        case .fade:
            contentView.alpha = 0
        case .transform:
            contentView.alpha = 0
            contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        case .fromTop, .fromBottom, .fromLeft, .fromRight:
            break
        }
    }

    private func applyFinalSlideStyle() {
        switch viewModel.presentationStyle {
        case .fade:
            contentView.alpha = 1
        case .transform:
            contentView.alpha = 1
            contentView.transform = .identity
        case .fromTop, .fromBottom, .fromLeft, .fromRight:
            break
        }
    }

    private func notifyWillPresent() {
        if let willPresentBlock {
            willPresentBlock(self)
        } else {
            delegate?.popupControllerWillPresent?(self)
        }
    }

    private func notifyDidPresent() {
        if let didPresentBlock {
            didPresentBlock(self)
        } else {
            delegate?.popupControllerDidPresent?(self)
        }
    }

    private func notifyWillDismiss() {
        if let willDismissBlock {
            willDismissBlock(self)
        } else {
            delegate?.popupControllerWillDismiss?(self)
        }
    }

    private func notifyDidDismiss() {
        if let didDismissBlock {
            didDismissBlock(self)
        } else {
            delegate?.popupControllerDidDismiss?(self)
        }
    }
}
