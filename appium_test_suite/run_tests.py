"""
Master Runner Script for PetOrb Appium E2E Automation Suite & Excel Analysis Reporter
"""

import sys
import os

# Ensure package paths are added
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from config.appium_config import TARGET_WEB_URL, BACKEND_API_URL
from utils.excel_reporter import ExcelReporter
from pages.auth_page import AuthPage
from pages.owner_dashboard_page import OwnerDashboardPage
from pages.pet_profile_page import PetProfilePage
from pages.sitter_dashboard_page import SitterDashboardPage
from pages.ai_assistant_page import AiAssistantPage
from pages.qr_management_page import QrManagementPage
from tests.test_suite_300 import PetOrbTestSuite300

def main():
    print("\n==========================================================================")
    print("      PETORB APPIUM AUTOMATION FRAMEWORK & EXCEL REPORT GENERATOR")
    print(f"      Target Web Application: {TARGET_WEB_URL}")
    print(f"      Backend API Endpoint:  {BACKEND_API_URL}")
    print("==========================================================================\n")

    driver = None # Mock/Appium Web Driver Context

    # Initialize POMs
    auth_page = AuthPage(driver)
    owner_page = OwnerDashboardPage(driver)
    pet_page = PetProfilePage(driver)
    sitter_page = SitterDashboardPage(driver)
    ai_page = AiAssistantPage(driver)
    qr_page = QrManagementPage(driver)

    # Initialize Reporter
    reporter = ExcelReporter(output_dir=os.path.join(os.path.dirname(__file__), "reports"))

    # Instantiate and execute 300 test cases
    suite = PetOrbTestSuite300(
        reporter=reporter,
        auth_page=auth_page,
        owner_page=owner_page,
        pet_page=pet_page,
        sitter_page=sitter_page,
        ai_page=ai_page,
        qr_page=qr_page
    )

    suite.run_all_tests()

    # Generate Excel Report
    report_file = reporter.generate_report()

    print("\n--------------------------------------------------------------------------")
    print("EXCEL TEST ANALYSIS REPORT GENERATED SUCCESSFULLY:")
    print(f"File Path: {report_file}")
    print("--------------------------------------------------------------------------\n")

if __name__ == "__main__":
    main()
