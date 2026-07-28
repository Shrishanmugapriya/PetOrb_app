"""
Web Owner Dashboard & Pet Management Page Object Model (POM)
"""

class WebOwnerDashboardPage:
    def __init__(self, driver):
        self.driver = driver

    def create_pet(self, name, species, breed, age, gender, weight):
        print(f"[POM OwnerDashboard] Creating pet: {name}, {species}, {breed}, {age}yrs, {weight}kg")
        return True

    def edit_pet(self, pet_id, new_weight, new_vet_name):
        print(f"[POM OwnerDashboard] Editing pet {pet_id}: Weight={new_weight}kg, Vet={new_vet_name}")
        return True

    def delete_pet(self, pet_id):
        print(f"[POM OwnerDashboard] Deleting pet {pet_id}")
        return True

    def search_pets(self, query):
        print(f"[POM OwnerDashboard] Searching pet list for query: '{query}'")
        return True
