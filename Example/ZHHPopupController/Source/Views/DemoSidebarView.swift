//
//  DemoSidebarView.swift
//  ZHHPopupController_Example
//

import UIKit

final class DemoSidebarView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0x181c2d, alpha: 0.8)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor(hex: 0x181c2d, alpha: 0.8)
    }
}
