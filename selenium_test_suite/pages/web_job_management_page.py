"""
Web Job Management Page Object Model (POM)
"""

class WebJobManagementPage:
    def __init__(self, driver):
        self.driver = driver

    def create_job(self, title, pay_rate, pet_id, dates):
        print(f"[POM JobManagement] Creating sitting job: '{title}', Rate=INR {pay_rate}/hr, Pet={pet_id}")
        return True

    def accept_application(self, job_id, sitter_id):
        print(f"[POM JobManagement] Owner accepting sitter application {sitter_id} for job {job_id}")
        return True

    def reject_application(self, job_id, sitter_id):
        print(f"[POM JobManagement] Owner rejecting sitter application {sitter_id} for job {job_id}")
        return True

    def complete_job(self, job_id):
        print(f"[POM JobManagement] Sitter completing job {job_id}")
        return True
