"""
Web QR Code & Access Security Page Object Model (POM)
"""

class WebQrPage:
    def __init__(self, driver):
        self.driver = driver

    def generate_sitter_qr(self, pet_id, sitter_id):
        return f"QR_SITTER_{pet_id[:4]}_{sitter_id[:4]}"

    def generate_lost_pet_qr(self, pet_id):
        return f"https://petorb.onrender.com/api/qr/scan/lost/{pet_id}"
