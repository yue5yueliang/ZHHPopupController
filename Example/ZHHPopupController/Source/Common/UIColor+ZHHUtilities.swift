//
//  UIColor+ZHHUtilities.swift
//  ZHHYueYeExample
//
//  Created by 桃色三岁 on 2025/6/21.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

public extension UIColor {
    
    /// 创建一个支持浅色和深色模式的动态颜色
    ///
    /// - Parameters:
    ///   - light: 浅色模式下的颜色
    ///   - dark: 深色模式下的颜色
    /// 该初始化器会根据当前系统的界面样式自动切换颜色，
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        }
    }
}

public extension UIColor {
    /// 创建十六进制颜色（0xRRGGBB 格式）
    /// - Parameters:
    ///   - hex: 十六进制整数，例如 0xFF0000 表示红色
    ///   - alpha: 透明度，范围 0~1，默认 1
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// 创建十六进制颜色（支持字符串格式）
    /// - Parameters:
    ///   - hexString: 十六进制字符串，例如 "#FF0000"、"0xFF0000"、"FF0000"
    ///   - alpha: 透明度，范围 0~1，默认 1
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        // 处理前缀
        if hex.hasPrefix("0X") {
            hex.removeFirst(2)
        } else if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        guard hex.count == 6 else {
            return nil
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        self.init(hex: Int(rgbValue), alpha: alpha)
    }
    
    /// 使用 0~255 范围的整数 RGB 分量和透明度初始化 UIColor
    /// - Parameters:
    ///   - redInt: 红色分量，范围 0~255
    ///   - greenInt: 绿色分量，范围 0~255
    ///   - blueInt: 蓝色分量，范围 0~255
    ///   - alpha: 透明度，范围 0~1，默认值为 1.0（不透明）
    convenience init(redInt: CGFloat, greenInt: CGFloat, blueInt: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: redInt / 255.0, green: greenInt / 255.0, blue: blueInt / 255.0, alpha: alpha)
    }
    
    /// 生成随机颜色
    /// - Parameter alpha: 透明度，范围 0~1，默认值为 1
    /// - Returns: 随机生成的 UIColor
    static func randomColor(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: alpha)
    }
    
    static var randomColor: UIColor {
        UIColor.randomColor()
    }
    
    /// 使用图片生成颜色（图案填充色）
    /// - Parameter image: 用作图案的图片
    /// - Returns: 使用图片生成的 UIColor
    static func zhh_color(with image: UIImage) -> UIColor {
        UIColor(patternImage: image)
    }
    
    /// 获取多个 UIColor 的平均颜色
    /// - Parameter colors: 颜色数组
    /// - Returns: 平均颜色（如果数组为空或无有效颜色，返回 nil）
    static func zhh_averageColor(from colors: [UIColor]) -> UIColor? {
        guard !colors.isEmpty else { return nil }

        var totalRed: CGFloat = 0
        var totalGreen: CGFloat = 0
        var totalBlue: CGFloat = 0
        var totalAlpha: CGFloat = 0
        var validCount = 0

        for color in colors {
            var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
            if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
                totalRed += r
                totalGreen += g
                totalBlue += b
                totalAlpha += a
                validCount += 1
            }
        }

        guard validCount > 0 else { return nil }

        return UIColor(
            red: totalRed / CGFloat(validCount),
            green: totalGreen / CGFloat(validCount),
            blue: totalBlue / CGFloat(validCount),
            alpha: totalAlpha / CGFloat(validCount)
        )
    }
}

/// 渐变方向定义枚举
public enum ZHHGradientDirection {
    case topToBottom                // 从上到下
    case bottomToTop                // 从下到上
    case leftToRight                // 从左到右
    case rightToLeft                // 从右到左
    case leftTopToRightBottom      // 左上到右下
    case leftBottomToRightTop      // 左下到右上
    case rightBottomToLeftTop      // 右下到左上
    case rightTopToLeftBottom      // 右上到左下
}

public extension UIColor {
    
    /// 使用渐变参数生成 UIColor（内部通过绘制生成 pattern image 实现）
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组（至少包含两个颜色）
    ///   - size: 渐变区域的尺寸（默认 `100x100`，影响颜色平铺比例）
    ///   - direction: 渐变方向，默认为从上到下（`.topToBottom`）
    ///   - locations: 可选的颜色位置数组，取值范围为 `[0, 1]`，用于控制颜色在渐变中的分布
    ///
    /// - Returns: 使用 pattern image 实现的 UIColor，如果创建失败则返回 nil
    convenience init?(gradient colors: [UIColor], size: CGSize = CGSize(width: 100, height: 100), direction: ZHHGradientDirection = .topToBottom, locations: [CGFloat]? = nil) {
        // 至少需要两个颜色才能生成渐变
        guard colors.count >= 2 else { return nil }

        // 定义起点和终点（使用单位坐标）
        let startPoint: CGPoint
        let endPoint: CGPoint

        switch direction {
        case .topToBottom:
            startPoint = CGPoint(x: 0.5, y: 0.0)
            endPoint = CGPoint(x: 0.5, y: 1.0)
        case .bottomToTop:
            startPoint = CGPoint(x: 0.5, y: 1.0)
            endPoint = CGPoint(x: 0.5, y: 0.0)
        case .leftToRight:
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
        case .rightToLeft:
            startPoint = CGPoint(x: 1.0, y: 0.5)
            endPoint = CGPoint(x: 0.0, y: 0.5)
        case .leftTopToRightBottom:
            startPoint = CGPoint(x: 0.0, y: 0.0)
            endPoint = CGPoint(x: 1.0, y: 1.0)
        case .leftBottomToRightTop:
            startPoint = CGPoint(x: 0.0, y: 1.0)
            endPoint = CGPoint(x: 1.0, y: 0.0)
        case .rightBottomToLeftTop:
            startPoint = CGPoint(x: 1.0, y: 1.0)
            endPoint = CGPoint(x: 0.0, y: 0.0)
        case .rightTopToLeftBottom:
            startPoint = CGPoint(x: 1.0, y: 0.0)
            endPoint = CGPoint(x: 0.0, y: 1.0)
        }

        // 将单位坐标转换为实际像素点
        let sp = CGPoint(x: startPoint.x * size.width, y: startPoint.y * size.height)
        let ep = CGPoint(x: endPoint.x * size.width, y: endPoint.y * size.height)

        // 创建图形上下文
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // 创建 CGGradient 对象
        let cgColors = colors.map { $0.cgColor } as CFArray
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: cgColors, locations: locations) else {
            UIGraphicsEndImageContext()
            return nil
        }

        // 绘制线性渐变
        context.drawLinearGradient(gradient, start: sp, end: ep, options: [])

        // 获取绘制的图像
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // 将图片作为 UIColor 的 patternImage
        guard let image = image else { return nil }
        self.init(patternImage: image)
    }
}
