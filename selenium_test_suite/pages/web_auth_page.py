"""
Web Authentication Page Object Model (POM) for Sign Up, Login, Password Rules & Session State
"""

class WebAuthPage:
    def __init__(self, driver):
        self.driver = driver

    def validate_password_rules(self, password):
        import re
        if len(password) < 6:
            return "Password must be at least 6 characters"
        if not re.search(r'^[a-zA-Z]', password):
            return "Password must start with a letter"
        if not re.search(r'[A-Z]', password):
            return "Password must contain at least one uppercase letter"
        if not re.search(r'[a-z]', password):
            return "Password must contain at least one lowercase letter"
        if not re.search(r'[0-9]', password):
            return "Password must contain at least one number"
        if not re.search(r'[!@#$%^&*()_+\-=\[\]{};:\'"\\|,.<>/?]', password):
            return "Password must contain at least one special character"
        return "VALID"

    def enter_credentials(self, email, password):
        print(f"[POM WebAuth] Entering credentials: Email={email}")
        return True

    def submit_login(self):
        print("[POM WebAuth] Submitting login form")
        return True

    def submit_signup(self, name, role):
        print(f"[POM WebAuth] Submitting signup form for Name={name}, Role={role}")
        return True
