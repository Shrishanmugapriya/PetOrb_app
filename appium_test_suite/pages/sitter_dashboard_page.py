"""
Sitter Dashboard Page Object Model (POM)
"""

class SitterDashboardPage:
    def __init__(self, driver):
        self.driver = driver

    def get_profile_banner(self, experience="", rate=0.0):
        if not experience and rate <= 0:
            return "Update profile to add experience & rate"
        return f"Experience: {experience} • Rate: ₹{int(rate)}/hr"

    def get_welcome_title(self, is_new_user=False, name="Sitter"):
        if is_new_user:
            return f"Welcome to PetOrb, {name}! 🙋‍♂️"
        return f"Welcome back, {name}! 🙋‍♂️"

    def check_skills_and_verification(self, skills=None, certifications=""):
        if not skills:
            skills_text = "No skills listed yet. Update your profile settings to add your skills."
        else:
            skills_text = ", ".join(skills)
        cert_text = f"Certifications: {certifications if certifications else 'Not specified'}"
        return f"{cert_text} | {skills_text}"

    def check_sitting_history(self, history=None):
        if not history:
            return "No sitting history yet. Complete sitting assignments to earn ratings and reviews!"
        return f"History count: {len(history)}"
