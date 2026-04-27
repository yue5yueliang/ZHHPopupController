//
//  DemoUpdatePopupView.swift
//  ZHHPopupController_Example
//

import UIKit
import SnapKit

final class DemoUpdatePopupView: UIView {
    var onUpdate: (() -> Void)?
    var onClose: (() -> Void)?

    private lazy var backgroundImageView: UIImageView = {
        let v = UIImageView(image: UIImage(named: "img_popup_update_bg"))
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "发现了新版本"
        l.textColor = .label
        l.font = .systemFont(ofSize: 20, weight: .semibold)
        return l
    }()

    private lazy var versionLabel: UILabel = {
        let l = UILabel()
        l.text = "V2.5.46"
        l.textColor = .secondaryLabel
        l.font = .systemFont(ofSize: 14, weight: .regular)
        return l
    }()

    private lazy var contentLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textColor = .label
        l.font = .systemFont(ofSize: 14)
        l.text =
            "1、直播部分页面交互逻辑的优化。\n\n" +
            "2、优化了商城下单支付功能，增加多个支付渠道。\n\n" +
            "3、优化了个人中心部分功能性能和体验，使用更顺畅。"
        return l
    }()

    private lazy var updateButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("立即更新", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        b.layer.cornerRadius = 22
        b.layer.masksToBounds = true
        b.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)
        return b
    }()

    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "ic_popup_close"), for: .normal)
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        layer.cornerRadius = 18
        layer.masksToBounds = true

        addSubview(backgroundImageView)
        addSubview(titleLabel)
        addSubview(versionLabel)
        addSubview(contentLabel)
        addSubview(updateButton)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(28)
            make.top.equalToSuperview().offset(32)
            make.right.lessThanOrEqualToSuperview().offset(-24)
        }

        versionLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.right.lessThanOrEqualToSuperview().offset(-24)
        }

        contentLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.right.equalToSuperview().offset(-28)
            make.top.equalTo(versionLabel.snp.bottom).offset(20)
        }

        updateButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.right.equalToSuperview().offset(-32)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-26)
        }

        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.42, blue: 0.18, alpha: 1).cgColor,
            UIColor(red: 1.0, green: 0.75, blue: 0.2, alpha: 1).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        updateButton.layer.insertSublayer(gradientLayer, at: 0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = updateButton.bounds
    }

    func makeContainerWithClose(spacing: CGFloat = 14) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear

        container.addSubview(self)
        container.addSubview(closeButton)

        self.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(360)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.snp.bottom).offset(spacing)
            make.centerX.equalToSuperview()
            make.size.equalTo(44)
            make.bottom.equalToSuperview()
        }
        return container
    }

    @objc private func updateTapped() {
        onUpdate?()
    }

    @objc private func closeTapped() {
        onClose?()
    }
}

