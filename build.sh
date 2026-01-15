#!/bin/bash

APP_NAME="Highway To-Do"
APP_BUNDLE="$APP_NAME.app"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Compile
swiftc -o "$APP_BUNDLE/Contents/MacOS/$APP_NAME" \
    HighwayTodoApp.swift \
    TaskModel.swift \
    TaskViewModel.swift \
    ContentView.swift \
    SettingsManager.swift \
    LocalizationManager.swift \
    SettingsView.swift

# Copy Assets
cp menubar_icon.png "$APP_BUNDLE/Contents/Resources/menubar_icon.png"
cp app_icon.png "$APP_BUNDLE/Contents/Resources/app_icon.png"

# Copy Info.plist
cp Info.plist "$APP_BUNDLE/Contents/Info.plist"

echo "Build complete: $APP_BUNDLE"
