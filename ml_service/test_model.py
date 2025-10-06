import requests
import json

# Test the ML service
base_url = "http://localhost:8000"


def test_ml_service():
    try:
        # Test root endpoint
        response = requests.get(f"{base_url}/")
        print("Root endpoint:", response.json())

        # Test sentiment prediction
        sentiment_data = {"text": "I love this product, it's amazing!"}
        response = requests.post(f"{base_url}/predict/sentiment", json=sentiment_data)
        print("Sentiment analysis:", response.json())

        # Test with negative sentiment
        sentiment_data = {"text": "This is terrible, I hate it"}
        response = requests.post(f"{base_url}/predict/sentiment", json=sentiment_data)
        print("Negative sentiment:", response.json())

        # Test model info
        response = requests.get(f"{base_url}/model/info")
        print("Model info:", response.json())

    except Exception as e:
        print(f"Error testing ML service: {e}")


if __name__ == "__main__":
    test_ml_service()
