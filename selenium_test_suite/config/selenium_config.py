"""
Selenium WebDriver Capabilities & Configuration for PetOrb Web E2E Testing
"""

import os

TARGET_WEB_URL = os.environ.get("TARGET_WEB_URL", "http://localhost:8080")
BACKEND_API_URL = os.environ.get("BACKEND_API_URL", "https://petorb.onrender.com/api")
BROWSER_NAME = "Chrome (Headless)"

CHROME_OPTIONS = [
    "--headless",
    "--disable-gpu",
    "--window-size=1280,800",
    "--no-sandbox",
    "--disable-dev-shm-usage"
]

EXPLICIT_WAIT_TIMEOUT = 10
