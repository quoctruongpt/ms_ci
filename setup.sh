#!/bin/sh
set -e  # Dừng script nếu có lỗi

# Nhận tham số từ dòng lệnh
BRANCH_RN=${1:-main}
BRANCH_UN=${2:-main}

# Thư mục chứa source code React Native 
PROJECT_RN_DIR="MonkeyStories"

# Thư mục chứa source code Unity
PROJECT_UN_DIR="MonkeyStories_UN"

# URL của repository GitHub RN
GIT_RN_REPO="git@github.com:quoctruongkt/MonkeyStories.git"

# URL của repository GitHub UN
GIT_UN_REPO="git@github.com:HungBuiMonkey/MS_DemoUnity.git"

# Thư mục chứa script
SCRIPTS_DIR="scripts"

# Đường dẫn đến Editor trong Unity
UNITY_EDITOR_DIR="$PROJECT_UN_DIR/Assets/Editor"

# Đường dẫn đến các file export
EXPORT_ANDROID_FILE="ExportAndroidStudio.cs"
EXPORT_IOS_FILE="ExportiOS.cs"

echo "📌 Nhánh React Native: $BRANCH_RN"
echo "📌 Nhánh Unity: $BRANCH_UN"

# Kiểm tra nếu thư mục đã tồn tại thì pull, nếu chưa thì clone
if [ -d "$PROJECT_RN_DIR" ]; then
    echo "🗑️ Đang reset và cập nhật $PROJECT_RN_DIR..."
    cd "$PROJECT_RN_DIR" || exit
    git reset --hard HEAD  # Loại bỏ toàn bộ thay đổi cục bộ
    git fetch origin  # Lấy danh sách nhánh mới nhất
    git checkout "$BRANCH_RN" || { echo "❌ Không tìm thấy nhánh $BRANCH_RN trong $PROJECT_RN_DIR!"; exit 1; }
    git pull origin "$BRANCH_RN" || { echo "❌ Pull code thất bại!"; exit 1; }
    npm install
    cd ..
else
    echo "Cloning repository..."
    git clone "$GIT_RN_REPO" "$PROJECT_RN_DIR" || { echo "❌ Clone thất bại!"; exit 1; }
    cd "$PROJECT_RN_DIR" || exit
    npm install
    cd ..
fi

# Kiểm tra nếu thư mục đã tồn tại thì pull, nếu chưa thì clone
if [ -d "$PROJECT_UN_DIR" ]; then
    echo "🗑️ Đang reset và cập nhật $PROJECT_UN_DIR..."
    cd "$PROJECT_UN_DIR" || exit
    git reset --hard HEAD  # Loại bỏ toàn bộ thay đổi cục bộ
    git fetch origin  # Lấy danh sách nhánh mới nhất
    git checkout "$BRANCH_UN" || { echo "❌ Không tìm thấy nhánh $BRANCH_UN trong $PROJECT_UN_DIR!"; exit 1; }
    git pull origin "$BRANCH_UN" || { echo "❌ Pull code Unity thất bại!"; exit 1; }
    cd ..
else
    echo "Cloning repository..."
    git clone "$GIT_UN_REPO" "$PROJECT_UN_DIR" || { echo "❌ Clone Unity thất bại!"; exit 1; }
fi

# Tạo thư mục Assets/Editor nếu chưa tồn tại
mkdir -p "$UNITY_EDITOR_DIR"

# Kiểm tra và copy file ExportAndroidStudio.cs nếu chưa có
if [ ! -f "$UNITY_EDITOR_DIR/$EXPORT_ANDROID_FILE" ]; then
    echo "📂 Không tìm thấy $EXPORT_ANDROID_FILE, đang copy từ $SCRIPTS_DIR..."
    cp "$SCRIPTS_DIR/$EXPORT_ANDROID_FILE" "$UNITY_EDITOR_DIR/"
    echo "✅ Đã copy $EXPORT_ANDROID_FILE vào $UNITY_EDITOR_DIR"
fi

# Kiểm tra và copy file ExportiOS.cs nếu chưa có
if [ ! -f "$UNITY_EDITOR_DIR/$EXPORT_IOS_FILE" ]; then
    echo "📂 Không tìm thấy $EXPORT_IOS_FILE, đang copy từ $SCRIPTS_DIR..."
    cp "$SCRIPTS_DIR/$EXPORT_IOS_FILE" "$UNITY_EDITOR_DIR/"
    echo "✅ Đã copy $EXPORT_IOS_FILE vào $UNITY_EDITOR_DIR"
fi

echo "🎉 Setup hoàn tất!"