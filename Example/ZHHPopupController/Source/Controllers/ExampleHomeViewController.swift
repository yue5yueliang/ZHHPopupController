//
//  ExampleHomeViewController.swift
//  ZHHPopupController_Example
//
//  Created by 桃色三岁 on 2025/6/21.
//  Copyright © 2025 桃色三岁. All rights reserved.
//

import UIKit

final class ExampleHomeViewController: UITableViewController {
    private enum Row: Int, CaseIterable {
        case config
        case styles

        var title: String {
            switch self {
            case .config: return "配置示例"
            case .styles: return "样式示例"
            }
        }
    }

    init() {
        super.init(style: .insetGrouped)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ZHHPopupController"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Row.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let r = Row(rawValue: indexPath.row)!
        cell.textLabel?.text = r.title
        cell.textLabel?.textColor = .label
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let r = Row(rawValue: indexPath.row)!
        switch r {
        case .config:
            navigationController?.pushViewController(PopupExampleViewController(), animated: true)
        case .styles:
            navigationController?.pushViewController(PopupStylesExampleViewController(), animated: true)
        }
    }
}
