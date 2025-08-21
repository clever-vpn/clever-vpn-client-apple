# CleverVPN Client for Apple Platforms

<div align="center">
  <img src="App/Assets.xcassets/CleverIcon.imageset/logo-circle-512.png" alt="CleverVPN Logo" width="128" height="128">
  
  [![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS-blue.svg)](https://github.com/CleverVPN/clever-vpn-client-apple)
  [![Swift](https://img.shields.io/badge/swift-5.0+-orange.svg)](https://swift.org)
  [![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
  [![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)](https://github.com/CleverVPN/clever-vpn-client-apple/releases)
</div>

A modern, secure, and user-friendly VPN client for iOS and macOS built with SwiftUI. CleverVPN provides fast and reliable VPN connections with an intuitive interface designed for Apple platforms.

The client application depends on [CleverVpnKit](https://github.com/clever-vpn/clever-vpn-kit), a Swift Package Manager (SPM) package that encapsulates the complex implementation of the Clever VPN protocol, making the client code extremely concise and maintainable.

## Features

### 🚀 Core Functionality
- **Universal App**: Native support for both iOS and macOS
- **Network Extension**: Advanced VPN implementation using Apple's NetworkExtension framework
- **System Extension**: macOS system extension support for enhanced security
- **WireGuard Protocol**: Modern VPN protocol for optimal performance and security
- **QR Code Scanner**: Easy server configuration via QR codes

### 🎨 User Experience
- **SwiftUI Interface**: Modern, native UI following Apple's design guidelines
- **Dark Mode Support**: Seamless integration with system appearance
- **Status Bar Integration**: Convenient macOS menu bar access
- **Real-time Connection Status**: Live connection monitoring with visual indicators
- **Comprehensive Logging**: Detailed logs for troubleshooting

### 🔒 Security & Privacy
- **Network Extension Isolation**: Secure VPN tunnel implementation
- **Keychain Integration**: Secure credential storage
- **App Group Sharing**: Secure data sharing between app components
- **System-level VPN**: Deep integration with Apple's VPN APIs

## Screenshots

| iOS | macOS |
|-----|-------|
| *Coming Soon* | *Coming Soon* |

## Requirements

### iOS
- iOS 15.0 or later
- iPhone or iPad

### macOS
- macOS 12.0 (Monterey) or later
- Apple Silicon or Intel Mac

## Installation

### From Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/CleverVPN/clever-vpn-client-apple.git
   cd clever-vpn-client-apple
   ```

2. **Configure Developer Settings**
   ```bash
   cp Config/Developer.xcconfig.template Config/Developer.xcconfig
   ```
   
3. **Edit Developer Configuration**
   Open `Config/Developer.xcconfig` and configure your development team and bundle identifiers:
   ```
   DEVELOPMENT_TEAM = YOUR_TEAM_ID
   APP_GROUP_ID = group.com.yourcompany.clevervpn
   ```

4. **Open in Xcode**
   ```bash
   open CleverVpn.xcodeproj
   ```

5. **Build and Run**
   - Select your target device/simulator
   - Build and run the project (⌘+R)

### App Store
*Coming Soon*

## Architecture

CleverVPN follows a modular architecture designed for maintainability and security:

```
┌─────────────────────┐
│     SwiftUI App     │
├─────────────────────┤
│   CleverVpnKit      │
├─────────────────────┤
│ Network Extension   │
├─────────────────────┤
│ System Extension    │
│    (macOS only)     │
└─────────────────────┘
```

### Key Components

- **Main App**: SwiftUI-based user interface
- **CleverVpnKit**: Core VPN functionality and API
- **Network Extension**: VPN tunnel implementation
- **System Extension**: Enhanced macOS system integration

## Configuration

### Network Extension Setup

The app uses Apple's NetworkExtension framework with the following key configurations:

- **App Groups**: Enable data sharing between app and extension
- **Network Extension Capability**: Required for VPN functionality
- **Keychain Sharing**: Secure credential storage across components

### Build Configuration

Key configuration files:
- `Config/Config.xcconfig`: Main configuration
- `Config/Version.xcconfig`: Version management
- `Config/Developer.xcconfig`: Developer-specific settings

## Development

### Project Structure

```
CleverVpn/
├── App/                          # Main application
│   ├── Views/                    # SwiftUI views
│   ├── Model/                    # Data models
│   └── System Extension/         # System extension manager
├── VpnNetworkExtension/          # Network extension
├── Config/                       # Build configuration
├── docs/                         # Documentation
└── MakeDmgTool/                  # macOS DMG creation tools
```

### Key Dependencies

- **SwiftUI**: User interface framework
- **NetworkExtension**: VPN implementation
- **CleverVpnKit**: Core VPN functionality
- **CodeScanner**: QR code scanning capability
- **FlagKit**: Country flag display

### Building for Distribution

#### iOS
1. Configure provisioning profiles for App Store distribution
2. Archive the project in Xcode
3. Upload to App Store Connect

#### macOS
1. Configure Developer ID certificates
2. Use the provided DMG creation tool:
   ```bash
   cd MakeDmgTool
   ./createdmg.sh
   ```

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Code Style

- Follow Swift coding conventions
- Use SwiftUI best practices
- Maintain consistency with existing code
- Add comments for complex logic

## Troubleshooting

### Common Issues

**VPN Connection Fails**
- Check network extension permissions
- Verify app group configuration
- Review system logs for detailed error messages

**Build Errors**
- Ensure Developer.xcconfig is properly configured
- Check provisioning profiles and certificates
- Verify all required capabilities are enabled

**macOS System Extension Issues**
- Allow system extension in System Preferences
- Check System Extension management in Terminal
- Verify proper code signing

### Logging

The app includes comprehensive logging for troubleshooting:
- Access logs through the in-app log viewer
- System logs available via Console.app (macOS) or Xcode device logs (iOS)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 CleverVPN

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Acknowledgments

- Apple's NetworkExtension framework
- WireGuard protocol implementation
- SwiftUI community
- Open source contributors

## Support

- **Issues**: [GitHub Issues](https://github.com/CleverVPN/clever-vpn-client-apple/issues)
- **Documentation**: [Wiki](https://github.com/CleverVPN/clever-vpn-client-apple/wiki)
- **Discussions**: [GitHub Discussions](https://github.com/CleverVPN/clever-vpn-client-apple/discussions)

---

<div align="center">
  Made with ❤️ for the Apple developer community
</div>
