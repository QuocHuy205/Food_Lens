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
    "ga_ran": {
        "name_vi": "Gà rán",
        "calories_per_100g": 280,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 26,
            "carbs_g": 12,
            "fat_g": 14,
            "fiber_g": 0
        }
    },
    "pizza": {
        "name_vi": "Pizza",
        "calories_per_100g": 285,
        "default_portion": 300,
        "nutrition_per_100g": {
            "protein_g": 12,
            "carbs_g": 36,
            "fat_g": 10,
            "fiber_g": 2
        }
    },
    "burger": {
        "name_vi": "Burger",
        "calories_per_100g": 250,
        "default_portion": 250,
        "nutrition_per_100g": {
            "protein_g": 13,
            "carbs_g": 28,
            "fat_g": 10,
            "fiber_g": 1
        }
    },
    "mi_xao": {
        "name_vi": "Mì xào",
        "calories_per_100g": 155,
        "default_portion": 300,
        "nutrition_per_100g": {
            "protein_g": 6,
            "carbs_g": 22,
            "fat_g": 5,
            "fiber_g": 1.5
        }
    },
    "hu_tieu": {
        "name_vi": "Hủ tiếu",
        "calories_per_100g": 60,
        "default_portion": 400,
        "nutrition_per_100g": {
            "protein_g": 5,
            "carbs_g": 8,
            "fat_g": 1.5,
            "fiber_g": 0.8
        }
    },
    "banh_canh": {
        "name_vi": "Bánh canh",
        "calories_per_100g": 95,
        "default_portion": 350,
        "nutrition_per_100g": {
            "protein_g": 6,
            "carbs_g": 14,
            "fat_g": 2.5,
            "fiber_g": 1
        }
    },
    "lau": {
        "name_vi": "Lẩu",
        "calories_per_100g": 85,
        "default_portion": 500,
        "nutrition_per_100g": {
            "protein_g": 8,
            "carbs_g": 6,
            "fat_g": 3,
            "fiber_g": 1
        }
    },
    "nuoc_mam_tom": {
        "name_vi": "Mưỡng bợp/Mắm tôm",
        "calories_per_100g": 110,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 18,
            "carbs_g": 2,
            "fat_g": 3,
            "fiber_g": 0
        }
    },
    "trang_bang": {
        "name_vi": "Trăng bàng",
        "calories_per_100g": 70,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 3,
            "carbs_g": 10,
            "fat_g": 2,
            "fiber_g": 1
        }
    },
    "banh_xeo": {
        "name_vi": "Bánh xèo",
        "calories_per_100g": 180,
        "default_portion": 250,
        "nutrition_per_100g": {
            "protein_g": 8,
            "carbs_g": 25,
            "fat_g": 6,
            "fiber_g": 1
        }
    },
    "canh_ga": {
        "name_vi": "Canh gà",
        "calories_per_100g": 45,
        "default_portion": 350,
        "nutrition_per_100g": {
            "protein_g": 5,
            "carbs_g": 2,
            "fat_g": 2,
            "fiber_g": 0.5
        }
    },
    "ca_kho": {
        "name_vi": "Cá kho tộ",
        "calories_per_100g": 165,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 22,
            "carbs_g": 2,
            "fat_g": 8,
            "fiber_g": 0
        }
    },
    "thang_co": {
        "name_vi": "Thắng cô",
        "calories_per_100g": 155,
        "default_portion": 300,
        "nutrition_per_100g": {
            "protein_g": 18,
            "carbs_g": 5,
            "fat_g": 7,
            "fiber_g": 0
        }
    },
    "tay_cam": {
        "name_vi": "Tay cầm",
        "calories_per_100g": 95,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 8,
            "carbs_g": 10,
            "fat_g": 3,
            "fiber_g": 0.5
        }
    },
    "sua_dau_nanh": {
        "name_vi": "Sữa đậu nành",
        "calories_per_100g": 54,
        "default_portion": 250,
        "nutrition_per_100g": {
            "protein_g": 3.3,
            "carbs_g": 1.8,
            "fat_g": 3.3,
            "fiber_g": 0.5
        }
    },
    "trai_ngu": {
        "name_vi": "Trái ngũ",
        "calories_per_100g": 120,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 3,
            "carbs_g": 28,
            "fat_g": 0.5,
            "fiber_g": 2
        }
    },
    "hai_san": {
        "name_vi": "Hải sản",
        "calories_per_100g": 95,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 20,
            "carbs_g": 1,
            "fat_g": 1,
            "fiber_g": 0
        }
    },
    "rau_xanh": {
        "name_vi": "Rau xanh",
        "calories_per_100g": 25,
        "default_portion": 150,
        "nutrition_per_100g": {
            "protein_g": 2.5,
            "carbs_g": 3,
            "fat_g": 0.3,
            "fiber_g": 2
        }
    },
    "trai_cay": {
        "name_vi": "Trái cây",
        "calories_per_100g": 60,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 1,
            "carbs_g": 14,
            "fat_g": 0.5,
            "fiber_g": 2
        }
    },
    "caffe": {
        "name_vi": "Cà phê",
        "calories_per_100g": 2,
        "default_portion": 250,
        "nutrition_per_100g": {
            "protein_g": 0.2,
            "carbs_g": 0,
            "fat_g": 0,
            "fiber_g": 0
        }
    },
    "nuoc_ep": {
        "name_vi": "Nước ép",
        "calories_per_100g": 45,
        "default_portion": 250,
        "nutrition_per_100g": {
            "protein_g": 0.5,
            "carbs_g": 11,
            "fat_g": 0,
            "fiber_g": 0.5
        }
    },
    "moong_bean": {
        "name_vi": "Mung bean",
        "calories_per_100g": 95,
        "default_portion": 200,
        "nutrition_per_100g": {
            "protein_g": 9,
            "carbs_g": 17,
            "fat_g": 0.3,
            "fiber_g": 6
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
    # If we already have a DB entry, return it
    if key in NUTRITION_DATABASE:
        return NUTRITION_DATABASE[key]

    # Otherwise generate a reasonable entry dynamically based on keywords
    generated = _generate_nutrition_for_key(key)
    # Cache generated entry so future calls are fast and consistent
    NUTRITION_DATABASE[key] = generated
    return generated


def _humanize_key(key: str) -> str:
    """Convert class key like 'bun_dau_mam_tom' -> 'Bún đậu mắm tôm' with common replacements."""
    exceptions = {
        'bun_dau_mam_tom': 'Bún đậu mắm tôm',
        'banh_mi': 'Bánh mì',
        'bun_bo_hue': 'Bún bò Huế',
        'com_tam': 'Cơm tấm',
        'banh_xeo': 'Bánh xèo',
        'mi_xao': 'Mì xào',
        'hu_tieu': 'Hủ tiếu',
        'banh_canh': 'Bánh canh',
        'goi_cuon': 'Gỏi cuốn',
        'banh_beo': 'Bánh bèo',
        'banh_bao': 'Bánh bao',
        'banh_gio': 'Bánh giò',
        'com_chien': 'Cơm chiên',
        'ga_chien_nuoc_mam': 'Gà chiên nước mắm',
        'bun_rieu': 'Bún riêu',
        'mi_quang': 'Mì Quảng',
        'cao_lau': 'Cao lầu',
        'banh_trang_nuong': 'Bánh tráng nướng',
        'pho': 'Phở'
    }

    if key in exceptions:
        return exceptions[key]

    parts = key.split('_')
    replacements = {
        'banh': 'Bánh',
        'bun': 'Bún',
        'com': 'Cơm',
        'pho': 'Phở',
        'mi': 'Mì',
        'ga': 'Gà',
        'ca': 'Cá',
        'canh': 'Canh',
        'hu': 'Hủ',
        'tieu': 'tiếu',
        'xao': 'xào',
        'ran': 'rán',
        'chien': 'chiên',
        'nuong': 'nướng',
        'sot': 'sốt',
        'thit': 'thịt',
        'mam': 'mắm',
        'tom': 'tôm'
    }

    human_words = []
    for p in parts:
        if p in replacements:
            human_words.append(replacements[p])
        else:
            # fallback: capitalize first letter
            human_words.append(p.capitalize())

    # Join with spaces and normalize spacing/dashes
    name = ' '.join(human_words)
    # Minor cleanup: fix sequences like 'Hủ tiếu' produced from ['hu','tieu']
    name = name.replace('Hủ tiếu', 'Hủ tiếu')
    return name


def _estimate_macros_and_calories(key: str) -> tuple:
    """Heuristic estimator that returns (cal_per_100g, macros_dict).
    Uses keyword matching to assign reasonable defaults.
    """
    k = key.lower()

    # Base categories
    if any(w in k for w in ('banh', 'pizza', 'burger', 'xeo', 'nem', 'banh_mi', 'com_chien')):
        # baked/fried doughy items
        cal = 230
        macros = {'protein_g': 8, 'carbs_g': 30, 'fat_g': 10, 'fiber_g': 1}
    elif any(w in k for w in ('bun', 'pho', 'mi', 'hu_tieu', 'cao_lau', 'mi_quang', 'bun_rieu', 'hu')):
        # noodle soups / bowls
        cal = 85
        macros = {'protein_g': 6, 'carbs_g': 12, 'fat_g': 2, 'fiber_g': 1}
    elif any(w in k for w in ('com', 'cơm', 'com_tam', 'com_rang', 'com_chien')):
        cal = 160
        macros = {'protein_g': 7.5, 'carbs_g': 28, 'fat_g': 4.5, 'fiber_g': 1}
    elif any(w in k for w in ('ga', 'thit', 'heo', 'bo', 'ca')):
        cal = 150
        macros = {'protein_g': 20, 'carbs_g': 1.5, 'fat_g': 7, 'fiber_g': 0}
    elif any(w in k for w in ('salad', 'rau', 'trai', 'nuoc_ep', 'caffe')):
        cal = 40
        macros = {'protein_g': 2, 'carbs_g': 8, 'fat_g': 0.5, 'fiber_g': 2}
    else:
        # generic fallback
        cal = DEFAULT_FOOD['calories_per_100g']
        macros = DEFAULT_FOOD['nutrition_per_100g']

    return cal, macros


def _generate_nutrition_for_key(key: str) -> dict:
    """Create a generated nutrition entry for unknown class keys."""
    name_vi = _humanize_key(key)
    cal, macros = _estimate_macros_and_calories(key)

    entry = {
        'name_vi': name_vi,
        'calories_per_100g': cal,
        'default_portion': 300,
        'nutrition_per_100g': {
            'protein_g': round(macros['protein_g'], 1),
            'carbs_g': round(macros['carbs_g'], 1),
            'fat_g': round(macros['fat_g'], 1),
            'fiber_g': round(macros.get('fiber_g', 1), 1)
        }
    }

    return entry


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
