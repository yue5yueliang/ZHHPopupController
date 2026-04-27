//
//  PopupExampleViewModel.swift
//  ZHHPopupController_Example
//

import UIKit
import ZHHPopupController

final class PopupExampleViewModel {
    var hostViewProvider: (() -> UIView?)
    var onStatusBarLightChanged: ((Bool) -> Void)?

    private(set) var items: [PopupExampleItem] = (1 ... 8).map { PopupExampleItem(title: "样式示例 - \($0)") }

    private lazy var popupController1: ZHHPopupController = makePopup1()
    private lazy var popupController2: ZHHPopupController = makePopup2()
    private lazy var popupController3: ZHHPopupController = makePopup3()
    private lazy var popupController4: ZHHPopupController = makePopup4()
    private lazy var popupController5: ZHHPopupController = makePopup5()
    private lazy var popupController6: ZHHPopupController = makePopup6()
    private lazy var popupController7: ZHHPopupController = makePopup7()
    private lazy var popupController8: ZHHPopupController = makePopup8()

    private lazy var keyboardView1: DemoKeyboardView = makeKeyboardView1()
    private lazy var keyboardView2: DemoKeyboardView2 = makeKeyboardView2()

    init(hostViewProvider: @escaping (() -> UIView?)) {
        self.hostViewProvider = hostViewProvider
    }

    func show(at index: Int, in window: UIView) {
        switch index {
        case 0:
            popupController1.show(in: window, completion: nil)
        case 1:
            popupController2.show(in: window, duration: 0.75, bounced: true, completion: nil)
        case 2:
            popupController3.show(in: window, completion: nil)
        case 3:
            popupController4.show(in: window, duration: 0.25, completion: nil)
        case 4:
            popupController5.show(in: window, completion: nil)
        case 5:
            popupController6.show(in: window, completion: nil)
        case 6:
            popupController7.show(in: window, completion: nil)
        case 7:
            popupController8.show(in: window, duration: 0.2, completion: nil)
        default:
            break
        }
    }

    // MARK: - 示例 1：底部弹出 Overfly

    private func makePopup1() -> ZHHPopupController {
        var pcHolder: ZHHPopupController?
        let card = DemoUpdatePopupView(frame: CGRect(x: 0, y: 0, width: 312, height: 360))
        let content = card.makeContainerWithClose(spacing: 16)

        let pc = ZHHPopupController(view: content, size: CGSize(width: 312, height: 360 + 16 + 44))
        pcHolder = pc

        card.onClose = { [weak pcHolder] in
            pcHolder?.dismiss()
        }
        card.onUpdate = { [weak pcHolder] in
            pcHolder?.dismiss()
        }

        pc.maskType = .blackOpacity
        pc.maskAlpha = 0.4
        pc.layoutType = .center
        pc.presentationStyle = .fromBottom
        pc.dismissalStyle = .fromBottom
        pc.dismissOnMaskTouched = true
        return pc
    }

    // MARK: - 示例 2：顶部幕布 + 状态栏

    private func makePopup2() -> ZHHPopupController {
        let curtain = makeCurtainView()
        let pc = ZHHPopupController(view: curtain, size: curtain.bounds.size)
        pc.layoutType = .top
        pc.presentationStyle = .fromTop
        pc.offsetSpacing = -30
        pc.willPresentBlock = { [weak self] _ in
            self?.onStatusBarLightChanged?(true)
        }
        pc.willDismissBlock = { [weak self] _ in
            self?.onStatusBarLightChanged?(false)
        }
        return pc
    }

    private func makeCurtainView() -> DemoCurtainView {
        let curtain = DemoCurtainView()
        let w: CGFloat
        let top: CGFloat
        if let host = hostViewProvider() {
            w = host.bounds.width > 0 ? host.bounds.width : UIScreen.main.bounds.width
            top = host.safeAreaInsets.top
        } else {
            w = UIScreen.main.bounds.width
            top = 0
        }
        let h = 300 + top
        curtain.frame = CGRect(x: 0, y: 0, width: w, height: h)
        return curtain
    }

    // MARK: - 示例 3：左侧抽屉

    private func makePopup3() -> ZHHPopupController {
        let sidebar = makeSidebarView()
        let pc = ZHHPopupController(view: sidebar, size: sidebar.bounds.size)
        pc.layoutType = .left
        pc.presentationStyle = .fromLeft
        pc.panGestureEnabled = true
        pc.panDismissRatio = 0.5
        return pc
    }

    private func makeSidebarView() -> DemoSidebarView {
        let sidebar = DemoSidebarView()
        let b = UIScreen.main.bounds
        sidebar.frame = CGRect(origin: .zero, size: CGSize(width: b.width - 90, height: b.height))
        sidebar.backgroundColor = UIColor(red: 24 / 255, green: 28 / 255, blue: 45 / 255, alpha: 0.8)
        return sidebar
    }

    // MARK: - 示例 4：键盘联动 + 双面板切换

