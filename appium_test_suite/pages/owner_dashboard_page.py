"""
Owner Dashboard Page Object Model (POM)
"""

class OwnerDashboardPage:
    def __init__(self, driver):
        self.driver = driver

    def get_welcome_title(self, is_new_user=False, name="Owner"):
        if is_new_user:
            return f"Welcome to PetOrb, {name}! 👋"
        return f"Welcome back, {name}! 👋"

    def check_notifications(self, has_alerts=False):
        if not has_alerts:
            return "No new notifications or alerts."
        return "Active notifications present"

    def navigate_to_add_pet(self):
        print("[POM OwnerDashboard] Navigating to Add Pet Profile Screen")
        return True

    def open_ai_assistant(self, pet_name):
        print(f"[POM OwnerDashboard] Opening AI Assistant for {pet_name}")
        return True
