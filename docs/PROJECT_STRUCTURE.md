# 📁 PROJECT STRUCTURE — Cây thư mục đầy đủ

```
food_ai_app/
├── lib/
│   ├── main.dart                          ← Entry point, Firebase init
│   ├── firebase_options.dart              ← Auto-generated bởi FlutterFire CLI
│   │
│   ├── core/                              ← Dùng chung toàn app
│   │   ├── config/
│   │   │   └── app_config.dart            ← API keys, URLs
│   │   ├── errors/
│   │   │   ├── failure.dart               ← Abstract Failure classes
│   │   │   └── exceptions.dart            ← Custom exceptions
│   │   ├── extensions/
│   │   │   ├── datetime_ext.dart
│   │   │   └── string_ext.dart
│   │   ├── router/
│   │   │   └── app_router.dart            ← go_router config
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── tdee_calculator.dart       ← Tính TDEE từ BMI
│   │   │   └── calorie_formatter.dart
│   │   └── widgets/                       ← Shared widgets
│   │       ├── loading_overlay.dart
│   │       ├── error_widget.dart
│   │       └── calorie_progress_bar.dart
│   │
│   └── features/
│       │
│       ├── auth/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── user_model.dart
│       │   │   └── repositories/
│       │   │       └── auth_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user_entity.dart
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── usecases/
│       │   │       ├── login_usecase.dart
│       │   │       ├── register_usecase.dart
│       │   │       └── logout_usecase.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── auth_provider.dart
│       │       └── screens/
│       │           ├── splash_screen.dart
│       │           ├── login_screen.dart
│       │           └── register_screen.dart
│       │
│       ├── scan/
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   ├── ai_remote_datasource.dart
│       │   │   │   └── cloudinary_datasource.dart
│       │   │   ├── models/
│       │   │   │   ├── scan_result_model.dart
│       │   │   │   └── scan_history_model.dart
│       │   │   └── repositories/
│       │   │       └── scan_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   ├── scan_result.dart
│       │   │   │   └── scan_history.dart
│       │   │   ├── repositories/
│       │   │   │   └── scan_repository.dart
│       │   │   └── usecases/
│       │   │       ├── upload_image_usecase.dart
│       │   │       ├── analyze_food_usecase.dart
│       │   │       └── save_scan_history_usecase.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── scan_provider.dart
│       │       └── screens/
│       │           ├── scan_screen.dart
│       │           └── scan_result_screen.dart
│       │
│       ├── nutrition/
│       │   ├── data/
│       │   │   ├── datasources/
│       │   │   │   └── nutrition_datasource.dart
│       │   │   ├── models/
│       │   │   │   └── daily_log_model.dart
│       │   │   └── repositories/
│       │   │       └── nutrition_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── daily_log.dart
│       │   │   ├── repositories/
│       │   │   │   └── nutrition_repository.dart
│       │   │   └── usecases/
│       │   │       ├── get_daily_log_usecase.dart
│       │   │       ├── update_daily_log_usecase.dart
│       │   │       └── get_weekly_summary_usecase.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── nutrition_provider.dart
│       │       └── screens/
│       │           └── stats_screen.dart
│       │
│       ├── profile/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── user_profile_model.dart
│       │   │   └── repositories/
│       │   │       └── profile_repository_impl.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user_profile.dart
│       │   │   ├── repositories/
│       │   │   │   └── profile_repository.dart
│       │   │   └── usecases/
│       │   │       ├── get_profile_usecase.dart
│       │   │       └── update_profile_usecase.dart
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── profile_provider.dart
│       │       └── screens/
│       │           ├── profile_screen.dart
│       │           └── edit_profile_screen.dart
│       │
│       ├── history/
│       │   └── presentation/
│       │       ├── providers/
│       │       │   └── history_provider.dart
│       │       └── screens/
│       │           └── history_screen.dart
│       │
│       └── home/
│           └── presentation/
│               ├── widgets/
│               │   ├── home_shell.dart       ← Bottom nav shell
│               │   ├── calorie_summary_card.dart
│               │   └── recent_scans_list.dart
│               └── screens/
│                   └── home_screen.dart
│
├── test/
│   ├── unit/
│   │   └── features/
│   │       ├── auth/
│   │       ├── scan/
│   │       └── nutrition/
│   ├── widget/
│   └── mocks/
│       └── mock_repositories.dart
│
├── ai_server/                             ← Python mock AI server (ngoài Flutter)
│   ├── main.py
│   ├── mock_data.py
│   └── requirements.txt
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Quy tắc đặt tên file

| Loại | Pattern | Ví dụ |
|------|---------|-------|
| Screen | `[name]_screen.dart` | `scan_screen.dart` |
| Widget | `[name]_widget.dart` hoặc `[name]_card.dart` | `calorie_card.dart` |
| Model | `[name]_model.dart` | `scan_result_model.dart` |
| Entity | `[name].dart` hoặc `[name]_entity.dart` | `scan_result.dart` |
| UseCase | `[verb]_[noun]_usecase.dart` | `analyze_food_usecase.dart` |
| Repository | `[name]_repository.dart` | `scan_repository.dart` |
| Provider | `[name]_provider.dart` | `scan_provider.dart` |
