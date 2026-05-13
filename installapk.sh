#!/bin/bash

# =================================================================
# Script tự động cài đặt ứng dụng APK từ GitHub Release
# Nguồn: https://github.com/ductam276/apk/releases/tag/Update-30%2F4%2F2026
# =================================================================

# Thông tin API
REPO="ductam276/apk"
API_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"
TEMP_DIR="repo_apks_temp"

# Tạo thư mục tạm
mkdir -p "$TEMP_DIR"
read -p "Pick ROM: 1: root ; 2: nonroot" ROM_CHOICE

if [ "$ROM_CHOICE" == "1" ]; then
    TAG="root"
elif [ "$ROM_CHOICE" == "2" ]; then
    TAG="nonroot"
else
    echo "Lựa chọn không hợp lệ!"
    exit 1
fi
echo "--- Đang kiểm tra kết nối ADB ---"
if ! adb devices | grep -q -w "device"; then
    echo "Lỗi: Không tìm thấy thiết bị Android. Hãy bật USB Debugging và kết nối lại."
    exit 1
fi

echo "--- Đang lấy danh sách ứng dụng từ GitHub ---"
# Lấy danh sách link tải APK
APK_URLS=$(curl -s "$API_URL" | jq -r '.assets[] | select(.name | endswith(".apk")) | .browser_download_url')

if [ -z "$APK_URLS" ] || [ "$APK_URLS" == "null" ]; then
    echo "Lỗi: Không tìm thấy file APK nào hoặc bị GitHub giới hạn truy cập (Rate Limit)."
    exit 1
fi

count=0
for url in $APK_URLS; do
    filename=$(basename "$url")
    count=$((count + 1))

    echo ""
    echo "[$count] Đang tải: $filename..."
    curl -L -o "$TEMP_DIR/$filename" "$url"

    if [ $? -eq 0 ]; then
        echo "--> Đang cài đặt vào điện thoại..."
        # -r: cài đè, -d: cho phép hạ cấp (downgrade)
        adb install -r -d "$TEMP_DIR/$filename"

        if [ $? -eq 0 ]; then
            echo "Thành công: $filename"
        else
            echo "THẤT BẠI: $filename"
        fi
    else
        echo "Lỗi khi tải file: $filename"
    fi
done

echo ""
echo "--- Đang dọn dẹp bộ nhớ tạm ---"
rm -rf "$TEMP_DIR"

echo "=== HOÀN TẤT: Đã xử lý xong toàn bộ danh sách! ==="
