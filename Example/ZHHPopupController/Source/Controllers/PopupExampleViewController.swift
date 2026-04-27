//
//  PopupExampleViewController.swift
//  ZHHPopupController_Example
//
//  Created by 桃色三岁 on 2025/6/21.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit
import ZHHPopupController

/// Demo 首页：按照 FFPopup 的配置页样式，选择布局/动画/遮罩/交互等参数并展示弹窗
final class PopupExampleViewController: UITableViewController {
    /// 列表行展示模型
    private struct Row {
        let title: String
        let detail: String?
        let showDisclosure: Bool
        let isChecked: Bool
    }

    /// 弹窗位置选项
    private var layoutType: ZHHPopupLayoutType = .center
    /// 展示动画选项
    private var showOption: PopupExampleShowOption = .bounceFromTop
    /// 消失动画选项
    private var dismissOption: PopupExampleDismissOption = .bounceToBottom
    /// 遮罩类型选项
    private var maskOption: PopupExampleMaskOption = .dimmed
    /// 点击背景是否关闭
    private var dismissOnBackgroundTouch: Bool = true
    /// 点击内容是否关闭
    private var dismissOnContentTouch: Bool = false
    /// 是否允许滑动关闭
    private var panGestureEnabled: Bool = false
    /// 是否自动关闭（默认 2 秒）
    private var dismissOutAfterDuration: Bool = false

    init() {
        // 使用圆角分组样式
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Popupup Example"
    }

    /// Section 数量由配置枚举决定
    override func numberOfSections(in tableView: UITableView) -> Int {
        PopupExampleSection.allCases.count
    }

    /// 每个 Section 的行数固定，对应截图里的结构
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let s = PopupExampleSection(rawValue: section) else { return 0 }
        switch s {
        case .layout: return 1
        case .animation: return 2
        case .mask: return 1
        case .background: return 1
        case .content: return 1
        case .gestures: return 1
        case .duration: return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let s = PopupExampleSection(rawValue: section) else { return nil }
        switch s {
        case .layout: return "布局"
        case .animation: return "动画"
        case .mask: return "遮罩"
        case .background: return "背景"
        case .content: return "内容"
        case .gestures: return "交互"
        case .duration: return "时长"
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else { return nil }
        let view = UIView(frame: .zero)
        let label = UILabel(frame: .zero)
        label.text = title
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -18),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        28
    }

