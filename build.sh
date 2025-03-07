#!/bin/sh
set -e  # Dừng script nếu có lỗi

# Nhận tham số từ dòng lệnh
BUILD_TARGET=$1   # android | ios | all
BRANCH_RN=$2      # Nhánh React Native
BRANCH_UN=$3      # Nhánh Unity

# Kiểm tra tham số đầu vào
if [ -z "$BUILD_TARGET" ] || [ -z "$BRANCH_RN" ] || [ -z "$BRANCH_UN" ]; then
    echo "❌ Thiếu tham số! Cách sử dụng:"
    echo "  ./build.sh android <branch_rn> <branch_unity>"
    echo "  ./build.sh ios <branch_rn> <branch_unity>"
    echo "  ./build.sh all <branch_rn> <branch_unity>"
    exit 1
fi

# Kiểm tra tính hợp lệ của BUILD_TARGET
if [ "$BUILD_TARGET" != "android" ] && [ "$BUILD_TARGET" != "ios" ] && [ "$BUILD_TARGET" != "all" ]; then
    echo "❌ BUILD_TARGET không hợp lệ. Chỉ chấp nhận: android, ios, hoặc all"
    exit 1
fi

# Kiểm tra sự tồn tại của các script phụ thuộc
for script in setup.sh export_android.sh export_ios.sh check_android_env.sh check_ios_env.sh; do
    if [ ! -f "$script" ]; then
        echo "❌ Không tìm thấy script: $script"
        exit 1
    fi
done

# Kiểm tra môi trường dựa trên BUILD_TARGET
echo "🔍 Kiểm tra môi trường build..."
if [ "$BUILD_TARGET" = "android" ] || [ "$BUILD_TARGET" = "all" ]; then
    echo "Kiểm tra môi trường Android..."
    if ! sh check_android_env.sh; then
        echo "❌ Môi trường Android chưa được cấu hình đúng"
        exit 1
    fi
fi

if [ "$BUILD_TARGET" = "ios" ] || [ "$BUILD_TARGET" = "all" ]; then
    echo "Kiểm tra môi trường iOS..."
    if ! sh check_ios_env.sh; then
        echo "❌ Môi trường iOS chưa được cấu hình đúng"
        exit 1
    fi
fi

echo "✅ Kiểm tra môi trường thành công"

echo "📌 Bắt đầu setup code với nhánh React Native: $BRANCH_RN và Unity: $BRANCH_UN"
if ! sh setup.sh "$BRANCH_RN" "$BRANCH_UN"; then
    echo "❌ Lỗi khi chạy setup.sh"
    exit 1
fi

# Chạy build Android nếu chọn android hoặc all
if [ "$BUILD_TARGET" = "android" ] || [ "$BUILD_TARGET" = "all" ]; then
    echo "🚀 Bắt đầu build Android..."
    if ! sh export_android.sh; then
        echo "❌ Lỗi khi build Android"
        exit 1
    fi
    echo "✅ Build Android thành công"
fi

# Chạy build iOS nếu chọn ios hoặc all
if [ "$BUILD_TARGET" = "ios" ] || [ "$BUILD_TARGET" = "all" ]; then
    echo "🚀 Bắt đầu build iOS..."
    if ! sh export_ios.sh; then
        echo "❌ Lỗi khi build iOS"
        exit 1
    fi
    echo "✅ Build iOS thành công"
fi

echo "🎉 Build hoàn tất!"