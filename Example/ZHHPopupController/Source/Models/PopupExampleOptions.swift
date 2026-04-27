//
//  PopupExampleOptions.swift
//  ZHHPopupController_Example
//

import Foundation

enum PopupExampleSection: Int, CaseIterable {
    case layout
    case animation
    case mask
    case background
    case content
    case gestures
    case duration
}

enum PopupExampleShowOption: Int, CaseIterable {
    case none
    case fadeIn
    case growIn
    case shrinkIn
    case slideFromTop
    case slideFromBottom
    case slideFromLeft
    case slideFromRight
    case bounceIn
    case bounceFromTop
    case bounceFromBottom
    case bounceFromLeft
    case bounceFromRight

    var title: String {
        switch self {
        case .none: return "无"
        case .fadeIn: return "淡入"
        case .growIn: return "放大进入"
        case .shrinkIn: return "缩小进入"
        case .slideFromTop: return "从上滑入"
        case .slideFromBottom: return "从下滑入"
        case .slideFromLeft: return "从左滑入"
        case .slideFromRight: return "从右滑入"
        case .bounceIn: return "弹性进入"
        case .bounceFromTop: return "从上弹入"
        case .bounceFromBottom: return "从下弹入"
        case .bounceFromLeft: return "从左弹入"
        case .bounceFromRight: return "从右弹入"
        }
    }
}

enum PopupExampleDismissOption: Int, CaseIterable {
    case none
    case fadeOut
    case growOut
    case shrinkOut
    case slideToTop
    case slideToBottom
    case slideToLeft
    case slideToRight
    case bounceOut
    case bounceToTop
    case bounceToBottom
    case bounceToLeft
    case bounceToRight

    var title: String {
        switch self {
        case .none: return "无"
        case .fadeOut: return "淡出"
        case .growOut: return "放大退出"
        case .shrinkOut: return "缩小退出"
        case .slideToTop: return "向上滑出"
        case .slideToBottom: return "向下滑出"
        case .slideToLeft: return "向左滑出"
        case .slideToRight: return "向右滑出"
        case .bounceOut: return "弹性退出"
        case .bounceToTop: return "向上弹出"
        case .bounceToBottom: return "向下弹出"
        case .bounceToLeft: return "向左弹出"
        case .bounceToRight: return "向右弹出"
        }
    }
}

enum PopupExampleMaskOption: Int, CaseIterable {
    case none
    case clear
    case dimmed
    case darkBlur
    case lightBlur
    case extraLightBlur
    case white

    var title: String {
        switch self {
        case .none: return "无"
        case .clear: return "透明"
        case .dimmed: return "变暗"
        case .darkBlur: return "深色毛玻璃"
        case .lightBlur: return "浅色毛玻璃"
        case .extraLightBlur: return "超浅毛玻璃"
        case .white: return "纯白"
        }
    }
}

