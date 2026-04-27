//
//  ZHHPopupTypes.swift
//  ZHHPopupController
//
//  Created by 桃色三岁 on 04/10/2026.
//  Copyright (c) 2026 桃色三岁. All rights reserved.
//

import UIKit

/// 遮罩类型：决定遮罩的视觉效果与背景交互方式
public enum ZHHPopupMaskType: UInt {
    /// 深色模糊
    case darkBlur = 0
    /// 浅色模糊
    case lightBlur
    /// 超浅模糊
    case extraLightBlur
    /// 纯白背景
    case white
    /// 透明遮罩（不改变背景视觉，但拦截触摸）
    case clear
    /// 黑色半透明遮罩（拦截触摸）
    case blackOpacity
    /// 无遮罩（触摸透传到背景）
    case none
}

/// 动画类型：决定内容视图展示/消失的过渡方式
public enum ZHHPopupSlideStyle: Int {
    /// 从上方滑入/滑出
    case fromTop = 0
    /// 从下方滑入/滑出
    case fromBottom
    /// 从左侧滑入/滑出
    case fromLeft
    /// 从右侧滑入/滑出
    case fromRight
    /// 透明度渐变
    case fade
    /// 缩放变换（配合 transformScale）
    case transform
}

/// 布局枚举：用于决定内容视图的静止位置（业务常用预置位置）
public enum ZHHPopupLayoutType: UInt {
    /// 顶部
    case top = 0
    /// 底部
    case bottom
    /// 左侧
    case left
    /// 右侧
    case right
    /// 居中
    case center
    /// 自定义（使用 offsetSpacing 作为微调）
    case custom
    /// 偏上（在居中基础上向上偏移半个内容高度）
    case aboveCenter
    /// 偏下（在居中基础上向下偏移半个内容高度）
    case belowCenter
}

/// 多弹窗层级：用于决定不同弹窗之间的叠放顺序
public enum ZHHPopupWindowLevel: UInt {
    /// 最高层
    case veryHigh = 0
    /// 较高
    case high
    /// 默认
    case normal
    /// 较低
    case low
    /// 最低层
    case veryLow
}
