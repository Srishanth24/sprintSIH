from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import pandas as pd
import numpy as np
from typing import List, Dict
import uvicorn
import io
import json
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
import pickle
import os
from datetime import datetime

app = FastAPI(title="Hackathon ML Service", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Global model variables
sentiment_model = None
vectorizer = None


class PredictRequest(BaseModel):
    text: str


class AnalysisResponse(BaseModel):
    sentiment: str
    confidence: float
    timestamp: str


class DataAnalysisResponse(BaseModel):
    summary: Dict
    insights: List[str]
    charts_data: Dict


# Initialize sentiment analysis model
def init_sentiment_model():
    global sentiment_model, vectorizer

    # Sample training data for sentiment analysis
    sample_texts = [
        "I love this product, it's amazing!",
        "This is terrible, I hate it",
        "Great quality and fast delivery",
        "Poor customer service, very disappointed",
        "Excellent value for money",
        "Waste of time and money",
        "Highly recommend this to everyone",
        "Never buying from here again",
        "Outstanding performance and quality",
        "Complete disaster, avoid at all costs",
        "Good product, satisfied with purchase",
        "Not worth the price, overrated",
        "Perfect solution for my needs",
        "Broken on arrival, poor packaging",
        "Exceeded my expectations",
        "Worst purchase I've ever made",
        "Fantastic customer support",
        "Cheap quality, falls apart easily",
        "Best investment I've made",
        "Regret buying this product",
    ]

    labels = [
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
        1,
        0,
    ]  # 1=positive, 0=negative

    # Create and train the model
    vectorizer = TfidfVectorizer(max_features=1000, stop_words="english")
    X = vectorizer.fit_transform(sample_texts)

    sentiment_model = LogisticRegression()
    sentiment_model.fit(X, labels)

    # Save the model
    os.makedirs("models", exist_ok=True)
    with open("models/sentiment_model.pkl", "wb") as f:
        pickle.dump(sentiment_model, f)
    with open("models/vectorizer.pkl", "wb") as f:
        pickle.dump(vectorizer, f)


# Load or initialize model on startup
def load_model():
    global sentiment_model, vectorizer
    try:
        with open("models/sentiment_model.pkl", "rb") as f:
            sentiment_model = pickle.load(f)
        with open("models/vectorizer.pkl", "rb") as f:
            vectorizer = pickle.load(f)
        print("Model loaded successfully")
    except Exception as e:
        print(f"Error loading model: {e}")
        print("Training new sentiment model...")
        init_sentiment_model()
        print("Model trained and saved")


@app.on_event("startup")
async def startup_event():
    load_model()


@app.get("/")
async def root():
    return {"message": "Hackathon ML Service is running!", "version": "1.0.0"}


@app.post("/predict/sentiment", response_model=AnalysisResponse)
async def predict_sentiment(request: PredictRequest):
    if not sentiment_model or not vectorizer:
        raise HTTPException(status_code=500, detail="Model not loaded")

    try:
        # Transform text using the vectorizer
        text_vector = vectorizer.transform([request.text])

        # Get prediction and probability
        prediction = sentiment_model.predict(text_vector)[0]
        probabilities = sentiment_model.predict_proba(text_vector)[0]

        # Determine sentiment and confidence
        sentiment = "positive" if prediction == 1 else "negative"
        confidence = float(max(probabilities))

        return AnalysisResponse(
            sentiment=sentiment,
            confidence=confidence,
            timestamp=datetime.now().isoformat(),
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")


@app.post("/analyze/data")
async def analyze_data(file: UploadFile = File(...)):
    try:
        # Read file content
        content = await file.read()

        # Determine file type and read accordingly
        if file.filename.endswith(".csv"):
            df = pd.read_csv(io.StringIO(content.decode("utf-8")))
        elif file.filename.endswith(".json"):
            data = json.loads(content.decode("utf-8"))
            df = pd.DataFrame(data)
        else:
            raise HTTPException(
                status_code=400, detail="Unsupported file format. Use CSV or JSON."
            )

        # Generate summary statistics
        summary = {
            "rows": len(df),
            "columns": len(df.columns),
            "column_names": df.columns.tolist(),
            "data_types": df.dtypes.astype(str).to_dict(),
            "missing_values": df.isnull().sum().to_dict(),
            "numeric_summary": {},
        }

        # Numeric column analysis
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        for col in numeric_cols:
            summary["numeric_summary"][col] = {
                "mean": float(df[col].mean()),
                "median": float(df[col].median()),
                "std": float(df[col].std()),
                "min": float(df[col].min()),
                "max": float(df[col].max()),
            }

        # Generate insights
        insights = []
        insights.append(
            f"Dataset contains {len(df)} rows and {len(df.columns)} columns"
        )

        if len(numeric_cols) > 0:
            insights.append(
                f"Found {len(numeric_cols)} numeric columns: {', '.join(numeric_cols)}"
            )

        missing_data = df.isnull().sum().sum()
        if missing_data > 0:
            insights.append(
                f"Dataset has {missing_data} missing values across all columns"
            )
        else:
            insights.append("No missing values detected in the dataset")

        # Prepare chart data for visualization
        charts_data = {}

        # Column distribution for categorical data
        categorical_cols = df.select_dtypes(include=["object"]).columns
        for col in categorical_cols[:3]:  # Limit to first 3 categorical columns
            value_counts = df[col].value_counts().head(10)
            charts_data[f"{col}_distribution"] = {
                "labels": value_counts.index.tolist(),
                "values": value_counts.values.tolist(),
            }

        # Numeric data for histograms
        for col in numeric_cols[:3]:  # Limit to first 3 numeric columns
            hist, bins = np.histogram(df[col].dropna(), bins=10)
            charts_data[f"{col}_histogram"] = {
                "bins": bins.tolist(),
                "frequencies": hist.tolist(),
            }

        return DataAnalysisResponse(
            summary=summary, insights=insights, charts_data=charts_data
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Analysis error: {str(e)}")


@app.post("/predict")
async def predict_legacy(filename: str = Form(...)):
    """Legacy endpoint for backward compatibility"""
    return {
        "prediction": "positive",
        "confidence": 0.95,
        "filename": filename,
        "note": "Use /predict/sentiment for advanced sentiment analysis",
    }


@app.get("/model/info")
async def model_info():
    return {
        "model_type": "Logistic Regression",
        "feature_extractor": "TF-IDF Vectorizer",
        "capabilities": ["Sentiment Analysis", "Data Analysis", "CSV/JSON Processing"],
        "endpoints": ["/predict/sentiment", "/analyze/data", "/model/info"],
    }


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
