//
//  SplitSettingsView.swift
//  VpnUi
//
//  Created by GitHub Copilot on 2026/3/23.
//

import CleverVpnKit
import SwiftUI

struct SplitSettingsView: View {
    @EnvironmentObject var cleverVPNModel: VPNClient

    @State private var regionEnabled = false
    @State private var regionCode = ""

    @State private var ipEnabled = false
    @State private var ipCidrText = ""

    @State private var domainEnabled = false
    @State private var domainBasicText = ""
    @State private var domainRegexText = ""
    @State private var showDomainAdvanced = false

    @State private var didLoad = false
    @State private var didSave = false

    var body: some View {
        Form {
            Section("Region") {
                Toggle("Enable region split", isOn: $regionEnabled)

                HStack {
                    Text("Detected code")
                    Spacer()
                    Text(regionCode.isEmpty ? NSLocalizedString("Auto", comment: "") : regionCode)
                        .foregroundColor(.gray)
                }

                Text("Region code is automatically detected by system and not editable.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Section("IP Rules") {
                Toggle("Enable IP split", isOn: $ipEnabled)
                ruleEditor(
                    title: "IP CIDR List",
                    hint: "One item per line, for example: 10.0.0.0/8",
                    text: $ipCidrText
                )
            }

            Section("Domain Rules") {
                Toggle("Enable domain split", isOn: $domainEnabled)
                ruleEditor(
                    title: "Domain & Suffix Rules",
                    hint: "One item per line. Use .example.com for suffix, api.example.com for exact domain.",
                    text: $domainBasicText
                )

                DisclosureGroup("Advanced Settings", isExpanded: $showDomainAdvanced) {
                    ruleEditor(
                        title: "Domain Regex",
                        hint: "One regex per line. example: ^stun\\\\..+",
                        text: $domainRegexText
                    )
                }
            }

            Section {
                Button("Save Split Settings") {
                    saveSplitInfo()
                }
                .disabled(!didLoad)
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
        .alert("Saved", isPresented: $didSave) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Split settings have been updated.")
        }
    }

    @ViewBuilder
    private func ruleEditor(title: LocalizedStringKey, hint: LocalizedStringKey, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .bold()
            Text(hint)
                .font(.caption)
                .foregroundColor(.gray)
            TextEditor(text: text)
                .frame(minHeight: 88)
                .font(.system(.body, design: .monospaced))
        }
    }

    private func loadSplitInfoIfNeeded() {
        if didLoad {
            return
        }

        if let splitInfo = cleverVPNModel.userInfo?.splitInfo {
            apply(splitInfo: splitInfo)
            didLoad = true
        }
    }

    private func apply(splitInfo: Split) {
        regionEnabled = splitInfo.region.enable
        regionCode = splitInfo.region.code

        ipEnabled = splitInfo.ip.enable
        ipCidrText = splitInfo.ip.ipCidr.joined(separator: "\n")

        domainEnabled = splitInfo.domain.enable
        domainBasicText = mergeDomainRules(domain: splitInfo.domain.domain, domainSuffix: splitInfo.domain.domainSuffix)
        domainRegexText = splitInfo.domain.domainRegex.joined(separator: "\n")
    }

    private func saveSplitInfo() {
        let (domainRules, domainSuffixRules) = splitDomainBasicRules(parseRules(domainBasicText))

        let splitInfo = Split(
            region: Region(enable: regionEnabled, code: regionCode),
            ip: IpRule(enable: ipEnabled, ipCidr: parseRules(ipCidrText)),
            domain: DomainRule(
                enable: domainEnabled,
                domain: domainRules,
                domainSuffix: domainSuffixRules,
                domainRegex: parseRules(domainRegexText)
            )
        )

        cleverVPNModel.updateSplitInfo(splitInfo: splitInfo)
        didSave = true
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
                let suffix = String(rule.drop(while: { $0 == "." }))
                if !suffix.isEmpty {
                    domainSuffixes.append(suffix)
                }
            } else {
                domains.append(rule)
            }
        }

        return (domains, domainSuffixes)
    }
}

#Preview {
    SplitSettingsView()
        .environmentObject(vpnClient)
}
