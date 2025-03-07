#!/bin/bash
set -e  # Dừng script nếu có lỗi

# Tạo thư mục logs
mkdir -p logs && touch logs/tmp.log
LOG_FILE="logs/setup_$(date +%Y%m%d_%H%M%S).log"

# Alternative logging approach
exec > "$LOG_FILE" 2>&1


# Nhận tham số từ dòng lệnh
BRANCH_RN=${1:-main}
BRANCH_UN=${2:-main}

# Định nghĩa các biến
PROJECT_RN_DIR="MonkeyStories"
PROJECT_UN_DIR="MonkeyStories_UN"
GIT_RN_REPO="git@github.com:quoctruongkt/MonkeyStories.git"
GIT_UN_REPO="git@github.com:HungBuiMonkey/MS_DemoUnity.git"
SCRIPTS_DIR="scripts"
UNITY_EDITOR_DIR="$PROJECT_UN_DIR/Assets/Editor"
EXPORT_ANDROID_FILE="ExportAndroidStudio.cs"
EXPORT_IOS_FILE="ExportiOS.cs"

# Kiểm tra các điều kiện tiên quyết
if [ ! -d "$SCRIPTS_DIR" ]; then
    echo "❌ Lỗi: Không tìm thấy thư mục scripts!"
    exit 1
fi

for file in "$SCRIPTS_DIR/$EXPORT_ANDROID_FILE" "$SCRIPTS_DIR/$EXPORT_IOS_FILE"; do
    if [ ! -f "$file" ]; then
        echo "❌ Lỗi: Không tìm thấy file $file"
        exit 1
    fi
done

# Hàm xử lý clone/pull repository
handle_repository() {
    local dir=$1
    local repo=$2
    local branch=$3
    local name=$4

    if [ -d "$dir" ]; then
        echo "🔄 Đang cập nhật $name repository..."
        (cd "$dir" && {
            git reset --hard HEAD
            git fetch origin || { echo "❌ Fetch thất bại cho $name!"; exit 1; }
            git checkout "$branch" || { echo "❌ Checkout thất bại cho nhánh $branch!"; exit 1; }
            git pull origin "$branch" || { echo "❌ Pull thất bại cho $name!"; exit 1; }
        })
    else
        echo "📥 Đang clone $name repository..."
        git clone -b "$branch" "$repo" "$dir" || { echo "❌ Clone thất bại cho $name!"; exit 1; }
    fi
}

echo "===================================="
echo "🚀 Bắt đầu setup dự án..."
echo "📌 Nhánh React Native: $BRANCH_RN"
echo "📌 Nhánh Unity: $BRANCH_UN"
echo "📜 Log file: $LOG_FILE"
echo "===================================="

# Xử lý React Native repository
handle_repository "$PROJECT_RN_DIR" "$GIT_RN_REPO" "$BRANCH_RN" "React Native"

# Cài đặt dependencies cho React Native
if [ -d "$PROJECT_RN_DIR" ]; then
    echo "📦 Cài đặt dependencies cho React Native..."
    (cd "$PROJECT_RN_DIR" && {
        npm install || { echo "❌ npm install thất bại!"; exit 1; }
    })
fi

# Xử lý Unity repository
handle_repository "$PROJECT_UN_DIR" "$GIT_UN_REPO" "$BRANCH_UN" "Unity"

# Tạo và copy các file Editor
echo "📂 Thiết lập Unity Editor files..."
mkdir -p "$UNITY_EDITOR_DIR"

for file in "$EXPORT_ANDROID_FILE" "$EXPORT_IOS_FILE"; do
    if [ ! -f "$UNITY_EDITOR_DIR/$file" ]; then
        echo "📄 Copy $file vào Unity Editor..."
        cp "$SCRIPTS_DIR/$file" "$UNITY_EDITOR_DIR/" || { echo "❌ Copy thất bại cho $file!"; exit 1; }
    fi
done

echo "===================================="
echo "✅ Setup hoàn tất!"
echo "📂 React Native: $PROJECT_RN_DIR (nhánh: $BRANCH_RN)"
echo "📂 Unity: $PROJECT_UN_DIR (nhánh: $BRANCH_UN)"
echo "📜 Log file: $LOG_FILE"
echo "===================================="