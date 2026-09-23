from fastapi.testclient import TestClient

from src.main import app

client = TestClient(app)


def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "UP"
    assert data["service"] == "ai-search-service"


def test_semantic_search():
    payload = {"query": "mechanical keyboard for office typing", "top_k": 3}
    response = client.post("/api/v1/search/semantic", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["count"] > 0
    assert any("Keyboard" in item["title"] for item in data["results"])
