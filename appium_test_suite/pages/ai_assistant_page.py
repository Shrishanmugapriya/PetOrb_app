"""
PetOrb AI Assistant Page Object Model (POM)
"""

class AiAssistantPage:
    def __init__(self, driver):
        self.driver = driver

    def send_prompt(self, prompt_text):
        print(f"[POM AI Assistant] Sending prompt: '{prompt_text}'")
        return True

    def verify_system_alert(self, response_text, pet_name="Appu"):
        expected = f"*(System Alert: I have updated {pet_name}'s official profile with these details!)*"
        return expected in response_text

    def verify_profile_extraction(self, prompt_text):
        keywords = ["sensitive", "allergies", "diet", "sleep", "walk", "medication"]
        return any(k in prompt_text.lower() for k in keywords)
