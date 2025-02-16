#!/bin/bash

# 删除输出目录
rm -rf output

# 定义目标平台数组
platforms=("macOS" "iOS" "iOS Simulator")

# 构建每个平台的 archive
for platform in "${platforms[@]}"; do
    # 替换空格为下划线，生成 archive 文件的名字后缀
    platform_suffix=$(echo $platform | sed 's/ /_/g')
    
    xcodebuild archive \
    -project ../CleverVpnKit.xcodeproj \
    -scheme CleverVpnKit \
    -destination "generic/platform=$platform" \
    -archivePath "./output/CleverVpnKit-$platform_suffix" \
    SKIP_INSTALL=NO
done

# 创建 xcframework
archive_args=""
for platform in "${platforms[@]}"; do
    platform_suffix=$(echo $platform | sed 's/ /_/g')
    archive_args="$archive_args -archive output/CleverVpnKit-$platform_suffix.xcarchive -framework CleverVpnKit.framework"
done

xcodebuild -create-xcframework $archive_args -output ./output/CleverVpnKit.xcframework
