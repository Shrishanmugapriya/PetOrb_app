"""
Web PetOrb AI Assistant Page Object Model (POM)
"""

class WebAiAssistantPage:
    def __init__(self, driver):
        self.driver = driver

    def send_prompt(self, prompt_text):
        print(f"[POM WebAI] Sending prompt: '{prompt_text}'")
        return True

    def verify_system_alert(self, response_text, pet_name="Appu"):
        expected = f"*(System Alert: I have updated {pet_name}'s official profile with these details!)*"
        return expected in response_text