    private func makeKeyboardView1() -> DemoKeyboardView {
        let v = DemoKeyboardView(frame: CGRect(x: 0, y: 0, width: 300, height: 236))
        v.loginClickedBlock = { [weak self] _ in
            self?.popupController4.dismiss()
        }
        v.nextClickedBlock = { [weak self] _, _ in
            guard let self else { return }
            UIView.transition(with: self.popupController4.contentView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                self.popupController4.contentView.addSubview(self.keyboardView2)
                self.keyboardView2.numberField.becomeFirstResponder()
            }, completion: { _ in
                if v.superview != nil {
                    v.removeFromSuperview()
                }
            })
        }
        return v
    }

    private func makeKeyboardView2() -> DemoKeyboardView2 {
        let v = DemoKeyboardView2(frame: CGRect(x: 0, y: 0, width: 300, height: 236))
        v.gobackClickedBlock = { [weak self] kb, _ in
            guard let self else { return }
            UIView.transition(with: self.popupController4.contentView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                self.popupController4.contentView.addSubview(self.keyboardView1)
                self.keyboardView1.numberField.becomeFirstResponder()
            }, completion: { _ in
                if kb.superview != nil {
                    kb.removeFromSuperview()
                }
            })
        }
        v.nextClickedBlock = { [weak self] _, _ in
            self?.keyboardView1.numberField.resignFirstResponder()
            self?.keyboardView2.numberField.resignFirstResponder()
        }
        return v
    }

    private func makePopup4() -> ZHHPopupController {
        let back = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 236))
        back.addSubview(keyboardView1)

        let pc = ZHHPopupController(view: back, size: back.bounds.size)
        pc.maskType = .blackOpacity
        pc.layoutType = .center
        pc.presentationStyle = .fromBottom
        pc.keyboardOffsetSpacing = 50
        pc.keyboardChangeFollowed = true
        pc.syncFirstResponderWithPresentation = true

        pc.willPresentBlock = { [weak self] _ in
            self?.keyboardView1.numberField.becomeFirstResponder()
        }
        pc.willDismissBlock = { [weak self] _ in
            guard let self else { return }
            if self.keyboardView1.numberField.isFirstResponder {
                self.keyboardView1.numberField.resignFirstResponder()
            }
            if self.keyboardView2.numberField.isFirstResponder {
                self.keyboardView2.numberField.resignFirstResponder()
            }
        }
        return pc
    }

    // MARK: - 示例 5：底部输入条

    private func makePopup5() -> ZHHPopupController {
        let width: CGFloat
        if let host = hostViewProvider() {
            width = host.bounds.width > 0 ? host.bounds.width : UIScreen.main.bounds.width
        } else {
            width = UIScreen.main.bounds.width
        }
        let rect = CGRect(x: 0, y: 0, width: width, height: 60)
        let kb = DemoKeyboardView3(frame: rect)
        kb.senderClickedBlock = { [weak self] _, _ in
            self?.popupController5.dismiss()
        }
        let pc = ZHHPopupController(view: kb, size: kb.bounds.size)
        pc.maskType = .darkBlur
        pc.layoutType = .bottom
        pc.presentationStyle = .fromBottom
        pc.syncFirstResponderWithPresentation = true
        pc.keyboardChangeFollowed = true
        pc.willPresentBlock = { _ in
            kb.textField.becomeFirstResponder()
        }
        pc.willDismissBlock = { _ in
            kb.textField.resignFirstResponder()
        }
        return pc
    }

    // MARK: - 示例 6：底部弹出（可下拉关闭）

    private func makePopup6() -> ZHHPopupController {
        var pcHolder: ZHHPopupController?

        let content = DemoPopupContentView(frame: .zero)
        let w = UIScreen.main.bounds.width
        let h: CGFloat = 440
        content.frame = CGRect(x: 0, y: 0, width: w, height: h)
        content.layer.cornerRadius = 12
        content.layer.masksToBounds = true

        let pc = ZHHPopupController(view: content, size: content.bounds.size)
        pcHolder = pc
        content.onClose = { [weak pcHolder] in
            pcHolder?.dismiss()
        }

        pc.maskType = .blackOpacity
        pc.maskAlpha = 0.5
        pc.layoutType = .bottom
        pc.presentationStyle = .fromBottom
        pc.dismissalStyle = .fromBottom
        pc.dismissOnMaskTouched = true
        pc.panGestureEnabled = true
        pc.panDismissEnabled = true
        pc.bottomPanFullScreenEnabled = true
        pc.panDismissRatio = 0.35
        return pc
    }

    // MARK: - 示例 7：翻牌弹窗

    private func makePopup7() -> ZHHPopupController {
        var pcHolder: ZHHPopupController?

        let b = UIScreen.main.bounds
        let content = DemoFlopPopupView(frame: b)

        let pc = ZHHPopupController(view: content, size: content.bounds.size)
        pcHolder = pc
        content.onClose = { [weak pcHolder] in
            pcHolder?.dismiss()
        }

        pc.maskType = .blackOpacity
        pc.maskAlpha = 0.4
        pc.layoutType = .center
        pc.presentationStyle = .fromBottom
        pc.dismissalStyle = .fromBottom
        pc.dismissOnMaskTouched = true
        return pc
    }

    // MARK: - 示例 8：可拖拽半开/全开面板

    private func makePopup8() -> ZHHPopupController {
        let w = UIScreen.main.bounds.width - 16
        let h = UIScreen.main.bounds.height - 120
        let content = DemoMomentumView(frame: CGRect(x: 0, y: 0, width: w, height: h))

        let pc = ZHHPopupController(view: content, size: content.bounds.size)
        pc.maskType = .blackOpacity
        pc.maskAlpha = 0.35
        pc.layoutType = .bottom
        pc.presentationStyle = .fromBottom
        pc.dismissalStyle = .fromBottom
        pc.dismissOnMaskTouched = true
        pc.panGestureEnabled = false
        pc.willPresentBlock = { controller in
            guard let momentumView = controller.contentView as? DemoMomentumView else { return }
            momentumView.onDismiss = { [weak controller] in
                controller?.dismiss()
            }
            momentumView.dismissTransform = .init(translationX: 0, y: momentumView.bounds.height)
            momentumView.closedTransform = .init(translationX: 0, y: momentumView.bounds.height)
        }
        pc.didPresentBlock = { controller in
            guard let momentumView = controller.contentView as? DemoMomentumView else { return }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
                momentumView.closedTransform = .init(translationX: 0, y: momentumView.bounds.height * 0.6)
            } completion: { _ in }
        }
        return pc
    }
}
