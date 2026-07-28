"""
Master CLI Runner for PetOrb Selenium Web E2E Test Suite & 5-Sheet Excel Analysis Report
"""

import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from config.selenium_config import TARGET_WEB_URL, BACKEND_API_URL, BROWSER_NAME
from utils.excel_5sheet_reporter import Excel5SheetReporter
from pages.web_auth_page import WebAuthPage
from pages.web_owner_dashboard_page import WebOwnerDashboardPage
from pages.web_sitter_dashboard_page import WebSitterDashboardPage
from pages.web_job_management_page import WebJobManagementPage
from pages.web_ai_assistant_page import WebAiAssistantPage
from pages.web_qr_page import WebQrPage
from tests.test_suite_selenium import PetOrbSeleniumTestSuite

def main():
    print("==========================================================================")
    print("      PETORB SELENIUM E2E WEB AUTOMATION SUITE & EXCEL REPORTER")
    print(f"      Target Web Application: {TARGET_WEB_URL}")
    print(f"      Backend API Endpoint:  {BACKEND_API_URL}")
    print(f"      Target Browser:        {BROWSER_NAME}")
    print("==========================================================================\n")

    driver = None # Selenium WebDriver Context

    # Initialize POMs
    auth_page = WebAuthPage(driver)
    owner_page = WebOwnerDashboardPage(driver)
    sitter_page = WebSitterDashboardPage(driver)
    job_page = WebJobManagementPage(driver)
    ai_page = WebAiAssistantPage(driver)
    qr_page = WebQrPage(driver)

    # Initialize 5-Sheet Excel Reporter
    test_reports_dir = os.path.join(os.path.dirname(__file__), "TestReports")
    reporter = Excel5SheetReporter(output_dir=test_reports_dir)

    # Instantiate and execute Selenium test suite
    suite = PetOrbSeleniumTestSuite(
        driver=driver,
        reporter=reporter,
        auth_page=auth_page,
        owner_page=owner_page,
        sitter_page=sitter_page,
        job_page=job_page,
        ai_page=ai_page,
        qr_page=qr_page
    )

    suite.run_all()

    # Generate 5-Sheet Excel Report
    report_file = reporter.generate_report()

    print("\n--------------------------------------------------------------------------")
    print("PETORB SELENIUM EXCEL ANALYSIS REPORT GENERATED SUCCESSFULLY:")
    print(f"File Path: {report_file}")
    print("--------------------------------------------------------------------------\n")

if __name__ == "__main__":
    main()
