//
//  ZHHPopupController+Gestures.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 手势相关逻辑：背景点击、内容点击、拖拽关闭，以及与滚动视图手势的协调
extension ZHHPopupController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer === panGesture {
            // 底部拖拽：对齐 ZHHBottomSelectView 的规则
            // - 触点落在 UIControl（按钮等）上：不接管
            // - 触点在 UIScrollView 内：不接管（滚动优先）
            // - 仅允许从内容视图顶部一小段区域开始拖拽
            guard viewModel.layoutType == .bottom else { return true }
            if touch.view is UIControl { return false }
            var currentView: UIView? = touch.view
            while let v = currentView {
                if v is UIScrollView {
                    return false
                }
                if v === contentView {
                    break
                }
                currentView = v.superview
            }
            let point = touch.location(in: contentView)
            if bottomPanFullScreenEnabled {
                return true
            }
            return point.y <= bottomPanHandleHeight
        }
        if gestureRecognizer === tapGesture {
            // 背景点击：只在触点不落在内容视图上时才响应
            guard let tv = touch.view else { return true }
            return !tv.isDescendant(of: contentView)
        }
        if gestureRecognizer === contentTapGesture {
            // 内容点击：避免拦截 UIControl（按钮、开关等）自身的交互
            if touch.view is UIControl { return false }
            guard let tv = touch.view else { return true }
            return tv.isDescendant(of: contentView)
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 拖拽关闭与 UIScrollView 的滚动手势可同时识别
        guard gestureRecognizer === panGesture else { return false }
        guard let otherView = otherGestureRecognizer.view as? UIScrollView else { return false }
        return otherGestureRecognizer === otherView.panGestureRecognizer
    }

    @objc internal func handleTapGesture(_: UITapGestureRecognizer) {
        // 点击背景关闭
        guard isPresentingInternal, viewModel.dismissOnMaskTouched else { return }
        defaultDismissBlock?(self)
    }

    @objc internal func handleContentTapGesture(_: UITapGestureRecognizer) {
        // 点击内容关闭
        guard isPresentingInternal, viewModel.dismissOnContentTouched else { return }
        defaultDismissBlock?(self)
    }

    @objc internal func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        // 键盘展示时禁用拖拽，避免与输入状态冲突
        guard let mask = maskView, viewModel.panGestureEnabled, viewModel.panDismissEnabled, !isKeyboardVisible else { return }
        let panTranslation = pan.translation(in: mask)
        switch pan.state {
        case .began:
            if viewModel.layoutType == .bottom {
                bottomPanBaseCenter = contentView.center
                bottomPanBaseMaskAlpha = mask.alpha
            } else {
                panBaseCenter = contentView.center
                panBaseMaskAlpha = mask.alpha
            }
        case .changed:
            if viewModel.layoutType == .bottom {
                handleBottomPanChanged(pan, translation: panTranslation, mask: mask)
            } else if viewModel.layoutType == .top || viewModel.layoutType == .left || viewModel.layoutType == .right {
                handleEdgePanChanged(pan, translation: panTranslation, mask: mask)
            } else {
                handlePanChanged(pan, translation: panTranslation, mask: mask)
                pan.setTranslation(.zero, in: mask)
            }
        case .ended, .cancelled, .failed:
            if viewModel.layoutType == .bottom {
                handleBottomPanEnded(pan, mask: mask)
            } else if viewModel.layoutType == .top || viewModel.layoutType == .left || viewModel.layoutType == .right {
                handleEdgePanEnded(pan, mask: mask)
            } else {
                handlePanEnded(pan, mask: mask)
            }
        default:
            break
        }
    }

    private func handlePanChanged(_ pan: UIPanGestureRecognizer, translation: CGPoint, mask: UIView) {
        guard let v = pan.view else { return }
        let layout = viewModel.layoutType
        let offset = viewModel.offsetSpacing
        switch layout {
        case .top:
            // 顶部布局：只允许向上拖动以关闭，并根据拖动距离调整遮罩透明度
            let boundary = v.bounds.height + offset
            if v.frame.minY + v.bounds.height + translation.y < boundary {
                v.center = CGPoint(x: v.center.x, y: v.center.y + translation.y)
            } else {
                v.center = restingCenter()
            }
            maskView?.alpha = v.frame.maxY / boundary
        case .left:
            // 左侧布局：只允许向左拖动以关闭
            let boundary = v.bounds.width + offset
            if v.frame.minX + v.bounds.width + translation.x < boundary {
                v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y)
            } else {
                v.center = restingCenter()
            }
            maskView?.alpha = v.frame.maxX / boundary
        case .bottom:
            // 底部布局：由 handleBottomPanChanged 处理（使用累计 translation）
            break
        case .right:
            // 右侧布局：只允许向右拖动以关闭
            let boundary = mask.bounds.width - v.bounds.width - offset
            if v.frame.minX + translation.x > boundary {
                v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y)
            } else {
                v.center = restingCenter()
            }
            let denom = mask.bounds.width - boundary
            if denom > 0 {
                maskView?.alpha = 1 - (v.frame.minX - boundary) / denom
            }
        case .center, .custom, .aboveCenter, .belowCenter:
            // 居中布局：首次移动锁定方向（横/竖），按单一方向拖动
            updateCenterPanChanged(v: v, translation: translation, mask: mask)
        }
    }

    private func updateCenterPanChanged(v: UIView, translation: CGPoint, mask: UIView) {
        // 首次拖动时锁定方向，避免横竖混合导致手感漂移
        if !isDirectionLocked {
            directionalVertical = abs(translation.x) < abs(translation.y)
            isDirectionLocked = true
        }
        if directionalVertical {
            // 竖向拖动：只改变 y，按拖动距离衰减遮罩透明度
            v.center = CGPoint(x: v.center.x, y: v.center.y + translation.y)
            // boundary：内容视图在“居中布局”下的起始上边界（用于计算遮罩渐变）
            let boundary = mask.bounds.height / 2 + viewModel.offsetSpacing - v.bounds.height / 2
            let denom = mask.bounds.height - boundary
            if denom > 0 {
                maskView?.alpha = 1 - (v.frame.minY - boundary) / denom
            }
        } else {
            // 横向拖动：只改变 x，按拖动距离衰减遮罩透明度
            v.center = CGPoint(x: v.center.x + translation.x, y: v.center.y)
            // boundary：内容视图在“居中布局”下的起始左边界（用于计算遮罩渐变）
            let boundary = mask.bounds.width / 2 + viewModel.offsetSpacing - v.bounds.width / 2
            let denom = mask.bounds.width - boundary
            if denom > 0 {
                maskView?.alpha = 1 - (v.frame.minX - boundary) / denom
            }
        }
    }

    private func handleBottomPanChanged(_ pan: UIPanGestureRecognizer, translation: CGPoint, mask: UIView) {
        guard let v = pan.view else { return }
        // 只处理向下拖拽
        if translation.y <= 0 { return }

        let offset = viewModel.offsetSpacing
        let y = mask.bounds.height - v.bounds.height - offset
        v.center = CGPoint(x: bottomPanBaseCenter.x, y: bottomPanBaseCenter.y + translation.y)
        if v.frame.minY < y {
            v.center = restingCenter()
        }
        let scale = (v.frame.minY - y) / v.bounds.height
        maskView?.alpha = bottomPanBaseMaskAlpha * (1 - scale)
    }

    private func handleBottomPanEnded(_ pan: UIPanGestureRecognizer, mask: UIView) {
        guard let v = pan.view else { return }
        let velocity = pan.velocity(in: mask)
        let offset = viewModel.offsetSpacing
        let y = mask.bounds.height - v.bounds.height - offset
        let dragged = max(0, v.frame.minY - y)
        let ratio = min(0.35, viewModel.panDismissRatio)
        let distanceThreshold = max(10, v.bounds.height * ratio)
        let needDismiss = (velocity.y > 1200) || dragged > distanceThreshold
        if needDismiss {
            defaultDismissBlock?(self)
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.maskView?.alpha = self.bottomPanBaseMaskAlpha
                v.center = self.restingCenter()
            })
        }
    }

    private func handleEdgePanChanged(_ pan: UIPanGestureRecognizer, translation: CGPoint, mask: UIView) {
        guard let v = pan.view else { return }
        let offset = viewModel.offsetSpacing
        switch viewModel.layoutType {
        case .top:
            // 顶部：只允许向上拖动
            if translation.y >= 0 { return }
            let boundary = v.bounds.height + offset
            v.center = CGPoint(x: panBaseCenter.x, y: panBaseCenter.y + translation.y)
            if v.frame.maxY > boundary {
                v.center = restingCenter()
            }
            maskView?.alpha = panBaseMaskAlpha * (v.frame.maxY / boundary)
        case .left:
            // 左侧：只允许向左拖动
            if translation.x >= 0 { return }
            let boundary = v.bounds.width + offset
            v.center = CGPoint(x: panBaseCenter.x + translation.x, y: panBaseCenter.y)
            if v.frame.maxX > boundary {
                v.center = restingCenter()
            }
            maskView?.alpha = panBaseMaskAlpha * (v.frame.maxX / boundary)
        case .right:
            // 右侧：只允许向右拖动
            if translation.x <= 0 { return }
            let boundary = mask.bounds.width - v.bounds.width - offset
            v.center = CGPoint(x: panBaseCenter.x + translation.x, y: panBaseCenter.y)
            if v.frame.minX < boundary {
                v.center = restingCenter()
            }
            let denom = mask.bounds.width - boundary
            if denom > 0 {
                maskView?.alpha = panBaseMaskAlpha * (1 - (v.frame.minX - boundary) / denom)
            }
        default:
            break
        }
    }

    private func handleEdgePanEnded(_ pan: UIPanGestureRecognizer, mask: UIView) {
        guard let v = pan.view else { return }
        let velocity = pan.velocity(in: mask)
        let offset = viewModel.offsetSpacing
        let ratio = min(0.35, viewModel.panDismissRatio)
        var needDismiss = false

        switch viewModel.layoutType {
        case .top:
            let boundary = v.bounds.height + offset
            let dragged = max(0, boundary - v.frame.maxY)
            let threshold = max(10, v.bounds.height * ratio)
            needDismiss = (velocity.y < -1200) || dragged > threshold
        case .left:
            let boundary = v.bounds.width + offset
            let dragged = max(0, boundary - v.frame.maxX)
            let threshold = max(10, v.bounds.width * ratio)
            needDismiss = (velocity.x < -1200) || dragged > threshold
        case .right:
            let boundary = mask.bounds.width - v.bounds.width - offset
            let dragged = max(0, v.frame.minX - boundary)
            let threshold = max(10, v.bounds.width * ratio)
            needDismiss = (velocity.x > 1200) || dragged > threshold
        default:
            break
        }

        if needDismiss {
            defaultDismissBlock?(self)
        } else {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
                self.maskView?.alpha = self.panBaseMaskAlpha
                v.center = self.restingCenter()
            })
        }
    }

    private func handlePanEnded(_ pan: UIPanGestureRecognizer, mask: UIView) {
        guard let v = pan.view else { return }
        // ratio：判定关闭的阈值比例（越大越难触发关闭）
        let ratio = viewModel.panDismissRatio
        var needDismiss = false
        switch viewModel.layoutType {
        case .top:
            // 顶部：向上拖动后，底边低于阈值则关闭
            needDismiss = v.frame.maxY < mask.bounds.height * ratio
        case .left:
            // 左侧：向左拖动后，右边低于阈值则关闭
            needDismiss = v.frame.maxX < mask.bounds.width * ratio
        case .bottom:
            // 底部由 handleBottomPanEnded 处理
            needDismiss = false
        case .right:
            // 右侧：向右拖动后，左边高于阈值则关闭
            needDismiss = v.frame.minX > mask.bounds.width * ratio
        case .center, .custom, .aboveCenter, .belowCenter:
            // 居中布局：竖向仅判断向下拖动；横向判断左右越界
            if directionalVertical {
                // 竖向：只判断向下拖动的距离是否超过阈值
                needDismiss = v.frame.minY > mask.bounds.height * ratio
            } else {
                let w = mask.bounds.width
                // 横向：向右或向左拖动超过阈值都可触发关闭
                needDismiss = v.frame.minX > w * ratio || v.frame.maxX < w * (1 - ratio)
            }
            // 每次结束后解除方向锁，下一次拖动重新判定方向
            isDirectionLocked = false
        }
        if needDismiss {
            // 达到阈值则关闭
            defaultDismissBlock?(self)
        } else {
            // 未达到阈值则回弹复位，并恢复遮罩透明度
            if viewModel.layoutType == .bottom {
                UIView.animate(
                    withDuration: 0.35,
                    delay: 0,
                    usingSpringWithDamping: 0.86,
                    initialSpringVelocity: 0.35,
                    options: [.curveEaseOut, .allowUserInteraction],
                    animations: {
                        self.maskView?.alpha = 1
                        v.center = self.restingCenter()
                    }
                )
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                    self.maskView?.alpha = 1
                    v.center = self.restingCenter()
                })
            }
        }
    }
}
