//
//  DemoFlopPopupView.swift
//  ZHHPopupController_Example
//

import UIKit
import SnapKit

final class DemoFlopPopupView: UIView {
    var onClose: (() -> Void)?

    private var isFlopped: Bool = false

    private lazy var topImageView: UIImageView = {
        let v = UIImageView(image: UIImage(named: "ic_flop_card_top"))
        v.contentMode = .scaleAspectFit
        return v
    }()

    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "ic_popup_close"), for: .normal)
        b.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        return b
    }()

    private lazy var leftCard: TwoSidedView = makeCard()
    private lazy var middleCard: TwoSidedView = makeCard()
    private lazy var rightCard: TwoSidedView = makeCard()

    private var selectedCardConstraints: (width: Constraint?, height: Constraint?) = (nil, nil)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        addSubview(topImageView)
        addSubview(leftCard)
        addSubview(middleCard)
        addSubview(rightCard)
        addSubview(closeButton)

        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(227.5)
            make.width.equalTo(245)
            make.height.equalTo(111)
        }

        let screenWidth = UIScreen.main.bounds.width
        let cardWidth = floor(screenWidth / 3.0)
        let cardHeight = 358.0 / 297.0 * cardWidth

        leftCard.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom)
            make.width.equalTo(cardWidth)
            make.height.equalTo(cardHeight)
        }
        middleCard.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(leftCard)
            make.width.equalTo(cardWidth)
            make.height.equalTo(cardHeight)
        }
        rightCard.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.equalTo(leftCard)
            make.width.equalTo(cardWidth)
            make.height.equalTo(cardHeight)
        }

        closeButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topImageView.snp.bottom).offset(272.5)
            make.size.equalTo(32)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    @objc private func closeTapped() {
        onClose?()
    }

    private func makeCard() -> TwoSidedView {
        let card = TwoSidedView()

        let back = UIImageView(image: UIImage(named: "ic_flop_card_back"))
        back.contentMode = .scaleAspectFit
        card.topView = back

        let prize = PrizeView()
        card.bottomView = prize

        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        card.addGestureRecognizer(tap)
        return card
    }

    @objc private func cardTapped(_ tap: UITapGestureRecognizer) {
        guard let card = tap.view as? TwoSidedView, !isFlopped else { return }
        isFlopped = true

        UIView.animate(withDuration: 0.35) {
            self.topImageView.alpha = 0
            self.leftCard.alpha = self.leftCard === card ? 1 : 0
            self.middleCard.alpha = self.middleCard === card ? 1 : 0
            self.rightCard.alpha = self.rightCard === card ? 1 : 0
        }

        card.snp.updateConstraints { make in
            selectedCardConstraints.width = make.width.equalTo(274).constraint
            selectedCardConstraints.height = make.height.equalTo(324 + 40.5 + 17.5).constraint
        }
        setNeedsLayout()
        layoutIfNeeded()

        UIView.animate(withDuration: 1.0) {
            card.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(182.5)
                make.width.equalTo(274)
                make.height.equalTo(324 + 40.5 + 17.5)
            }
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }

        card.transition(withDuration: 1.0, completion: nil)
    }
}

private final class PrizeView: UIView {
    private lazy var imageView: UIImageView = {
        let v = UIImageView(image: UIImage(named: "ic_flop_prize_envelope"))
        v.contentMode = .scaleAspectFit
        return v
    }()

    private lazy var numberImageView: UIImageView = {
        let v = UIImageView(image: UIImage(named: "ic_flop_number_2"))
        v.contentMode = .scaleAspectFit
        return v
    }()

    private lazy var titleLabel: UILabel = {
        let l = UILabel()
        l.text = "商品需要2人助力即可免费获得"
        l.font = .systemFont(ofSize: 14.5)
        l.textColor = UIColor(hexString: "#FFFFFF")
        return l
    }()

    private lazy var bottomButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "ic_flop_action_button"), for: .normal)
        b.adjustsImageWhenHighlighted = false
        b.isUserInteractionEnabled = false
        return b
    }()

    private lazy var bottomIcon: UIImageView = {
        let v = UIImageView(image: UIImage(named: "ic_flop_share"))
        v.contentMode = .scaleAspectFit
        return v
    }()

    private lazy var bottomLabel: UILabel = {
        let l = UILabel()
        l.text = "邀请好友助力"
        l.textColor = UIColor(hexString: "#F90815")
        l.font = .systemFont(ofSize: 13)
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        imageView.addSubview(numberImageView)
        imageView.addSubview(titleLabel)
        addSubview(bottomButton)
        bottomButton.addSubview(bottomIcon)
        bottomButton.addSubview(bottomLabel)

        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalTo(247)
            make.height.equalTo(324)
        }

        numberImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-38.5)
        }

        bottomButton.snp.makeConstraints { make in
            make.centerX.bottom.equalToSuperview()
            make.width.equalTo(208)
            make.height.equalTo(35)
        }

        bottomIcon.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(60)
            make.centerY.equalToSuperview()
            make.size.equalTo(16)
        }

        bottomLabel.snp.makeConstraints { make in
            make.left.equalTo(bottomIcon.snp.right).offset(6)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:)") }
}

private final class TwoSidedView: UIView {
    var topView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let v = topView {
                addSubview(v)
                setNeedsLayout()
            }
        }
    }

    var bottomView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            setNeedsLayout()
        }
    }

    private var isTurning: Bool = false
    private var isReversed: Bool = false

    func transition(withDuration duration: TimeInterval, completion: (() -> Void)?) {
        guard !isTurning, let top = topView, let bottom = bottomView else { return }
        isTurning = true
        if isReversed {
            UIView.transition(from: bottom, to: top, duration: duration, options: .transitionFlipFromLeft) { _ in
                completion?()
                self.isTurning = false
                self.isReversed = false
            }
        } else {
            UIView.transition(from: top, to: bottom, duration: duration, options: .transitionFlipFromRight) { _ in
                completion?()
                self.isTurning = false
                self.isReversed = true
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        topView?.frame = bounds
        bottomView?.frame = bounds
    }
}

