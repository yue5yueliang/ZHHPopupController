//
//  DemoKeyboardViews.swift
//  ZHHPopupController_Example
//

import UIKit

final class DemoUnderlineTextField: UITextField {
    var underlineColor: UIColor = .darkGray {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // 旧版示例里使用下划线，这里改为卡片式输入框，不再绘制下划线
    }
}

final class DemoKeyboardView: UIView {
    var nextClickedBlock: ((DemoKeyboardView, UIButton) -> Void)?
    var loginClickedBlock: ((DemoKeyboardView) -> Void)?

    let numberField = DemoUnderlineTextField()
    let passwordField = DemoUnderlineTextField()
    let loginButton = UIButton(type: .custom)
    let registerButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 10)

        numberField.font = .systemFont(ofSize: 17)
        numberField.underlineColor = UIColor.separator
        numberField.placeholder = "请输入手机号"
        numberField.leftView = symbolLeftView("phone.fill")
        numberField.leftViewMode = .always
        numberField.clearButtonMode = .whileEditing
        numberField.textColor = .label
        numberField.tintColor = .systemBlue
        numberField.keyboardType = .numberPad
        numberField.backgroundColor = UIColor.secondarySystemBackground
        numberField.layer.cornerRadius = 10
        numberField.layer.masksToBounds = true
        addSubview(numberField)

        passwordField.font = .systemFont(ofSize: 17)
        passwordField.underlineColor = UIColor.separator
        passwordField.placeholder = "请输入密码"
        passwordField.isSecureTextEntry = true
        passwordField.leftView = symbolLeftView("lock.fill")
        passwordField.leftViewMode = .always
        passwordField.clearButtonMode = .whileEditing
        passwordField.textColor = .label
        passwordField.tintColor = .systemBlue
        passwordField.backgroundColor = UIColor.secondarySystemBackground
        passwordField.layer.cornerRadius = 10
        passwordField.layer.masksToBounds = true
        addSubview(passwordField)

        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 12
        loginButton.layer.masksToBounds = true
        loginButton.setTitle("登录", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
        loginButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        loginButton.addTarget(self, action: #selector(loginTap), for: .touchUpInside)
        addSubview(loginButton)

        registerButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        registerButton.setTitle("注册账号", for: .normal)
        registerButton.setTitleColor(.systemBlue, for: .normal)
        registerButton.setTitleColor(.systemBlue.withAlphaComponent(0.6), for: .highlighted)
        registerButton.addTarget(self, action: #selector(registerTap), for: .touchUpInside)
        addSubview(registerButton)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    private func symbolLeftView(_ name: String) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let iv = UIImageView(image: UIImage(systemName: name))
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.frame = CGRect(x: 14, y: 0, width: 18, height: 18)
        iv.center.y = container.bounds.midY
        container.addSubview(iv)
        return container
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = zhh_width - 40
        let height: CGFloat = 44
        let spacing: CGFloat = 12

        numberField.zhh_size = CGSize(width: width, height: height)
        numberField.zhh_y = 20
        numberField.zhh_centerX = zhh_width / 2

        passwordField.zhh_size = numberField.zhh_size
        passwordField.zhh_y = numberField.zhh_bottom + spacing
        passwordField.zhh_centerX = zhh_width / 2

        loginButton.zhh_size = CGSize(width: width, height: 46)
        loginButton.zhh_centerX = zhh_width / 2
        loginButton.zhh_y = passwordField.zhh_bottom + 18

        registerButton.zhh_size = CGSize(width: 70, height: 30)
        registerButton.zhh_y = loginButton.zhh_bottom + 18
        registerButton.zhh_right = zhh_width - 20
    }

    @objc private func loginTap() {
        loginClickedBlock?(self)
    }

    @objc private func registerTap(_ sender: UIButton) {
        nextClickedBlock?(self, sender)
    }
}

final class DemoKeyboardView2: UIView {
    var gobackClickedBlock: ((DemoKeyboardView2, UIButton) -> Void)?
    var nextClickedBlock: ((DemoKeyboardView2, UIButton) -> Void)?

    let titleLabel = UILabel()
    let numberField = DemoUnderlineTextField()
    let codeField = DemoUnderlineTextField()
    let codeButton = UIButton(type: .custom)
    let nextButton = UIButton(type: .custom)
    let gobackButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 16
        layer.shadowOffset = CGSize(width: 0, height: 10)

        titleLabel.text = "注册账号"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        addSubview(titleLabel)

        numberField.font = .systemFont(ofSize: 17)
        numberField.underlineColor = UIColor.separator
        numberField.placeholder = "请输入手机号"
        numberField.clearButtonMode = .whileEditing
        numberField.textColor = .label
        numberField.tintColor = .systemBlue
        numberField.keyboardType = .numberPad
        numberField.backgroundColor = UIColor.secondarySystemBackground
        numberField.layer.cornerRadius = 10
        numberField.layer.masksToBounds = true
        addSubview(numberField)

        codeField.font = .systemFont(ofSize: 17)
        codeField.underlineColor = UIColor.separator
        codeField.placeholder = "请输入验证码"
        codeField.clearButtonMode = .whileEditing
        codeField.textColor = .label
        codeField.tintColor = .systemBlue
        codeField.keyboardType = .numberPad
        codeField.backgroundColor = UIColor.secondarySystemBackground
        codeField.layer.cornerRadius = 10
        codeField.layer.masksToBounds = true
        addSubview(codeField)

        codeButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        codeButton.setTitle("获取验证码", for: .normal)
        codeButton.setTitleColor(.systemBlue, for: .normal)
        codeButton.setTitleColor(.systemBlue.withAlphaComponent(0.6), for: .highlighted)
        addSubview(codeButton)

        nextButton.backgroundColor = .systemBlue
        nextButton.layer.cornerRadius = 12
        nextButton.layer.masksToBounds = true
        nextButton.setTitle("下一步", for: .normal)
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.setTitleColor(.white.withAlphaComponent(0.7), for: .highlighted)
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        nextButton.addTarget(self, action: #selector(nextTap), for: .touchUpInside)
        addSubview(nextButton)

        gobackButton.setTitleColor(.label, for: .normal)
        if let img = UIImage(systemName: "chevron.backward") {
            gobackButton.setImage(img, for: .normal)
        }
        gobackButton.tintColor = .secondaryLabel
        gobackButton.addTarget(self, action: #selector(backTap), for: .touchUpInside)
        addSubview(gobackButton)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let width = zhh_width - 40
        let height: CGFloat = 44
        let spacing: CGFloat = 12

        numberField.zhh_size = CGSize(width: width, height: height)
        numberField.zhh_y = 58
        numberField.zhh_centerX = zhh_width / 2

        codeField.zhh_size = numberField.zhh_size
        codeField.zhh_width /= 2
        codeField.zhh_y = numberField.zhh_bottom + spacing
        codeField.zhh_x = 20

        codeButton.zhh_size = codeField.zhh_size
        codeButton.zhh_y = codeField.zhh_y
        codeButton.zhh_x = codeField.zhh_width + 10

        nextButton.zhh_size = CGSize(width: width, height: 46)
        nextButton.zhh_centerX = zhh_width / 2
        nextButton.zhh_y = codeField.zhh_bottom + 18

        gobackButton.zhh_size = CGSize(width: 30, height: 30)
        gobackButton.frame.origin = CGPoint(x: 20, y: 10)

        titleLabel.zhh_size = CGSize(width: 90, height: 30)
        titleLabel.zhh_y = 10
        titleLabel.zhh_centerX = zhh_width / 2
    }

    @objc private func nextTap(_ sender: UIButton) {
        nextClickedBlock?(self, sender)
    }

    @objc private func backTap(_ sender: UIButton) {
        gobackClickedBlock?(self, sender)
    }
}

final class DemoKeyboardView3: UIView {
    var senderClickedBlock: ((DemoKeyboardView3, UIButton) -> Void)?

    let textField = UITextField()
    let senderButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: 0xFFFFF0)

        textField.font = .systemFont(ofSize: 17)
        textField.placeholder = " 请输入你的评论内容"
        textField.clearButtonMode = .whileEditing
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 4
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.backgroundColor = .lightText
        textField.tintColor = UIColor(hex: 0x569EED)
        addSubview(textField)

        senderButton.setTitle("发送", for: .normal)
        senderButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        senderButton.setTitleColor(.label, for: .normal)
        senderButton.addTarget(self, action: #selector(sendTap), for: .touchUpInside)
        senderButton.imageView?.contentMode = .center
        addSubview(senderButton)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let height = zhh_height - 20
        let padding: CGFloat = 15

        senderButton.zhh_size = CGSize(width: height, height: height)
        senderButton.zhh_right = zhh_width - padding
        senderButton.zhh_centerY = zhh_height / 2

        let spacing: CGFloat = 15
        textField.zhh_height = height
        textField.zhh_width = zhh_width - 2 * padding - senderButton.zhh_width - spacing
        textField.zhh_x = 20
        textField.zhh_centerY = zhh_height / 2
    }

    @objc private func sendTap(_ sender: UIButton) {
        senderClickedBlock?(self, sender)
    }
}
