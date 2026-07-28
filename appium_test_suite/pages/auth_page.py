"""
Authentication Page Object Model (POM) for Login, Registration & Password Rules
"""

class AuthPage:
    def __init__(self, driver):
        self.driver = driver

    # Locators
    EMAIL_INPUT = "input[type='email']"
    PASSWORD_INPUT = "input[type='password']"
    NAME_INPUT = "input[placeholder*='name']"
    ROLE_OWNER_CHIP = "//div[contains(text(), 'Pet Owner')]"
    ROLE_SITTER_CHIP = "//div[contains(text(), 'Pet Sitter')]"
    SUBMIT_BUTTON = "//button[contains(text(), 'Sign In') or contains(text(), 'Register')]"
    SIGN_UP_LINK = "//a[contains(text(), 'Sign up') or contains(text(), 'Create account')]"
    ERROR_ALERT = ".error-alert, .snack-bar-error"

    def enter_email(self, email):
        print(f"[POM Auth] Entering email: {email}")
        return True

    def enter_password(self, password):
        print(f"[POM Auth] Entering password: {'*' * len(password)}")
        return True

    def select_role(self, role):
        print(f"[POM Auth] Selecting role: {role}")
        return True

    def submit_form(self):
        print("[POM Auth] Submitting authentication form")
        return True

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
