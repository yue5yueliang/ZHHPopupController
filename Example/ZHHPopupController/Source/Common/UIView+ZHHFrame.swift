//
//  UIView+ZHHFrame.swift
//  ZHHYueYeExample
//
//  Created by 桃色三岁 on 2025/6/21.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

public extension UIView {

    // MARK: - 绝对坐标
    /// X 位置
    var zhh_x: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    /// Y 位置
    var zhh_y: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    /// 宽度
    var zhh_width: CGFloat {
        get { frame.size.width }
        set { frame.size.width = newValue }
    }

    /// 高度
    var zhh_height: CGFloat {
        get { frame.size.height }
        set { frame.size.height = newValue }
    }

    /// 最大 X 值（frame.maxX）
    var zhh_maxX: CGFloat {
        frame.maxX
    }

    /// 最大 Y 值（frame.maxY）
    var zhh_maxY: CGFloat {
        frame.maxY
    }

    /// 尺寸
    var zhh_size: CGSize {
        get { frame.size }
        set { frame.size = newValue }
    }

    /// 原点
    var zhh_origin: CGPoint {
        get { frame.origin }
        set { frame.origin = newValue }
    }

    /// X 原点
    var zhh_originX: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    /// Y 原点
    var zhh_originY: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    /// X 中心点
    var zhh_centerX: CGFloat {
        get { center.x }
        set { center.x = newValue }
    }

    /// Y 中心点
    var zhh_centerY: CGFloat {
        get { center.y }
        set { center.y = newValue }
    }

    /// 上边距（frame.origin.y）
    var zhh_top: CGFloat {
        get { frame.origin.y }
        set { frame.origin.y = newValue }
    }

    /// 下边距（frame.origin.y + height）
    var zhh_bottom: CGFloat {
        get { frame.origin.y + frame.size.height }
        set { frame.origin.y = newValue - frame.size.height }
    }

    /// 左边距（frame.origin.x）
    var zhh_left: CGFloat {
        get { frame.origin.x }
        set { frame.origin.x = newValue }
    }

    /// 右边距（frame.origin.x + width）
    var zhh_right: CGFloat {
        get { frame.origin.x + frame.size.width }
        set { frame.origin.x = newValue - frame.size.width }
    }
}

public extension UIView {
    
    
}
