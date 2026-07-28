"""
Real Appium Execution HTML Report Generator for PetOrb Mobile Testing
Creates a standalone HTML report with embedded screenshots, device specs, logs, and Pass/Fail stats.
"""

import os
import datetime

class AppiumHtmlReporter:
    def __init__(self, output_dir="reports"):
        self.output_dir = output_dir
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
        self.file_path = os.path.join(self.output_dir, "Real_Appium_Device_Execution_Report.html")
        self.results = []
        self.device_info = {}
        self.session_info = {}

    def set_device_info(self, device_name, os_version, udid, brand):
        self.device_info = {
            "device_name": device_name,
            "os_version": os_version,
            "udid": udid,
            "brand": brand
        }

    def set_session_info(self, session_id, appium_url, platform_name):
        self.session_info = {
            "session_id": session_id,
            "appium_url": appium_url,
            "platform_name": platform_name
        }

    def add_test_result(self, test_id, module, title, status, duration_ms, screenshot_path="", log_output="", stack_trace="", failure_suggestion=""):
        self.results.append({
            "test_id": test_id,
            "module": module,
            "title": title,
            "status": status,
            "duration_ms": duration_ms,
            "screenshot_path": screenshot_path,
            "log_output": log_output,
            "stack_trace": stack_trace,
            "failure_suggestion": failure_suggestion,
            "timestamp": datetime.datetime.now().strftime("%H:%M:%S")
        })

    def generate(self):
        total = len(self.results)
        passed = sum(1 for r in self.results if r["status"] == "PASS")
        failed = sum(1 for r in self.results if r["status"] == "FAIL")
        skipped = sum(1 for r in self.results if r["status"] == "SKIP")
        pass_rate = (passed / total * 100) if total > 0 else 0

        rows_html = ""
        for r in self.results:
            status_class = "pass" if r["status"] == "PASS" else ("fail" if r["status"] == "FAIL" else "skip")
            
            screenshot_html = ""
            if r["screenshot_path"] and os.path.exists(r["screenshot_path"]):
                rel_path = os.path.relpath(r["screenshot_path"], self.output_dir)
                screenshot_html = f'<a href="{rel_path}" target="_blank"><img src="{rel_path}" class="thumb" alt="Screenshot"/></a>'
            elif r["screenshot_path"]:
                screenshot_html = f'<span class="no-img">Image: {os.path.basename(r["screenshot_path"])}</span>'

            failure_html = ""
            if r["status"] == "FAIL":
                failure_html = f'''
                <div class="failure-box">
                    <strong>Stack Trace:</strong><pre>{r["stack_trace"]}</pre>
                    <strong>Suggested Fix:</strong> <p>{r["failure_suggestion"]}</p>
                </div>
                '''

            rows_html += f'''
            <tr class="{status_class}-row">
                <td><strong>{r["test_id"]}</strong></td>
                <td>{r["module"]}</td>
                <td>{r["title"]}</td>
                <td><span class="badge {status_class}">{r["status"]}</span></td>
                <td>{r["duration_ms"]} ms</td>
                <td>{r["timestamp"]}</td>
                <td>{screenshot_html}</td>
                <td>
                    <div class="log-text">{r["log_output"]}</div>
                    {failure_html}
                </td>
            </tr>
            '''

        html_content = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>PetOrb - Real Appium Mobile Execution Report</title>
    <style>
        body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f6f9; margin: 0; padding: 20px; color: #333; }}
        .container {{ max-width: 1200px; margin: 0 auto; background: #fff; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.08); padding: 25px; }}
        .header {{ background: linear-gradient(135deg, #1f4e78, #2c3e50); color: white; padding: 20px; border-radius: 10px; text-align: center; }}
        .header h1 {{ margin: 0; font-size: 24px; }}
        .header p {{ margin: 5px 0 0 0; opacity: 0.85; font-size: 13px; }}
        
        .meta-grid {{ display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin: 20px 0; }}
        .meta-card {{ background: #f8f9fa; border: 1px solid #e9ecef; border-radius: 8px; padding: 15px; }}
        .meta-card h3 {{ margin-top: 0; font-size: 14px; color: #1f4e78; border-bottom: 2px solid #1f4e78; padding-bottom: 5px; }}
        .meta-card p {{ margin: 4px 0; font-size: 12px; }}
        
        .kpi-row {{ display: flex; gap: 15px; margin-bottom: 20px; }}
        .kpi-card {{ flex: 1; padding: 15px; border-radius: 8px; text-align: center; color: white; font-weight: bold; }}
        .kpi-total {{ background: #34495e; }}
        .kpi-pass {{ background: #27ae60; }}
        .kpi-fail {{ background: #e74c3c; }}
        .kpi-rate {{ background: #2980b9; }}
        .kpi-card .num {{ font-size: 24px; display: block; margin-top: 5px; }}
        
        table {{ width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 12px; }}
        th {{ background: #1f4e78; color: white; padding: 10px; text-align: left; }}
        td {{ padding: 10px; border-bottom: 1px solid #eee; vertical-align: top; }}
        tr:hover {{ background-color: #f9fBFd; }}
        
        .badge {{ padding: 4px 8px; border-radius: 4px; font-weight: bold; font-size: 11px; display: inline-block; }}
        .badge.pass {{ background: #d4edda; color: #155724; }}
        .badge.fail {{ background: #f8d7da; color: #721c24; }}
        .badge.skip {{ background: #fff3cd; color: #856404; }}
        
        .thumb {{ width: 60px; height: 90px; object-fit: cover; border-radius: 4px; border: 1px solid #ccc; transition: transform 0.2s; }}
        .thumb:hover {{ transform: scale(3.5); z-index: 99; position: relative; }}
        .no-img {{ color: #888; font-style: italic; font-size: 10px; }}
        .log-text {{ color: #444; font-family: monospace; font-size: 11px; max-width: 300px; word-break: break-word; }}
        
        .failure-box {{ background: #fff5f5; border-left: 4px solid #e74c3c; padding: 8px; margin-top: 5px; font-size: 11px; }}
        .failure-box pre {{ margin: 3px 0; font-size: 10px; color: #c0392b; overflow-x: auto; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>PetOrb Appium Real Device Automation Report</h1>
            <p>Generated on {datetime.datetime.now().strftime("%B %d, %Y at %I:%M %p")}</p>
        </div>

        <div class="meta-grid">
            <div class="meta-card">
                <h3>📱 Connected Android Device Information</h3>
                <p><strong>Device Model:</strong> {self.device_info.get("device_name", "Android Device")}</p>
                <p><strong>Android OS Version:</strong> {self.device_info.get("os_version", "Android 10+")}</p>
                <p><strong>Brand / Hardware:</strong> {self.device_info.get("brand", "ARM64 Architecture")}</p>
                <p><strong>Device UDID / Serial:</strong> {self.device_info.get("udid", "Connected via USB / ADB")}</p>
            </div>
            <div class="meta-card">
                <h3>⚡ Appium Session & Server Info</h3>
                <p><strong>Appium Server URL:</strong> {self.session_info.get("appium_url", "http://127.0.0.1:4723")}</p>
                <p><strong>Session ID:</strong> {self.session_info.get("session_id", "ACTIVE_SESSION_01")}</p>
                <p><strong>Automation Driver:</strong> UiAutomator2 (Android)</p>
                <p><strong>Target App:</strong> PetOrb Mobile Flutter App</p>
            </div>
        </div>

        <div class="kpi-row">
            <div class="kpi-card kpi-total">Total Executed<span class="num">{total}</span></div>
            <div class="kpi-card kpi-pass">Passed Tests<span class="num">{passed}</span></div>
            <div class="kpi-card kpi-fail">Failed Tests<span class="num">{failed}</span></div>
            <div class="kpi-card kpi-rate">Pass Rate<span class="num">{pass_rate:.1f}%</span></div>
        </div>

        <h2>Granular Real Execution Results</h2>
        <table>
            <thead>
                <tr>
                    <th>Test ID</th>
                    <th>Module</th>
                    <th>Test Title</th>
                    <th>Status</th>
                    <th>Duration</th>
                    <th>Time</th>
                    <th>Screenshot</th>
                    <th>Execution Log & Traceback</th>
                </tr>
            </thead>
            <tbody>
                {rows_html}
            </tbody>
        </table>
    </div>
</body>
</html>
'''
        with open(self.file_path, "w", encoding="utf-8") as f:
            f.write(html_content)
        print(f"[AppiumHtmlReporter] HTML Execution Report generated: {self.file_path}")
        return self.file_path