    private func row(at indexPath: IndexPath) -> Row {
        // 根据 section/row 生成当前要展示的“标题 + 详情/勾选态”
        let s = PopupExampleSection(rawValue: indexPath.section)!
        switch s {
        case .layout:
            return Row(title: "位置", detail: layoutTypeTitle(layoutType), showDisclosure: true, isChecked: false)
        case .animation:
            if indexPath.row == 0 {
                return Row(title: "展示", detail: showOption.title, showDisclosure: true, isChecked: false)
            }
            return Row(title: "消失", detail: dismissOption.title, showDisclosure: true, isChecked: false)
        case .mask:
            return Row(title: "背景", detail: maskOption.title, showDisclosure: true, isChecked: false)
        case .background:
            return Row(title: "点击背景关闭", detail: nil, showDisclosure: false, isChecked: dismissOnBackgroundTouch)
        case .content:
            return Row(title: "点击内容关闭", detail: nil, showDisclosure: false, isChecked: dismissOnContentTouch)
        case .gestures:
            let supported = supportsPanDismiss(for: layoutType)
            let checked = supported ? panGestureEnabled : false
            let detail = supported ? nil : "仅上下左右支持"
            return Row(title: "滑动关闭", detail: detail, showDisclosure: false, isChecked: checked)
        case .duration:
            return Row(title: "自动关闭（2 秒）", detail: nil, showDisclosure: false, isChecked: dismissOutAfterDuration)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .value1, reuseIdentifier: "cell")
        let r = row(at: indexPath)
        cell.textLabel?.text = r.title
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.text = r.detail
        cell.detailTextLabel?.textColor = .secondaryLabel
        if r.showDisclosure {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = r.isChecked ? .checkmark : .none
        }
        cell.selectionStyle = .default
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 点击不同 section：要么进入选择页，要么直接切换开关
        let s = PopupExampleSection(rawValue: indexPath.section)!
        switch s {
        case .layout:
            pushLayoutType()
        case .animation:
            if indexPath.row == 0 {
                pushShow()
            } else {
                pushDismiss()
            }
        case .mask:
            pushMask()
        case .background:
            dismissOnBackgroundTouch.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .content:
            dismissOnContentTouch.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .gestures:
            guard supportsPanDismiss(for: layoutType) else { return }
            panGestureEnabled.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .duration:
            dismissOutAfterDuration.toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let s = PopupExampleSection(rawValue: section)!
        // 仅最后一组需要展示底部按钮
        return s == .duration ? 110 : 12
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let s = PopupExampleSection(rawValue: section)!
        guard s == .duration else { return UIView(frame: .zero) }
        // 底部展示 “Show Popup” 按钮
        let footer = UIView(frame: .zero)
        let button = UIButton(type: .system)
        button.setTitle("显示弹窗", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(showPopupTapped), for: .touchUpInside)
        footer.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 44),
            button.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 44),
            button.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -44),
            button.bottomAnchor.constraint(equalTo: footer.bottomAnchor, constant: -22)
        ])
        return footer
    }

    @objc private func showPopupTapped() {
        guard let host = view.window ?? view else { return }
        // 构造内容视图（模拟 FFPopup 的示例内容）
        let content = DemoPopupContentView(frame: .zero)
        let scale = UIScreen.main.bounds.width > 0 ? UIScreen.main.bounds.width / 375.0 : 1
        let w = 320.0 * scale
        let h = 360.0 * scale
        content.frame = CGRect(x: 0, y: 0, width: w, height: h)

        // 根据当前配置创建弹窗
        let popup = ZHHPopupController(view: content, size: content.bounds.size)
        content.onClose = { [weak popup] in
            popup?.dismiss()
        }

        popup.layoutType = layoutType // 布局（预置位置）

        updateShowOption(showOption, to: popup) // 动画（展示）
        updateDismissOption(dismissOption, to: popup) // 动画（消失）
        updateMaskOption(maskOption, to: popup) // 遮罩

        popup.dismissOnMaskTouched = dismissOnBackgroundTouch // 交互：点击背景关闭
        popup.dismissOnContentTouched = dismissOnContentTouch // 交互：点击内容关闭
        let allowPan = panGestureEnabled && supportsPanDismiss(for: layoutType)
        popup.panGestureEnabled = allowPan // 交互：滑动关闭（仅上下左右）
        popup.panDismissEnabled = allowPan
        if layoutType == .bottom {
            popup.bottomPanFullScreenEnabled = allowPan
        }
        popup.dismissAfterDelay = dismissOutAfterDuration ? 2.0 : 0 // 自动关闭：2 秒 / 不自动关闭

        let (duration, bounced) = showAnimationParams(showOption)
        popup.show(in: host, duration: duration, bounced: bounced, completion: nil)
    }

    private func supportsPanDismiss(for layout: ZHHPopupLayoutType) -> Bool {
        switch layout {
        case .top, .left, .bottom, .right:
            return true
        case .center, .custom, .aboveCenter, .belowCenter:
            return false
        }
    }

    /// 将 demo 的 show 选项映射到展示时长与是否弹性动画
    private func showAnimationParams(_ option: PopupExampleShowOption) -> (TimeInterval, Bool) {
        switch option {
        case .none:
            return (0, false)
        case .bounceIn, .bounceFromTop, .bounceFromBottom, .bounceFromLeft, .bounceFromRight:
            return (0.35, true)
        default:
            return (0.15, false)
        }
    }

    private func updateShowOption(_ option: PopupExampleShowOption, to popup: ZHHPopupController) {
        // 将 demo 的 show 选项映射到库内部的 presentationStyle / transformScale
        switch option {
        case .none:
            // 无动画：内部用 fade 且把展示时长设为 0（见 showAnimationParams）
            popup.presentationStyle = .fade
        case .fadeIn:
            // 淡入：仅改变透明度
            popup.presentationStyle = .fade
        case .growIn:
            // 放大进入：从较小 scale 过渡到 1
            popup.presentationStyle = .transform
            popup.presentationTransformScale = 0.7
        case .shrinkIn:
            // 缩小进入：从较大 scale 过渡到 1
            popup.presentationStyle = .transform
            popup.presentationTransformScale = 1.25
        case .slideFromTop:
            // 从上滑入：初始位置在屏幕上方
            popup.presentationStyle = .fromTop
        case .slideFromBottom:
            // 从下滑入：初始位置在屏幕下方
            popup.presentationStyle = .fromBottom
        case .slideFromLeft:
            // 从左滑入：初始位置在屏幕左侧
            popup.presentationStyle = .fromLeft
        case .slideFromRight:
            // 从右滑入：初始位置在屏幕右侧
            popup.presentationStyle = .fromRight
        case .bounceIn:
            // 弹性进入：使用 transform，并在展示时开启 bounced
            popup.presentationStyle = .transform
            popup.presentationTransformScale = 0.85
        case .bounceFromTop:
            // 从上弹入：使用 fromTop，并在展示时开启 bounced
            popup.presentationStyle = .fromTop
        case .bounceFromBottom:
            // 从下弹入：使用 fromBottom，并在展示时开启 bounced
            popup.presentationStyle = .fromBottom
        case .bounceFromLeft:
            // 从左弹入：使用 fromLeft，并在展示时开启 bounced
            popup.presentationStyle = .fromLeft
        case .bounceFromRight:
            // 从右弹入：使用 fromRight，并在展示时开启 bounced
            popup.presentationStyle = .fromRight
        }
    }

    private func updateDismissOption(_ option: PopupExampleDismissOption, to popup: ZHHPopupController) {
        // 将 demo 的 dismiss 选项映射到库内部的 dismissalStyle / dismissBounced / transformScale
        popup.dismissBounced = false
        switch option {
        case .none:
            // 无动画：内部用 fade 且把关闭时长设为 0（外部走默认 dismiss 时长时可自行调整）
            popup.dismissalStyle = .fade
        case .fadeOut:
            // 淡出：仅改变透明度
            popup.dismissalStyle = .fade
        case .growOut:
            // 放大退出：从 1 过渡到较大 scale
            popup.dismissalStyle = .transform
            popup.dismissalTransformScale = 1.25
        case .shrinkOut:
            // 缩小退出：从 1 过渡到较小 scale
            popup.dismissalStyle = .transform
            popup.dismissalTransformScale = 0.75
        case .slideToTop:
            // 向上滑出：结束位置在屏幕上方
            popup.dismissalStyle = .fromTop
        case .slideToBottom:
            // 向下滑出：结束位置在屏幕下方
            popup.dismissalStyle = .fromBottom
        case .slideToLeft:
            // 向左滑出：结束位置在屏幕左侧
            popup.dismissalStyle = .fromLeft
        case .slideToRight:
            // 向右滑出：结束位置在屏幕右侧
            popup.dismissalStyle = .fromRight
        case .bounceOut:
            // 弹性退出：使用 transform，并在关闭时开启 dismissBounced
            popup.dismissalStyle = .transform
            popup.dismissalTransformScale = 0.85
            popup.dismissBounced = true
        case .bounceToTop:
            // 向上弹出：使用 fromTop，并在关闭时开启 dismissBounced
            popup.dismissalStyle = .fromTop
            popup.dismissBounced = true
        case .bounceToBottom:
            // 向下弹出：使用 fromBottom，并在关闭时开启 dismissBounced
            popup.dismissalStyle = .fromBottom
            popup.dismissBounced = true
        case .bounceToLeft:
            // 向左弹出：使用 fromLeft，并在关闭时开启 dismissBounced
            popup.dismissalStyle = .fromLeft
            popup.dismissBounced = true
        case .bounceToRight:
            // 向右弹出：使用 fromRight，并在关闭时开启 dismissBounced
            popup.dismissalStyle = .fromRight
            popup.dismissBounced = true
        }
    }

    private func updateMaskOption(_ option: PopupExampleMaskOption, to popup: ZHHPopupController) {
        // 将 demo 的遮罩选项映射到库内部 maskType
        switch option {
        case .none:
            // 无遮罩：允许背景交互（触摸可穿透）
            popup.maskType = .none
        case .clear:
            // 透明遮罩：不改变背景视觉，但拦截背景触摸
            popup.maskType = .clear
        case .dimmed:
            // 变暗遮罩：背景变暗并拦截触摸
            popup.maskType = .blackOpacity
            popup.maskAlpha = 0.5
        case .darkBlur:
            // 深色毛玻璃：拦截触摸
            popup.maskType = .darkBlur
        case .lightBlur:
            // 浅色毛玻璃：拦截触摸
            popup.maskType = .lightBlur
        case .extraLightBlur:
            // 超浅毛玻璃：拦截触摸
            popup.maskType = .extraLightBlur
        case .white:
            // 纯白遮罩：拦截触摸
            popup.maskType = .white
        }
    }

    private func pushLayoutType() {
        // 进入弹窗位置选择页（单一布局枚举）
        let options: [(String, ZHHPopupLayoutType)] = [
            ("顶部", .top),
            ("底部", .bottom),
            ("左侧", .left),
            ("右侧", .right),
            ("居中", .center),
            ("偏上", .aboveCenter),
            ("偏下", .belowCenter),
            ("自定义", .custom)
        ]
        let vc = PopupOptionSelectionViewController(
            titleText: "位置",
            options: options.map { $0.0 },
            selectedIndex: options.firstIndex(where: { $0.1 == layoutType }) ?? 4
        ) { [weak self] idx in
            self?.layoutType = options[idx].1
            self?.tableView.reloadSections(IndexSet(integer: PopupExampleSection.layout.rawValue), with: .automatic)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushShow() {
        // 进入展示动画选择页
        let options = PopupExampleShowOption.allCases
        let vc = PopupOptionSelectionViewController(
            titleText: "展示动画",
            options: options.map { $0.title },
            selectedIndex: options.firstIndex(of: showOption) ?? 0
        ) { [weak self] idx in
            self?.showOption = options[idx]
            self?.tableView.reloadSections(IndexSet(integer: PopupExampleSection.animation.rawValue), with: .automatic)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushDismiss() {
        // 进入消失动画选择页
        let options = PopupExampleDismissOption.allCases
        let vc = PopupOptionSelectionViewController(
            titleText: "消失动画",
            options: options.map { $0.title },
            selectedIndex: options.firstIndex(of: dismissOption) ?? 0
        ) { [weak self] idx in
            self?.dismissOption = options[idx]
            self?.tableView.reloadSections(IndexSet(integer: PopupExampleSection.animation.rawValue), with: .automatic)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func pushMask() {
        // 进入遮罩选择页
        let options = PopupExampleMaskOption.allCases
        let vc = PopupOptionSelectionViewController(
            titleText: "遮罩",
            options: options.map { $0.title },
            selectedIndex: options.firstIndex(of: maskOption) ?? 0
        ) { [weak self] idx in
            self?.maskOption = options[idx]
            self?.tableView.reloadSections(IndexSet(integer: PopupExampleSection.mask.rawValue), with: .automatic)
        }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func layoutTypeTitle(_ type: ZHHPopupLayoutType) -> String {
        // 当前选中项的详情文案
        switch type {
        case .top: return "顶部"
        case .bottom: return "底部"
        case .left: return "左侧"
        case .right: return "右侧"
        case .center: return "居中"
        case .aboveCenter: return "偏上"
        case .belowCenter: return "偏下"
        case .custom: return "自定义"
        }
    }
}
