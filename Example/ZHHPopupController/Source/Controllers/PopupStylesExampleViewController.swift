//
//  PopupStylesExampleViewController.swift
//  ZHHPopupController_Example
//
//  Created by 桃色三岁 on 2025/6/21.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 样式示例页：复用 `PopupExampleViewModel` 的 5 个内置弹窗示例，点击行即可展示对应效果
final class PopupStylesExampleViewController: UITableViewController {
    /// 示例数据与弹窗构建逻辑集中在 ViewModel 内
    private lazy var viewModel: PopupExampleViewModel = {
        let vm = PopupExampleViewModel(hostViewProvider: { [weak self] in
            // 作为弹窗承载视图：优先使用 window（覆盖整屏），否则退化为当前 view
            self?.view.window ?? self?.view
        })
        vm.onStatusBarLightChanged = { [weak self] isLight in
            // 某些示例需要切换状态栏颜色（例如顶部幕布）
            self?.isStatusBarLight = isLight
        }
        return vm
    }()

    /// 是否使用浅色状态栏（由示例 2 在展示/消失时触发）
    private var isStatusBarLight: Bool = false {
        didSet {
            if oldValue != isStatusBarLight {
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    /// 统一由 `isStatusBarLight` 控制状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        isStatusBarLight ? .lightContent : .default
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "样式示例"
    }

    /// 行数与示例项数量一致
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    /// 仅展示标题，不需要详情/选择页
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = viewModel.items[indexPath.row].title
        cell.textLabel?.textColor = .label
        cell.accessoryType = .none
        return cell
    }

    /// 点击行后，直接展示对应示例弹窗
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let host = view.window ?? view else { return }
        viewModel.show(at: indexPath.row, in: host)
    }
}
