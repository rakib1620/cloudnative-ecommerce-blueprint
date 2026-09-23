"""
AI Semantic Search & RAG Microservice
Provides semantic vector search and AI Copilot recommendations over the product catalog.
"""

import datetime
import os

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(
    title="AI Semantic Search & RAG Service",
    version="1.0.0",
    description="Vector search & generative AI recommendations using Qdrant vector database",
)

QDRANT_HOST = os.getenv("QDRANT_HOST", "localhost")
QDRANT_PORT = os.getenv("QDRANT_PORT", "6333")


class SearchQuery(BaseModel):
    query: str
    top_k: int | None = 5
    category: str | None = None


class SearchResultItem(BaseModel):
    id: int
    title: str
    category: str
    price: float
    relevance_score: float


class SearchResponse(BaseModel):
    query: str
    results: list[SearchResultItem]
    count: int


# Mock knowledge base for initial semantic retrieval
DEMO_CATALOG = [
    {
        "id": 1,
        "title": "Ultra-light Performance Mechanical Keyboard",
        "category": "Electronics",
        "price": 129.99,
        "keywords": ["keyboard", "mechanical", "switch", "rgb", "typing"],
    },
    {
        "id": 2,
        "title": "Ergonomic Mesh High-Back Office Chair",
        "category": "Furniture",
        "price": 289.00,
        "keywords": ["chair", "ergonomic", "desk", "lumbar", "mesh", "office"],
    },
    {
        "id": 3,
        "title": "Noise-Cancelling Studio Wireless Headphones",
        "category": "Audio",
        "price": 199.50,
        "keywords": ["headphone", "audio", "sound", "noise", "wireless", "music"],
    },
    {
        "id": 4,
        "title": "4K Ultra HD IPS 27-inch Developer Monitor",
        "category": "Electronics",
        "price": 449.99,
        "keywords": ["monitor", "display", "screen", "4k", "ips", "usb-c"],
    },
]


@app.get("/health")
def health_check():
    return {
        "status": "UP",
        "service": "ai-search-service",
        "qdrant_target": f"{QDRANT_HOST}:{QDRANT_PORT}",
        "timestamp": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    }


@app.post("/api/v1/search/semantic", response_model=SearchResponse)
def semantic_search(payload: SearchQuery):
    query_tokens = payload.query.lower().split()
    matched = []

    for item in DEMO_CATALOG:
        score = 0.5  # Base score
        for token in query_tokens:
            if token in item["title"].lower():
                score += 0.3
            if any(token in kw for kw in item["keywords"]):
                score += 0.2
        if score > 0.5:
            matched.append(
                SearchResultItem(
                    id=item["id"],
                    title=item["title"],
                    category=item["category"],
                    price=item["price"],
                    relevance_score=min(round(score, 2), 1.0),
                )
            )

    matched.sort(key=lambda x: x.relevance_score, reverse=True)
    results = matched[: payload.top_k]

    return SearchResponse(query=payload.query, results=results, count=len(results))


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8085)
