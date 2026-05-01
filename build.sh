#!/bin/bash
set -euo pipefail

APP_NAME="Highway To-Do"
APP_BUNDLE="$APP_NAME.app"
MIN_OS="26.0"
ARCH=$(uname -m)   # arm64 on Apple Silicon, x86_64 on Intel

mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

echo "Building for $ARCH, macOS $MIN_OS..."

swiftc \
    -swift-version 6 \
    -target "$ARCH-apple-macos$MIN_OS" \
    -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    HighwayTodoApp.swift \
    TaskModel.swift \
    TaskViewModel.swift \
    ContentView.swift \
    SettingsManager.swift \
    LocalizationManager.swift \
    SettingsView.swift

cp menubar_icon.png "$APP_BUNDLE/Contents/Resources/menubar_icon.png"
cp app_icon.png     "$APP_BUNDLE/Contents/Resources/app_icon.png"
cp Info.plist       "$APP_BUNDLE/Contents/Info.plist"

echo "Build complete: $APP_BUNDLE"
