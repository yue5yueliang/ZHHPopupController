//
//  PopupOptionSelectionViewController.swift
//  ZHHPopupController_Example
//
//  Created by 桃色三岁 on 2025/6/21.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

/// 通用的“单选列表”页面：展示一组字符串选项，选中后回调并返回上一页
final class PopupOptionSelectionViewController: UITableViewController {
    /// 展示的选项文案
    private let options: [String]
    /// 当前选中行
    private var selectedIndex: Int
    /// 选中回调（把选中下标回传给上层页面）
    private let onSelected: (Int) -> Void

    init(titleText: String, options: [String], selectedIndex: Int, onSelected: @escaping (Int) -> Void) {
        self.options = options
        self.selectedIndex = selectedIndex
        self.onSelected = onSelected
        super.init(style: .insetGrouped)
        title = titleText
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = options[indexPath.row]
        // 通过勾选样式体现当前选中项
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 更新选中态并刷新列表
        selectedIndex = indexPath.row
        tableView.reloadData()
        // 通知上层更新配置，然后返回
        onSelected(indexPath.row)
        navigationController?.popViewController(animated: true)
    }
}

