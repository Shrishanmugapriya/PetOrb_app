"""
Appium Desired Capabilities and Environment Configuration for PetOrb E2E Automation
"""

import os

APPIUM_SERVER_URL = os.environ.get("APPIUM_SERVER_URL", "http://127.0.0.1:4723")
TARGET_WEB_URL = os.environ.get("TARGET_WEB_URL", "http://localhost:8080")
BACKEND_API_URL = os.environ.get("BACKEND_API_URL", "https://petorb.onrender.com/api")

# Android Native & Hybrid Appium Capabilities
ANDROID_CAPABILITIES = {
    "platformName": "Android",
    "automationName": "UiAutomator2",
    "deviceName": "Android Emulator",
    "appPackage": "com.petorb.petorb_app",
    "appActivity": ".MainActivity",
    "noReset": False,
    "fullReset": False,
    "newCommandTimeout": 300,
}

# iOS Native & Hybrid Appium Capabilities
IOS_CAPABILITIES = {
    "platformName": "iOS",
    "automationName": "XCUITest",
    "deviceName": "iPhone 15 Pro",
    "bundleId": "com.example.petorbApp",
    "noReset": False,
    "newCommandTimeout": 300,
}

# Flutter Web & Cross-Platform Driver Capabilities
CHROME_WEB_CAPABILITIES = {
    "browserName": "chrome",
    "platformName": "Windows",
    "goog:chromeOptions": {
        "args": ["--headless", "--disable-gpu", "--window-size=1280,800", "--no-sandbox"]
    }
}
