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

echo "📌 Bắt đầu setup code với nhánh React Native: $BRANCH_RN và Unity: $BRANCH_UN"
sh setup.sh "$BRANCH_RN" "$BRANCH_UN"

# Chạy build Android nếu chọn android hoặc all
if [ "$BUILD_TARGET" = "android" ] || [ "$BUILD_TARGET" = "all" ]; then
    echo "🚀 Bắt đầu build Android..."
    sh export_android.sh
fi

# Chạy build iOS nếu chọn ios hoặc all
if [ "$BUILD_TARGET" = "ios" ] || [ "$BUILD_TARGET" = "all" ]; then
    echo "🚀 Bắt đầu build iOS..."
    sh export_ios.sh
fi

echo "🎉 Build hoàn tất!"