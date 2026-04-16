#!/bin/bash
# 🚀 QUICK START — Chạy Toàn Bộ System Ngay

# ===== TERMINAL 1: Chạy Server Python =====
echo "🔧 Terminal 1: Setup Server"
cd ai_server

# Create venv
python -m venv venv

# Activate (Windows)
venv\Scripts\activate
# Activate (Linux/Mac)
# source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run server
echo "🚀 Starting Server..."
python main.py

# Output: INFO: Uvicorn running on http://0.0.0.0:8000
# Keep this terminal open!


# ===== TERMINAL 2: Chạy Flutter App =====
echo "📱 Terminal 2: Run App"
cd ..  # Back to food_lens root

# Get dependencies
flutter pub get

# Run app
echo "🚀 Starting App..."
flutter run

# Output: Running app on emulator/device
# Keep this terminal open!


# ===== TEST SERVER =====
echo "🧪 Terminal 3: Test API"

# Health check
curl -X GET http://localhost:8000/health

# Output:
# {
#   "status": "healthy",
#   "model_loaded": true,
#   "timestamp": "2026-04-16T..."
# }


# ===== SETUP COMPLETE! =====
echo ""
echo "✅ System Running!"
echo ""
echo "Access Points:"
echo "  • App: Running on device/emulator"
echo "  • API: http://localhost:8000"
echo "  • Swagger: http://localhost:8000/docs"
echo "  • Health: http://localhost:8000/health"
