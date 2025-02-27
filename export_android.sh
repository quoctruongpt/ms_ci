#!/bin/bash

# Lấy thư mục chứa script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
echo "Thư mục script: $SCRIPT_DIR"

# Định nghĩa các biến
UNITY_PATH="/Applications/Unity/Hub/Editor/2022.3.57f1/Unity.app/Contents/MacOS/Unity" # Đường dẫn đến Unity Editor trên máy bạn
PROJECT_PATH="$SCRIPT_DIR/MonkeyStories_UN" # Đường dẫn đến dự án Unity của bạn
RN_PROJECT_PATH="$SCRIPT_DIR/MonkeyStories" # Đường dẫn đến dự án React Native của bạn
EXPORT_PATH="$RN_PROJECT_PATH/unity/builds/android"
MANIFEST_PATH="$EXPORT_PATH/unityLibrary/src/main/AndroidManifest.xml"
GRADLE_FILE="$EXPORT_PATH/unityLibrary/build.gradle"

# Tên file log
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/export_android.log"

# Tạo thư mục logs nếu chưa có
mkdir -p "$LOG_DIR"

echo "===================================="
echo "🔄 Bắt đầu quá trình build Unity sang Android Studio..."
echo "Dự án Unity: $PROJECT_PATH"
echo "Dự án React Native: $RN_PROJECT_PATH"
echo "Thư mục xuất: $EXPORT_PATH"
echo "Log xuất: $LOG_FILE"
echo "===================================="

# Xoá dữ liệu cũ trong thư mục xuất
if [ -d "$EXPORT_PATH" ]; then
    echo "🗑 Xoá dữ liệu cũ trong $EXPORT_PATH..."
    rm -rf "$EXPORT_PATH"
    mkdir -p "$EXPORT_PATH"
else
    echo "📂 Tạo mới thư mục xuất $EXPORT_PATH..."
    mkdir -p "$EXPORT_PATH"
fi

# Chạy Unity để export dự án Android Studio
echo "🚀 Bắt đầu export dự án từ Unity..."
"$UNITY_PATH" -quit -batchmode -projectPath "$PROJECT_PATH" -executeMethod ExportAndroidStudio.Export -exportPath "$EXPORT_PATH" > "$LOG_FILE" 2>&1

# Kiểm tra xem quá trình export có thành công không
if [ $? -ne 0 ]; then
    echo "❌ Lỗi: Unity export thất bại, kiểm tra log tại $LOG_FILE"
    exit 1
fi

# Kiểm tra xem file AndroidManifest.xml có tồn tại không
if [ ! -f "$MANIFEST_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy AndroidManifest.xml tại $MANIFEST_PATH"
    exit 1
fi

# Xoá tất cả các thẻ <intent-filter> trong AndroidManifest.xml
echo "🛠 Xoá <intent-filter> khỏi AndroidManifest.xml..."
sed -i '' '/<intent-filter>/,/<\/intent-filter>/d' "$MANIFEST_PATH"

# Kiểm tra xem file build.gradle có tồn tại không
if [ ! -f "$GRADLE_FILE" ]; then
    echo "❌ Lỗi: Không tìm thấy $GRADLE_FILE"
    exit 1
fi

# Chỉnh sửa build.gradle: Thay android.ndkDirectory bằng ndkPath và sửa dependencies
echo "🛠 Cập nhật build.gradle..."
sed -i '' 's/android.ndkDirectory/android.ndkPath/g' "$GRADLE_FILE"
sed -i '' "s/implementation(name: 'IngameDebugConsole', ext:'aar')/implementation project(':IngameDebugConsole')/g" "$GRADLE_FILE"

echo "✅ Cập nhật build.gradle thành công!"

echo "===================================="
echo "🎉 Xuất dự án hoàn tất!"
echo "📂 Kiểm tra thư mục: $EXPORT_PATH"
echo "📜 Log file: $LOG_FILE"
echo "===================================="
