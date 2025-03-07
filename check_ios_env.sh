#!/bin/bash

echo "Đang kiểm tra cài đặt môi trường phát triển iOS..."

# Hàm kiểm tra sự tồn tại của lệnh
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Hàm kiểm tra phiên bản có lớn hơn hoặc bằng yêu cầu
version_greater_equal() {
    printf '%s\n%s' "$2" "$1" | sort -V -C
}

# Kiểm tra Node.js
echo "\nĐang kiểm tra Node.js..."
if command_exists node; then
    NODE_VERSION=$(node -v | cut -d 'v' -f2)
    echo "Đã tìm thấy Node.js phiên bản: $NODE_VERSION"
    if version_greater_equal "$NODE_VERSION" "18.18.0"; then
        echo "✅ Phiên bản Node.js tương thích"
    else
        echo "❌ Phiên bản Node.js phải là 18.18.0 hoặc mới hơn"
        echo "Để cập nhật Node.js:"
        echo "1. Sử dụng nvm (Node Version Manager):"
        echo "   - Cài đặt nvm: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash"
        echo "   - Cài đặt Node.js: nvm install 18.18.0"
        echo "2. Hoặc sử dụng Homebrew:"
        echo "   - brew update"
        echo "   - brew install node@18"
    fi
else
    echo "❌ Không tìm thấy Node.js"
    echo "Cài đặt Node.js bằng một trong các cách sau:"
    echo "1. Sử dụng Homebrew:"
    echo "   - brew update"
    echo "   - brew install node@18"
    echo "2. Tải trực tiếp từ trang chủ: https://nodejs.org/"
fi

# Kiểm tra Watchman
echo "\nĐang kiểm tra Watchman..."
if command_exists watchman; then
    WATCHMAN_VERSION=$(watchman --version)
    echo "✅ Đã tìm thấy Watchman, phiên bản: $WATCHMAN_VERSION"
else
    echo "❌ Không tìm thấy Watchman"
    echo "Cài đặt Watchman bằng một trong các cách sau:"
    echo "1. Sử dụng Homebrew:"
    echo "   - brew update"
    echo "   - brew install watchman"
    echo "2. Tải từ trang chủ: https://facebook.github.io/watchman/"
fi

# Kiểm tra Xcode
echo "\nĐang kiểm tra Xcode..."
XCODE_PATH="/Applications/Xcode.app"
if [ -d "$XCODE_PATH" ]; then
    XCODE_VERSION=$(/usr/bin/xcodebuild -version | head -n1 | awk '{ print $2 }')
    echo "✅ Đã tìm thấy Xcode, phiên bản: $XCODE_VERSION"
else
    echo "❌ Không tìm thấy Xcode"
    echo "Cài đặt Xcode từ Mac App Store: https://apps.apple.com/us/app/xcode/id497799835"
fi

# Kiểm tra Xcode Command Line Tools
echo "\nĐang kiểm tra Xcode Command Line Tools..."
if xcode-select -p &>/dev/null; then
    echo "✅ Xcode Command Line Tools đã được cài đặt"
else
    echo "❌ Xcode Command Line Tools chưa được cài đặt"
    echo "Cài đặt bằng cách:"
    echo "1. Mở Xcode"
    echo "2. Vào Settings (hoặc Preferences)"
    echo "3. Chọn tab Locations"
    echo "4. Chọn phiên bản Command Line Tools mới nhất"
    echo "Hoặc chạy lệnh: xcode-select --install"
fi

# Kiểm tra Unity
echo "\nĐang kiểm tra Unity..."
UNITY_HUB_PATH="/Applications/Unity Hub.app"
UNITY_PATH="/Applications/Unity/Hub/Editor/2022.3.57f1"

if [ -d "$UNITY_HUB_PATH" ]; then
    if [ -d "$UNITY_PATH" ]; then
        echo "✅ Unity phiên bản 2022.3.57f1 đã được cài đặt"
    else
        echo "❌ Không tìm thấy Unity phiên bản 2022.3.57f1"
        echo "Cài đặt Unity thông qua Unity Hub:"
        echo "1. Mở Unity Hub"
        echo "2. Vào tab Installs"
        echo "3. Nhấn Add"
        echo "4. Chọn phiên bản 2022.3.57f1"
        echo "5. Chọn các module cần thiết (Android Build Support, iOS Build Support)"
        echo "6. Nhấn Install để cài đặt"
    fi
else
    echo "❌ Không tìm thấy Unity Hub"
    echo "Cài đặt Unity Hub từ: https://unity.com/download"
fi

# Kiểm tra CocoaPods
echo "\nĐang kiểm tra CocoaPods..."
if command_exists pod; then
    POD_VERSION=$(pod --version)
    echo "✅ Đã tìm thấy CocoaPods, phiên bản: $POD_VERSION"
else
    echo "❌ Không tìm thấy CocoaPods"
    echo "Cài đặt CocoaPods bằng lệnh:"
    echo "sudo gem install cocoapods"
fi

# Kiểm tra cấu hình môi trường
echo "\nĐang kiểm tra cấu hình môi trường..."

# Kiểm tra NVM (nếu được sử dụng)
if [ -d "$HOME/.nvm" ]; then
    echo "\nPhát hiện NVM được cài đặt"
    if grep -q "nvm.sh" "$HOME/.zshenv" 2>/dev/null; then
        echo "✅ Cấu hình NVM đã có trong .zshenv"
    else
        echo "⚠️ Nên di chuyển cấu hình NVM từ .zshrc sang .zshenv"
        echo "Thêm các dòng sau vào ~/.zshenv:"
        echo 'export NVM_DIR="$HOME/.nvm"'
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
    fi
fi

echo "\nKiểm tra môi trường đã hoàn tất."