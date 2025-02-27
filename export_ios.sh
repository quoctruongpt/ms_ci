#!/bin/bash

# Lấy thư mục chứa script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
echo "Thư mục script: $SCRIPT_DIR"

# Định nghĩa các biến
UNITY_PATH="/Applications/Unity/Hub/Editor/2022.3.57f1/Unity.app/Contents/MacOS/Unity"
PROJECT_PATH="$SCRIPT_DIR/MonkeyStories_UN" # Đường dẫn đến dự án Unity
RN_PROJECT_PATH="$SCRIPT_DIR/MonkeyStories" # Đường dẫn đến dự án React Native
EXPORT_PATH="$SCRIPT_DIR/unity_ios_build" # Xuất tạm ra thư mục ngoài RN project
FINAL_IOS_PATH="$RN_PROJECT_PATH/unity/builds/ios" # Thư mục lưu framework cuối cùng
XCODE_PROJ_PATH="$EXPORT_PATH/Unity-iPhone.xcodeproj"
NATIVE_CALL_PROXY_PATH="$EXPORT_PATH/Libraries/Plugins/iOS/NativeCallProxy.h"
FRAMEWORK_PATH="$EXPORT_PATH/UnityFramework"
PBXPROJ_FILE="$XCODE_PROJ_PATH/project.pbxproj"
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
IOS_DIR="$RN_PROJECT_PATH/ios"

# Tên file log
LOG_FILE="$SCRIPT_DIR/logs/export_ios.log"
LOG_FILE_UNITY_FW="$SCRIPT_DIR/logs/unityframework_build.log"

echo "Bắt đầu xuất dự án Unity sang iOS..."
echo "Dự án Unity: $PROJECT_PATH"
echo "Dự án React Native: $RN_PROJECT_PATH"
echo "Thư mục xuất tạm: $EXPORT_PATH"
echo "Thư mục xuất cuối: $FINAL_IOS_PATH"

#Xoá thư mục cũ nếu tồn tại
if [ -d "$EXPORT_PATH" ]; then
    rm -rf "$EXPORT_PATH"
    echo "Đã xoá thư mục cũ: $EXPORT_PATH"
fi

# Chạy Unity để export dự án iOS
"$UNITY_PATH" -quit -batchmode -projectPath "$PROJECT_PATH" -executeMethod ExportiOS.Export -logFile "$LOG_FILE"

# Kiểm tra xem quá trình export có thành công không
if [ ! -d "$EXPORT_PATH" ]; then
    echo "Lỗi: Export iOS thất bại, không tìm thấy thư mục xuất."
    exit 1
fi

echo "✅ Export iOS hoàn tất! Thư mục xuất: $EXPORT_PATH"

# Thay đổi Target Membership của NativeCallProxy.h sang Public (nếu file tồn tại)
if [ -f "$NATIVE_CALL_PROXY_PATH" ]; then
    echo "🔧 Đang chỉnh sửa project.pbxproj để đặt NativeCallProxy.h thành Public..."
    sed -i '' 's|\(.*NativeCallProxy.h.*PBXBuildFile; fileRef = .*; \)|\1settings = {ATTRIBUTES = (Public); }; |g' "$PBXPROJ_FILE"
    echo "✅ Đã chỉnh sửa project.pbxproj!"
else
    echo "❌ Không tìm thấy NativeCallProxy.h, kiểm tra lại quá trình export!"
    exit 1
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
cd "$IOS_DIR" && pod install
