#!/bin/bash

echo "Đang kiểm tra cài đặt môi trường phát triển Android..."

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

# Kiểm tra Java
echo "\nĐang kiểm tra Java..."
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    echo "Đã tìm thấy Java phiên bản: $JAVA_VERSION"
    if [[ $JAVA_VERSION == 17* ]]; then
        echo "✅ Phiên bản Java tương thích (JDK 17)"
    else
        echo "❌ Cần JDK 17 để phát triển Android"
        echo "Cài đặt JDK 17 bằng một trong các cách sau:"
        echo "1. Sử dụng Homebrew:"
        echo "   - brew tap homebrew/cask-versions"
        echo "   - brew install --cask temurin17"
        echo "2. Tải trực tiếp từ trang chủ: https://adoptium.net/"
        echo "3. Sử dụng SDKMAN:"
        echo "   - curl -s \"https://get.sdkman.io\" | bash"
        echo "   - source \"$HOME/.sdkman/bin/sdkman-init.sh\""
        echo "   - sdk install java 17.0.8-tem"
    fi
else
    echo "❌ Không tìm thấy Java"
    echo "Cài đặt JDK 17 bằng một trong các cách sau:"
    echo "1. Sử dụng Homebrew:"
    echo "   - brew tap homebrew/cask-versions"
    echo "   - brew install --cask temurin17"
    echo "2. Tải trực tiếp từ trang chủ: https://adoptium.net/"
    echo "3. Sử dụng SDKMAN:"
    echo "   - curl -s \"https://get.sdkman.io\" | bash"
    echo "   - source \"$HOME/.sdkman/bin/sdkman-init.sh\""
    echo "   - sdk install java 17.0.8-tem"
fi

# Kiểm tra JAVA_HOME
echo "\nĐang kiểm tra JAVA_HOME..."
if [ -n "$JAVA_HOME" ]; then
    echo "✅ JAVA_HOME đã được thiết lập tại: $JAVA_HOME"
else
    echo "❌ JAVA_HOME chưa được thiết lập"
    echo "Thiết lập JAVA_HOME bằng cách thêm các dòng sau vào ~/.zshrc hoặc ~/.bash_profile:"
    echo "export JAVA_HOME=\$(/usr/libexec/java_home -v 17)"
    echo "export PATH=\$JAVA_HOME/bin:\$PATH"
    echo "\nSau đó chạy lệnh: source ~/.zshrc (hoặc source ~/.bash_profile)"
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

# Kiểm tra Android Studio và SDK
echo "\nĐang kiểm tra Android SDK..."
if [ -n "$ANDROID_HOME" ]; then
    echo "✅ ANDROID_HOME đã được thiết lập tại: $ANDROID_HOME"
    
    # Kiểm tra SDK Platform
    if [ -d "$ANDROID_HOME/platforms/android-35" ]; then
        echo "✅ Android SDK Platform 35 đã được cài đặt"
    else
        echo "❌ Android SDK Platform 35 chưa được cài đặt"
        echo "Cài đặt thông qua Android Studio:"
        echo "1. Mở Android Studio"
        echo "2. Vào Settings/Preferences -> Appearance & Behavior -> System Settings -> Android SDK"
        echo "3. Chọn tab 'SDK Platforms'"
        echo "4. Chọn 'Android 14.0 (API Level 35)'"
        echo "5. Nhấn 'Apply' để cài đặt"
    fi

    # Kiểm tra Build Tools
    if [ -d "$ANDROID_HOME/build-tools/35.0.0" ]; then
        echo "✅ Android Build Tools 35.0.0 đã được cài đặt"
    else
        echo "❌ Android Build Tools 35.0.0 chưa được cài đặt"
        echo "Cài đặt thông qua Android Studio:"
        echo "1. Mở Android Studio"
        echo "2. Vào Settings/Preferences -> Appearance & Behavior -> System Settings -> Android SDK"
        echo "3. Chọn tab 'SDK Tools'"
        echo "4. Chọn 'Android SDK Build-Tools 35.0.0'"
        echo "5. Nhấn 'Apply' để cài đặt"
    fi

    # Kiểm tra Platform Tools
    if [ -d "$ANDROID_HOME/platform-tools" ]; then
        echo "✅ Android Platform Tools đã được cài đặt"
    else
        echo "❌ Android Platform Tools chưa được cài đặt"
        echo "Cài đặt thông qua Android Studio:"
        echo "1. Mở Android Studio"
        echo "2. Vào Settings/Preferences -> Appearance & Behavior -> System Settings -> Android SDK"
        echo "3. Chọn tab 'SDK Tools'"
        echo "4. Chọn 'Android SDK Platform-Tools'"
        echo "5. Nhấn 'Apply' để cài đặt"
    fi

    # Kiểm tra Emulator
    if [ -d "$ANDROID_HOME/emulator" ]; then
        echo "✅ Android Emulator đã được cài đặt"
    else
        echo "❌ Android Emulator chưa được cài đặt"
        echo "Cài đặt thông qua Android Studio:"
        echo "1. Mở Android Studio"
        echo "2. Vào Settings/Preferences -> Appearance & Behavior -> System Settings -> Android SDK"
        echo "3. Chọn tab 'SDK Tools'"
        echo "4. Chọn 'Android Emulator'"
        echo "5. Nhấn 'Apply' để cài đặt"
    fi
else
    echo "❌ ANDROID_HOME chưa được thiết lập"
    echo "1. Cài đặt Android Studio từ: https://developer.android.com/studio"
    echo "2. Sau khi cài đặt, thêm các dòng sau vào ~/.zshrc hoặc ~/.bash_profile:"
    echo "export ANDROID_HOME=\$HOME/Library/Android/sdk"
    echo "export PATH=\$PATH:\$ANDROID_HOME/emulator"
    echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools"
    echo "\nSau đó chạy lệnh: source ~/.zshrc (hoặc source ~/.bash_profile)"
fi

# Kiểm tra PATH có chứa công cụ Android
echo "\nĐang kiểm tra PATH cho công cụ Android..."
if echo $PATH | grep -q "$ANDROID_HOME/platform-tools"; then
    echo "✅ platform-tools đã có trong PATH"
else
    echo "❌ platform-tools chưa có trong PATH"
    echo "Thêm dòng sau vào ~/.zshrc hoặc ~/.bash_profile:"
    echo "export PATH=\$PATH:\$ANDROID_HOME/platform-tools"
fi

if echo $PATH | grep -q "$ANDROID_HOME/emulator"; then
    echo "✅ emulator đã có trong PATH"
else
    echo "❌ emulator chưa có trong PATH"
    echo "Thêm dòng sau vào ~/.zshrc hoặc ~/.bash_profile:"
    echo "export PATH=\$PATH:\$ANDROID_HOME/emulator"
fi

echo "\nKiểm tra môi trường đã hoàn tất."