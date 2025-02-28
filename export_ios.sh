#!/bin/bash
set -e  # Dừng script nếu có lỗi

# Lấy thư mục chứa script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# Tạo thư mục logs nếu chưa tồn tại
mkdir -p "$SCRIPT_DIR/logs"

# Định nghĩa các biến
UNITY_PATH="/Applications/Unity/Hub/Editor/2022.3.57f1/Unity.app/Contents/MacOS/Unity"
PROJECT_PATH="$SCRIPT_DIR/MonkeyStories_UN"
RN_PROJECT_PATH="$SCRIPT_DIR/MonkeyStories"
EXPORT_PATH="$SCRIPT_DIR/unity_ios_build"
FINAL_IOS_PATH="$RN_PROJECT_PATH/unity/builds/ios"
XCODE_PROJ_PATH="$EXPORT_PATH/Unity-iPhone.xcodeproj"
NATIVE_CALL_PROXY_PATH="$EXPORT_PATH/Libraries/Plugins/iOS/NativeCallProxy.h"
PBXPROJ_FILE="$XCODE_PROJ_PATH/project.pbxproj"
IOS_DIR="$RN_PROJECT_PATH/ios"

# Tên file log với timestamp
LOG_FILE="$SCRIPT_DIR/logs/export_ios_$(date +%Y%m%d_%H%M%S).log"
LOG_FILE_UNITY_FW="$SCRIPT_DIR/logs/unityframework_build_$(date +%Y%m%d_%H%M%S).log"

# Kiểm tra các điều kiện tiên quyết
if [ ! -f "$UNITY_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy Unity Editor tại $UNITY_PATH"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy dự án Unity tại $PROJECT_PATH"
    exit 1
fi

if [ ! -d "$RN_PROJECT_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy dự án React Native tại $RN_PROJECT_PATH"
    exit 1
fi

# Tạo thư mục xuất cuối nếu chưa tồn tại
mkdir -p "$FINAL_IOS_PATH"

echo "===================================="
echo "🚀 Bắt đầu xuất dự án Unity sang iOS..."
echo "📂 Dự án Unity: $PROJECT_PATH"
echo "📂 Dự án React Native: $RN_PROJECT_PATH"
echo "📂 Thư mục xuất tạm: $EXPORT_PATH"
echo "📂 Thư mục xuất cuối: $FINAL_IOS_PATH"
echo "📜 Log file: $LOG_FILE"
echo "===================================="

# Xoá và tạo lại thư mục xuất
rm -rf "$EXPORT_PATH"
mkdir -p "$EXPORT_PATH"

# Chạy Unity để export dự án iOS với timeout
echo "🔄 Đang export từ Unity..."
timeout 1800 "$UNITY_PATH" -quit -batchmode -projectPath "$PROJECT_PATH" -executeMethod ExportiOS.Export -logFile "$LOG_FILE" || {
    echo "❌ Lỗi: Unity export thất bại hoặc timeout"
    echo "📜 Chi tiết lỗi cuối cùng:"
    tail -n 20 "$LOG_FILE"
    exit 1
}

# Backup project.pbxproj trước khi chỉnh sửa
if [ -f "$PBXPROJ_FILE" ]; then
    cp "$PBXPROJ_FILE" "${PBXPROJ_FILE}.backup"
    echo "📦 Đã tạo backup project.pbxproj"
fi

# Thay đổi Target Membership với xử lý lỗi
if [ -f "$NATIVE_CALL_PROXY_PATH" ]; then
    echo "🔧 Đang chỉnh sửa project.pbxproj..."
    if ! sed -i '' 's|\(.*NativeCallProxy.h.*PBXBuildFile; fileRef = .*; \)|\1settings = {ATTRIBUTES = (Public); }; |g' "$PBXPROJ_FILE"; then
        echo "❌ Lỗi khi chỉnh sửa project.pbxproj"
        [ -f "${PBXPROJ_FILE}.backup" ] && cp "${PBXPROJ_FILE}.backup" "$PBXPROJ_FILE"
        exit 1
    fi
fi

echo "🔧 Chuyển target membership của thư mục Data sang UnityFramework..."
ruby update_target_membership.rb "$XCODE_PROJ_PATH"

echo "🚀 Bắt đầu build UnityFramework trong Xcode..."

# # Kiểm tra xem project.pbxproj có tồn tại không
if [ ! -f "$PBXPROJ_FILE" ]; then
    echo "❌ Không tìm thấy project.pbxproj tại $PBXPROJ_FILE!"
    exit 1
fi

# # Chạy xcodebuild để build UnityFramework
xcodebuild -project "$XCODE_PROJ_PATH" -scheme UnityFramework -configuration Release -sdk iphoneos clean build | tee "$LOG_FILE_UNITY_FW"

# # Kiểm tra kết quả build
if [ $? -eq 0 ]; then
    echo "✅ Build UnityFramework thành công!"
else
    echo "❌ Build UnityFramework thất bại! Kiểm tra log: $SCRIPT_DIR/unityframework_build.log"
    exit 1
fi

# Lấy đường dẫn DerivedData từ xcodebuild
DERIVED_DATA_PATH=$(xcodebuild -project "$XCODE_PROJ_PATH" -scheme UnityFramework -showBuildSettings | grep -m 1 "BUILD_DIR" | awk '{print $3}')

if [ -z "$DERIVED_DATA_PATH" ]; then
    echo "❌ Không tìm thấy thư mục DerivedData từ Xcode!"
    exit 1
fi

# Định nghĩa đường dẫn chính xác của UnityFramework.framework
UNITY_FRAMEWORK_PATH="$DERIVED_DATA_PATH/Release-iphoneos/UnityFramework.framework"

if [ -d "$UNITY_FRAMEWORK_PATH" ]; then
    echo "🚚 Đang sao chép UnityFramework.framework vào thư mục cuối cùng..."
    rm -rf "$FINAL_IOS_PATH/UnityFramework.framework" # Xóa framework cũ nếu có
    cp -R "$UNITY_FRAMEWORK_PATH" "$FINAL_IOS_PATH"
    echo "✅ Sao chép UnityFramework.framework thành công vào: $FINAL_IOS_PATH"
else
    echo "❌ Không tìm thấy UnityFramework.framework trong thư mục Build!"
    exit 1
fi

# Xóa Pods và Podfile.lock
rm -rf "$IOS_DIR/Pods"
rm -f "$IOS_DIR/Podfile.lock"

echo "✅ Đã xóa Pods và Podfile.lock!"

# Chạy lại pod install
echo "📦 Đang cài đặt lại Pods..."
cd "$IOS_DIR" && timeout 300 pod install || {
    echo "❌ Lỗi: Pod install thất bại hoặc timeout"
    exit 1
}

echo "===================================="
echo "✅ Quá trình xuất iOS hoàn tất!"
echo "📂 Framework tại: $FINAL_IOS_PATH"
echo "📜 Log files:"
echo "   - Unity Export: $LOG_FILE"
echo "   - Framework Build: $LOG_FILE_UNITY_FW"
echo "===================================="
