//
//  SplitSettingsView.swift
//  VpnUi
//
//  Created by GitHub Copilot on 2026/3/23.
//

import CleverVpnKit
import SwiftUI

struct SplitSettingsView: View {
    private enum EditorField: Hashable {
        case ipRules
        case domainRules
        case domainRegex
    }

    @EnvironmentObject var cleverVPNModel: VPNClient
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var focusedField: EditorField?

    @State private var regionEnabled = false
    @State private var regionCode = ""
    @State private var regionCustomCode = ""

    @State private var ipEnabled = false
    @State private var ipCidrText = ""

    @State private var domainEnabled = false
    @State private var domainBasicText = ""
    @State private var domainRegexText = ""
    @State private var showDomainAdvanced = false

    @State private var didLoad = false
    @State private var initialSplitSignature = ""

    var body: some View {
        Form {
            Section {
                Toggle("Enable region split", isOn: $regionEnabled)
                    .onChange(of: regionEnabled) { enabled in
                        // 开启时地区必须有一个值：没有就落缺省（cn）。已有值保留用户的。
                        if enabled, SplitRegionOptions.normalized(regionCode) == nil {
                            regionCode = SplitRegionOptions.defaultCode
                        }
                    }

                // 选择控件只在开启时才显示：关闭状态下"选地区"没有意义，
                // 少两行也更不容易让人以为已经生效（值仍然保留在 userInfo 里，不会丢）。
                if regionEnabled {
                    // 一行当前值，点进去是「设置 → 语言」那种可滚动的分组列表。
                    NavigationLinkEx(destination: RegionSelectionView(selectedCode: regionCode) { code in
                        regionCode = code
                    }) {
                        HStack {
                            Text("Region")
                            Spacer()
                            Text(SplitRegionOptions.label(for: regionCode))
                                .foregroundColor(.gray)
                        }
                    }

                    HStack {
                        TextField("Custom code (e.g. us)", text: $regionCustomCode)
                            .onSubmit(applyCustomRegionCode)
                        Button("Use", action: applyCustomRegionCode)
                            .disabled(SplitRegionOptions.normalized(regionCustomCode) == nil)
                    }
                }
            } header: {
                Text("Region")
            } footer: {
                Text("Traffic to the selected region goes direct and everything else goes through the tunnel. Pick the region you are currently in, not the one you want to appear in. Turn it off if unsure.")
            }

            Section("IP Rules") {
                Toggle("Enable IP split", isOn: $ipEnabled)
                ruleEditor(
                    title: "IP CIDR List",
                    hint: "One item per line, for example: 10.0.0.0/8",
                    placeholder: "10.0.0.0/8\n192.168.0.0/16",
                    field: .ipRules,
                    text: $ipCidrText
                )
            }

            Section("Domain Rules") {
                Toggle("Enable domain split", isOn: $domainEnabled)
                ruleEditor(
                    title: "Domain & Suffix Rules",
                    hint: "One item per line. Use .example.com for suffix, api.example.com for exact domain.",
                    placeholder: ".example.com\napi.example.com",
                    field: .domainRules,
                    text: $domainBasicText
                )

                DisclosureGroup("Advanced Settings", isExpanded: $showDomainAdvanced) {
                    ruleEditor(
                        title: "Domain Regex",
                        hint: "One regex per line. example: ^stun\\\\..+",
                        placeholder: "^stun\\..+",
                        field: .domainRegex,
                        text: $domainRegexText
                    )
                }
            }
        }
        .modifier(FormModifier())
        .navigationTitle("Split Routing")
        .onAppear {
            loadSplitInfoIfNeeded()
        }
        .onReceive(cleverVPNModel.$userInfo) { _ in
            loadSplitInfoIfNeeded()
        }
        .onDisappear {
            saveSplitInfoIfNeeded()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                saveSplitInfoIfNeeded()
            }
        }
    }

    @ViewBuilder
    private func ruleEditor(
        title: LocalizedStringKey,
        hint: LocalizedStringKey,
        placeholder: String,
        field: EditorField,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .bold()
            Text(hint)
                .font(.caption)
                .foregroundColor(.gray)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(editorBackgroundColor)

                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }

                editorTextView(text: text, field: field)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(focusedField == field ? Color.accentColor : Color.gray.opacity(0.2), lineWidth: focusedField == field ? 1.5 : 1)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = field
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func editorTextView(text: Binding<String>, field: EditorField) -> some View {
        if #available(iOS 16, macOS 13, *) {
            TextEditor(text: text)
                .focused($focusedField, equals: field)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 108)
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .font(.system(.body, design: .monospaced))
                .background(Color.clear)
        } else {
            TextEditor(text: text)
                .focused($focusedField, equals: field)
                .frame(minHeight: 108)
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .font(.system(.body, design: .monospaced))
                .background(Color.clear)
        }
    }

    /// 手动输入的地区代码（内置列表之外的值，例如 `ua`）。
    private func applyCustomRegionCode() {
        guard let code = SplitRegionOptions.normalized(regionCustomCode) else {
            return
        }
        regionCode = code
        regionCustomCode = ""
    }

    private func loadSplitInfoIfNeeded() {
        if didLoad {
            return
        }

        if let splitInfo = cleverVPNModel.userInfo?.splitInfo {
            apply(splitInfo: splitInfo)
            initialSplitSignature = currentSplitSignature()
            didLoad = true
        }
    }

    private func apply(splitInfo: Split) {
        regionEnabled = splitInfo.region.enable
        // region 代码**永远不为空**：落盘值是空/非法时，界面上直接显示缺省值。
        regionCode = SplitRegionOptions.normalized(splitInfo.region.code) ?? SplitRegionOptions.defaultCode
        regionCustomCode = ""

        ipEnabled = splitInfo.ip.enable
        ipCidrText = splitInfo.ip.ipCidr.joined(separator: "\n")

        domainEnabled = splitInfo.domain.enable
        domainBasicText = mergeDomainRules(domain: splitInfo.domain.domain, domainSuffix: splitInfo.domain.domainSuffix)
        domainRegexText = splitInfo.domain.domainRegex.joined(separator: "\n")
    }

    private func saveSplitInfo() {
        let (domainRules, domainSuffixRules) = splitDomainBasicRules(parseRules(domainBasicText))

        // region：**永远写一个合法值**（空/非法 ⇒ 缺省 cn）。
        // `enable=true` + 空 code 会让引擎去装配名为 `geoip-` 的垃圾规则集（URL 404），
        // 所以这里不做"没选地区就不算开启"的隐式降级，而是把值补成缺省。
        let normalizedRegionCode = SplitRegionOptions.normalized(regionCode) ?? SplitRegionOptions.defaultCode

        let splitInfo = Split(
            region: Region(
                enable: regionEnabled,
                code: normalizedRegionCode
            ),
            ip: IpRule(enable: ipEnabled, ipCidr: parseRules(ipCidrText)),
            domain: DomainRule(
                enable: domainEnabled,
                domain: domainRules,
                domainSuffix: domainSuffixRules,
                domainRegex: parseRules(domainRegexText)
            )
        )

        cleverVPNModel.updateSplitInfo(splitInfo: splitInfo)
    }

    private func saveSplitInfoIfNeeded() {
        guard didLoad else {
            return
        }

        let currentSignature = currentSplitSignature()
        guard currentSignature != initialSplitSignature else {
            return
        }

        saveSplitInfo()
        initialSplitSignature = currentSignature
    }

    private func currentSplitSignature() -> String {
        [
            regionEnabled ? "1" : "0",
            regionCode,
            ipEnabled ? "1" : "0",
            ipCidrText,
            domainEnabled ? "1" : "0",
            domainBasicText,
            domainRegexText,
        ].joined(separator: "\u{1F}")
    }

    private func parseRules(_ text: String) -> [String] {
        return text
            .split(whereSeparator: { $0 == "\n" || $0 == "," || $0 == ";" })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func mergeDomainRules(domain: [String], domainSuffix: [String]) -> String {
        let suffixRules = domainSuffix
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0.hasPrefix(".") ? $0 : ".\($0)" }

        return (domain + suffixRules).joined(separator: "\n")
    }

    private func splitDomainBasicRules(_ rules: [String]) -> ([String], [String]) {
        var domains: [String] = []
        var domainSuffixes: [String] = []

        for rule in rules {
            if rule.hasPrefix(".") {
                let suffix = "." + String(rule.drop(while: { $0 == "." }))
                if !suffix.isEmpty {
                    domainSuffixes.append(suffix)
                }
            } else {
                domains.append(rule)
            }
        }

        return (domains, domainSuffixes)
    }

    private var editorBackgroundColor: Color {
        #if os(macOS)
            Color(nsColor: .textBackgroundColor)
        #else
            Color(uiColor: .secondarySystemBackground)
        #endif
    }
}

#Preview {
    SplitSettingsView()
        .environmentObject(vpnClient)
}
