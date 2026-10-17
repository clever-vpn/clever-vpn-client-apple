//
//  RegionSelectionView.swift
//  VpnUi
//
//  地区选择：仿系统「设置 → 语言」的形态 —— **可滚动的分组列表**（按大洲分组），
//  点选即生效并返回，当前项带勾选。所以内置列表再长（现在 31 项）都不怕。
//
//  为什么不用 `Picker`：`Picker` 的默认样式会随系统版本/平台漂移（iOS 上可能变成弹菜单），
//  而且分组标题能不能渲染要看样式实现；这里用 `List` + `Section` 自己画，行为确定。
//

import SwiftUI
import CleverVpnKit

struct RegionSelectionView: View {
    let selectedCode: String
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query = ""

    var body: some View {
        List {
            ForEach(sections) { section in
                Section {
                    ForEach(section.options) { option in
                        row(option)
                    }
                } header: {
                    Text(LocalizedStringKey(section.group.titleKey))
                }
            }
        }
        .searchable(text: $query)
        .navigationTitle("Region")
    }

    /// 按大洲分组（搜索时只保留命中的项）。当前值不在内置列表里（自定义代码）时，
    /// 额外补一段「Custom」，保证列表里总能勾出当前值。
    private var sections: [SplitRegionSection] {
        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var result: [SplitRegionSection] = []

        for section in SplitRegionOptions.sections {
            let options = keyword.isEmpty
                ? section.options
                : section.options.filter { matches($0, keyword) }
            if !options.isEmpty {
                result.append(SplitRegionSection(group: section.group, options: options))
            }
        }

        let current = SplitRegionOptions.option(for: selectedCode)
        let isListed = result.contains { section in
            section.options.contains { $0.code == current.code }
        }
        if current.group == .custom, !isListed, keyword.isEmpty || matches(current, keyword) {
            result.append(SplitRegionSection(group: .custom, options: [current]))
        }

        return result
    }

    /// 搜索按「地区代码 + 英文名」匹配（列表里只显示「🇯🇵  jp」，不塞英文名）。
    private func matches(_ option: SplitRegionOption, _ keyword: String) -> Bool {
        option.code.contains(keyword) || option.name.lowercased().contains(keyword)
    }

    @ViewBuilder
    private func row(_ option: SplitRegionOption) -> some View {
        HStack {
            Text(option.label)
            Spacer()
            if option.code == SplitRegionOptions.option(for: selectedCode).code {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(option.code)
            // 真实 NavigationLink（iOS 16+/macOS 13+）下 dismiss 就是返回上一级；
            // 老系统的自定义栈里 dismiss 无效，用户点系统返回键即可（值已生效）。
            dismiss()
        }
    }
}
