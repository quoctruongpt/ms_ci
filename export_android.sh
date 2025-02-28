#!/bin/bash
set -e  # Dừng script nếu có lỗi xảy ra

# Lấy thư mục chứa script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
echo "Thư mục script: $SCRIPT_DIR"

# Định nghĩa các biến
UNITY_PATH="/Applications/Unity/Hub/Editor/2022.3.57f1/Unity.app/Contents/MacOS/Unity"
PROJECT_PATH="$SCRIPT_DIR/MonkeyStories_UN"
RN_PROJECT_PATH="$SCRIPT_DIR/MonkeyStories"
EXPORT_PATH="$RN_PROJECT_PATH/unity/builds/android"
MANIFEST_PATH="$EXPORT_PATH/unityLibrary/src/main/AndroidManifest.xml"
GRADLE_FILE="$EXPORT_PATH/unityLibrary/build.gradle"

# Kiểm tra Unity Editor
if [ ! -f "$UNITY_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy Unity Editor tại $UNITY_PATH"
    exit 1
fi

# Kiểm tra dự án Unity
if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy dự án Unity tại $PROJECT_PATH"
    exit 1
fi

# Kiểm tra dự án React Native
if [ ! -d "$RN_PROJECT_PATH" ]; then
    echo "❌ Lỗi: Không tìm thấy dự án React Native tại $RN_PROJECT_PATH"
    exit 1
fi

# Tên file log
LOG_DIR="$SCRIPT_DIR/logs"
LOG_FILE="$LOG_DIR/export_android_$(date +%Y%m%d_%H%M%S).log"

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
if ! "$UNITY_PATH" -quit -batchmode -projectPath "$PROJECT_PATH" -executeMethod ExportAndroidStudio.Export -exportPath "$EXPORT_PATH" > "$LOG_FILE" 2>&1; then
    echo "❌ Lỗi: Unity export thất bại"
    echo "📜 Chi tiết lỗi cuối cùng:"
    tail -n 20 "$LOG_FILE"
    exit 1
fi

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

# Backup AndroidManifest.xml trước khi chỉnh sửa
cp "$MANIFEST_PATH" "${MANIFEST_PATH}.backup"
echo "📦 Đã tạo backup AndroidManifest.xml"

# Xoá tất cả các thẻ <intent-filter> trong AndroidManifest.xml
echo "🛠 Xoá <intent-filter> khỏi AndroidManifest.xml..."
if ! sed -i '' '/<intent-filter>/,/<\/intent-filter>/d' "$MANIFEST_PATH"; then
    echo "❌ Lỗi khi chỉnh sửa AndroidManifest.xml"
    echo "🔄 Khôi phục từ backup..."
    cp "${MANIFEST_PATH}.backup" "$MANIFEST_PATH"
    exit 1
fi

# Backup build.gradle trước khi chỉnh sửa
cp "$GRADLE_FILE" "${GRADLE_FILE}.backup"
echo "📦 Đã tạo backup build.gradle"

# Chỉnh sửa build.gradle
echo "🛠 Cập nhật build.gradle..."
if ! sed -i '' 's/android.ndkDirectory/android.ndkPath/g' "$GRADLE_FILE" || \
   ! sed -i '' "s/implementation(name: 'IngameDebugConsole', ext:'aar')/implementation project(':IngameDebugConsole')/g" "$GRADLE_FILE"; then
    echo "❌ Lỗi khi chỉnh sửa build.gradle"
    echo "🔄 Khôi phục từ backup..."
    cp "${GRADLE_FILE}.backup" "$GRADLE_FILE"
    exit 1
fi

echo "✅ Cập nhật build.gradle thành công!"

echo "===================================="
echo "🎉 Xuất dự án hoàn tất!"
echo "📂 Kiểm tra thư mục: $EXPORT_PATH"
echo "📜 Log file: $LOG_FILE"
echo "===================================="
