//
//  DemoPopupContentView.swift
//  ZHHPopupController_Example
//

import UIKit
import SnapKit

final class DemoPopupContentView: UIView {
    var onClose: (() -> Void)?

    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let button = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.masksToBounds = true

        titleLabel.text = "提示"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        descLabel.text = "你的请求已提交成功，我们会尽快处理。"
        descLabel.font = .systemFont(ofSize: 15)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        addSubview(descLabel)

        button.setTitle("知道了", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(button)

        closeButton.setTitle("×", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .medium)
        closeButton.tintColor = .tertiaryLabel
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        addSubview(closeButton)

        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 44))
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(22)
        }

        button.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(22)
            make.bottom.equalToSuperview().inset(22)
            make.height.equalTo(44)
        }

        descLabel.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualTo(button.snp.top).offset(-18)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    @objc private func closeTapped() {
        onClose?()
    }
}

