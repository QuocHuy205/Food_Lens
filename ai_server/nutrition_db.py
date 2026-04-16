"""
Vietnamese Food Nutrition Database
Thay vì hardcode, bạn có thể load từ JSON sau này
"""

NUTRITION_DATABASE = {
    "pho": {
        "name_vi": "Phở bò",
        "calories_per_100g": 75,
        "default_portion": 400,
        "nutrition_per_100g": {
            "protein_g": 7.5,
            "carbs_g": 9,
            "fat_g": 1.5,
            "fiber_g": 0.5
        }
    },
    "banh_mi": {
        "name_vi": "Bánh mì",
        "calories_per_100g": 265,
        "default_portion": 150,
        "nutrition_per_100g": {
            "protein_g": 9,
            "carbs_g": 50,
            "fat_g": 5,
            "fiber_g": 2
        }
    },
    "com_tam": {
        "name_vi": "Cơm tấm",
        "calories_per_100g": 160,
        "default_portion": 300,
        "nutrition_per_100g": {
            "protein_g": 8,
            "carbs_g": 30,
            "fat_g": 4,
            "fiber_g": 1
        }
    },
    "bun_bo": {
        "name_vi": "Bún bò Huế",
        "calories_per_100g": 68,
        "default_portion": 450,
        "nutrition_per_100g": {
            "protein_g": 6,
            "carbs_g": 8,
            "fat_g": 2,
            "fiber_g": 0.5
        }
    },
    "goi_cuon": {
        "name_vi": "Gỏi cuốn",
        "calories_per_100g": 89,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 5,
            "carbs_g": 12,
            "fat_g": 1.5,
            "fiber_g": 1
        }
    },
    "salad": {
        "name_vi": "Salad",
        "calories_per_100g": 15,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 1,
            "carbs_g": 2,
            "fat_g": 0.2,
            "fiber_g": 2
        }
    },
    "canh_chua": {
        "name_vi": "Canh chua",
        "calories_per_100g": 30,
        "default_portion": 350,
        "nutrition_per_100g": {
            "protein_g": 2,
            "carbs_g": 3,
            "fat_g": 1,
            "fiber_g": 0.8
        }
    },
    "nem": {
        "name_vi": "Nem chiên",
        "calories_per_100g": 240,
        "default_portion": 120,
        "nutrition_per_100g": {
            "protein_g": 10,
            "carbs_g": 20,
            "fat_g": 12,
            "fiber_g": 0.5
        }
    },
}

# Default fallback
DEFAULT_FOOD = {
    "name_vi": "Món ăn hỗn hợp",
    "calories_per_100g": 120,
    "default_portion": 300,
    "nutrition_per_100g": {
        "protein_g": 6,
        "carbs_g": 15,
        "fat_g": 4,
        "fiber_g": 1
    }
}


def get_nutrition_by_name(food_name: str) -> dict:
    """Get nutrition info by food name"""
    key = food_name.lower().replace(" ", "_")
    return NUTRITION_DATABASE.get(key, DEFAULT_FOOD)


def calculate_nutrition(food_data: dict, portion_grams: int = None) -> dict:
    """Calculate nutrition for specific portion"""
    if portion_grams is None:
        portion_grams = food_data.get("default_portion", 300)
    
    per_100g = food_data.get("nutrition_per_100g", DEFAULT_FOOD["nutrition_per_100g"])
    multiplier = portion_grams / 100
    
    return {
        "protein_g": round(per_100g["protein_g"] * multiplier, 1),
        "carbs_g": round(per_100g["carbs_g"] * multiplier, 1),
        "fat_g": round(per_100g["fat_g"] * multiplier, 1),
        "fiber_g": round(per_100g["fiber_g"] * multiplier, 1),
    }
