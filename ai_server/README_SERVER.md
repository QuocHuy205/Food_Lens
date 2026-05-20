# Food AI Server

FastAPI backend cho Food Lens. Server nhận ảnh từ Flutter, chạy TensorFlow inference, và trả về món ăn cùng calories/nutrition. Luồng hiện tại có 2 cách gọi chính:

- `POST /predict`: nhận ảnh multipart trực tiếp
- `POST /analyze`: nhận `image_url` từ Cloudinary, server tải ảnh về rồi phân tích

## Cấu trúc hiện tại

```text
ai_server/
├── main.py
├── config.py
├── inference.py
├── schemas.py
├── nutrition_db.py
├── train.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── data/
│   └── images/
├── models/
│   ├── model_v1.h5
│   ├── model_v1.tflite
│   └── classes.json
└── logs/
```

## File chính

- `main.py`: FastAPI app, CORS, startup, `/health`, `/predict`, `/analyze`
- `inference.py`: load model, preprocess ảnh, infer, tính nutrition
- `config.py`: đường dẫn, tham số model, timeout, host/port
- `schemas.py`: Pydantic request/response models
- `nutrition_db.py`: database dinh dưỡng
- `train.py`: pipeline train model từ `data/images/`

## Chuẩn bị môi trường

### 1. Tạo venv

```bash
cd ai_server
python -m venv .venv311
```

### 2. Kích hoạt venv trên Windows

```bash
.\.venv311\Scripts\activate
```

### 3. Cài dependencies

```bash
python -m pip install -r requirements.txt
```

### 4. Tạo file `.env`

Copy từ `.env.example` rồi chỉnh các giá trị cần thiết, ví dụ:

```env
SERVER_HOST=0.0.0.0
SERVER_PORT=8000
DEBUG=False
AI_API_BASE_URL=http://10.0.2.2:8000
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_UPLOAD_PRESET=your-upload-preset
```

## Chạy server

### Cách khuyến nghị trên Windows

```bash
cd d:\CaloriesAI\food_lens\ai_server
.\.venv311\Scripts\uvicorn.exe main:app --app-dir d:\CaloriesAI\food_lens\ai_server --host 0.0.0.0 --port 8000
```

### Cách khác

```bash
python main.py
```

## API đang dùng

### Health check

```bash
GET /health
```

### Predict trực tiếp bằng file ảnh

```bash
POST /predict
```

Form-data:

- key: `image`
- value: file ảnh

### Analyze từ Cloudinary URL

```bash
POST /analyze
```

Body JSON:

```json
{
  "image_url": "https://res.cloudinary.com/.../image.jpg"
}
```

## Kết quả trả về

Cả hai endpoint đều trả về object dạng:

```json
{
  "success": true,
  "data": {
    "food_name": "banh_beo",
    "food_name_vi": "Món ăn hỗn hợp",
    "confidence": 0.678223,
    "calories_estimated": 360.0,
    "portion_grams": 300,
    "nutrition": {
      "protein_g": 18.0,
      "carbs_g": 45.0,
      "fat_g": 12.0,
      "fiber_g": 3.0
    },
    "top_predictions": [],
    "inference_time_ms": 123.01,
    "response_time_ms": 123.03,
    "model_version": "food_model.h5",
    "input_size": 224
  },
  "error": null
}
```

## Train model

Dataset train nằm ở `data/images/`, mỗi class là một folder riêng.

```bash
cd d:\CaloriesAI\food_lens\ai_server
$env:EPOCHS='15'
.\.venv311\Scripts\python.exe train.py
```

Kết quả train sẽ lưu vào:

- `models/model_v1.h5`
- `models/model_v1.tflite`
- `models/classes.json`

`train.py` đã được tối ưu cho GPU và mixed precision, nên nếu máy có NVIDIA GPU phù hợp thì train sẽ nhanh hơn.

## Docker

### Build

```bash
docker build -t food-ai-server .
```

### Run

```bash
docker run -p 8000:8000 --env-file .env food-ai-server
```

### Docker Compose

```bash
docker-compose up --build
```

## Flutter integration

Flutter app đang dùng 2 luồng:

- upload file ảnh rồi gọi `/predict`
- upload Cloudinary rồi gọi `/analyze`

Cấu hình URL server nằm trong `.env` của app qua `AI_API_BASE_URL` hoặc `AI_SERVER_URL`.

## Troubleshooting nhanh

- Nếu server không lên, kiểm tra model trong `models/model_v1.h5` và `models/classes.json`
- Nếu `/analyze` lỗi, kiểm tra `CLOUDINARY_CLOUD_NAME` và `CLOUDINARY_UPLOAD_PRESET`
- Nếu Flutter chạy trên emulator Android, dùng `http://10.0.2.2:8000`
- Nếu muốn xem docs API, mở `http://localhost:8000/docs`

## Ghi chú

- Không cần sửa logic inference nếu server đang chạy ổn.
- Ưu tiên giữ `main.py`, `inference.py`, `config.py`, `schemas.py`, `nutrition_db.py`, `train.py`, `models/`, `data/`.
- Các file test cũ và cache chỉ nên giữ nếu còn thật sự cần cho debugging.
