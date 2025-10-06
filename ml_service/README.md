# ML Service Setup Instructions

## Prerequisites

- Python 3.8 or higher
- pip package manager

## Quick Setup

1. **Install dependencies:**

   ```bash
   pip install -r requirements.txt
   ```

2. **Start the ML service:**

   ```bash
   python main.py
   ```

   For development with auto-restart:

   ```bash
   uvicorn main:app --reload
   ```

## Features

- **File Analysis** - Analyzes uploaded files and returns predictions
- **FastAPI** - Modern, fast web framework with automatic documentation
- **CORS Support** - Configured for cross-origin requests

## API Endpoints

- `POST /predict` - Analyze uploaded files and return ML predictions

## Customization

Replace the placeholder ML logic in `main.py` with your actual machine learning models:

```python
@app.post("/predict")
async def predict(filename: str = Form(...)):
    # TODO: Replace with actual ML model
    # 1. Load the uploaded file
    # 2. Process with your ML model
    # 3. Return predictions/analysis

    return {"prediction": "positive", "confidence": 0.95, "filename": filename}
```

## Documentation

FastAPI automatically generates API documentation:

- Interactive docs: http://localhost:8000/docs
- OpenAPI schema: http://localhost:8000/openapi.json

Service runs on http://localhost:8000
