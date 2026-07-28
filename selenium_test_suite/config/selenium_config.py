"""
Selenium WebDriver Capabilities & Configuration for PetOrb Web E2E Testing
"""

import os

TARGET_WEB_URL = os.environ.get("TARGET_WEB_URL", "http://localhost:8080")
BACKEND_API_URL = os.environ.get("BACKEND_API_URL", "https://petorb.onrender.com/api")
BROWSER_NAME = "Google Chrome (Interactive GUI)"

CHROME_OPTIONS = [
    "--start-maximized",
    "--window-size=1366,768",
    "--disable-gpu",
    "--no-sandbox",
    "--disable-dev-shm-usage"
]

EXPLICIT_WAIT_TIMEOUT = 10
