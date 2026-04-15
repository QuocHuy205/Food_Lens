import random

# Mock Vietnamese food data
MOCK_FOODS = [
    {"food_name": "Phở", "calories": 350, "confidence": 0.92},
    {"food_name": "Bánh mì", "calories": 280, "confidence": 0.88},
    {"food_name": "Cơm tấm", "calories": 420, "confidence": 0.85},
    {"food_name": "Bún chả", "calories": 480, "confidence": 0.90},
    {"food_name": "Gỏi cuốn", "calories": 120, "confidence": 0.87},
    {"food_name": "Chả giò", "calories": 180, "confidence": 0.89},
    {"food_name": "Cơm chiên", "calories": 520, "confidence": 0.86},
    {"food_name": "Canh chua cá", "calories": 280, "confidence": 0.84},
    {"food_name": "Bún cá cay", "calories": 350, "confidence": 0.83},
    {"food_name": "Mỳ ý", "calories": 450, "confidence": 0.91},
]


def get_mock_food_result():
    """Return random mock food result"""
    return random.choice(MOCK_FOODS)


def get_all_mock_foods():
    """Return all mock foods"""
    return MOCK_FOODS
