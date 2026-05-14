#!/bin/bash

# =================================================================
# Script tự động cài đặt ứng dụng APK từ GitHub Release
# Nguồn: https://github.com/ductam276/apk/
# =================================================================

# Thông tin API
REPO="ductam276/apk"
TEMP_DIR="apks_temp"

# Tạo thư mục tạm
echo "Choose install packages you want"
echo "1: Default"
echo "2: Default + Root"
echo "3: Root only"
read -p ROM_CHOICE
checking
if [ "$ROM_CHOICE" == "1" ]; then
    TAG="default"
    installapk
elif [ "$ROM_CHOICE" == "2" ]; then
    TAG="default"
    installapk
    TAG="root"
    installapk
elif [ "$ROM_CHOICE" == "3" ]; then
    TAG="root"
    installapk
else
    echo "Error!"
    exit 1
fi

checking (){
echo "Checking adb devices"
if ! adb devices | grep -q -w "device"; then
    echo "Error, No Adb devices found"
    exit 1
fi
}

install_apk() {
mkdir -p "$TEMP_DIR"
echo "Import Apks list from github"
echo "Tag is $TAG"
# Lấy danh sách link tải APK
API_URL="https://api.github.com/repos/$REPO/releases/tags/$TAG"
APK_URLS=$(curl -s "$API_URL" | jq -r '.assets[] | select(.name | endswith(".apk")) | .browser_download_url')

if [ -z "$APK_URLS" ] || [ "$APK_URLS" == "null" ]; then
    echo "No apks found from github"
    exit 1
fi

count=0
for url in $APK_URLS; do
    filename=$(basename "$url")
    count=$((count + 1))

    echo ""
    echo "[$count] Đang tải: $filename..."
    curl -sL -o "$TEMP_DIR/$filename" "$url"

    if [ $? -eq 0 ]; then
        echo "Installing to devices"
        adb install "$TEMP_DIR/$filename"

        if [ $? -eq 0 ]; then
            echo "Success: $filename"
        else
            echo "Failed: $filename"
        fi
    else
        echo "Cant download: $filename"
    fi
done

echo ""
echo "Clear temp dir"
rm -rf "$TEMP_DIR"
}
echo "Install apks done!"
