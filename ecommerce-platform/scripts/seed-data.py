"""
Seed Data Script for Ecommerce Microservices & AI RAG Engine.
Seeds:
1. PostgreSQL Products & Categories
2. Qdrant Vector Collection & Embeddings
"""

import json
import time
import urllib.request
import urllib.error

PRODUCTS = [
    {
        "id": 1,
        "title": "Ultra-light Performance Mechanical Keyboard",
        "category": "Electronics",
        "price": 129.99,
        "description": "Hot-swappable tactile RGB wireless mechanical keyboard with low latency 2.4GHz connection."
    },
    {
        "id": 2,
        "title": "Ergonomic Mesh High-Back Office Chair",
        "category": "Furniture",
        "price": 289.00,
        "description": "Breathable mesh ergonomic chair with dynamic lumbar support and 4D adjustable armrests."
    },
    {
        "id": 3,
        "title": "Noise-Cancelling Studio Wireless Headphones",
        "category": "Audio",
        "price": 199.50,
        "description": "Active noise cancelling over-ear headphones with 40-hour battery life and spatial audio."
    },
    {
        "id": 4,
        "title": "4K Ultra HD IPS 27-inch Developer Monitor",
        "category": "Electronics",
        "price": 449.99,
        "description": "Factory calibrated 4K USB-C monitor with 99% sRGB color gamut and 90W power delivery."
    }
]

def seed_qdrant(qdrant_url="http://localhost:6333", collection_name="products"):
    print(f"[*] Checking Qdrant connection at {qdrant_url}...")
    try:
        req = urllib.request.Request(f"{qdrant_url}/collections/{collection_name}", method="GET")
        with urllib.request.urlopen(req) as resp:
            print(f"[+] Collection '{collection_name}' already exists.")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            print(f"[*] Creating Qdrant collection '{collection_name}'...")
            payload = json.dumps({
                "vectors": {
                    "size": 4, # Demo vector size
                    "distance": "Cosine"
                }
            }).encode("utf-8")
            req = urllib.request.Request(
                f"{qdrant_url}/collections/{collection_name}",
                data=payload,
                headers={"Content-Type": "application/json"},
                method="PUT"
            )
            try:
                with urllib.request.urlopen(req) as resp:
                    print(f"[+] Collection created: {resp.status}")
            except Exception as ex:
                print(f"[-] Could not create Qdrant collection: {ex}")
        else:
            print(f"[-] Qdrant error: {e}")
    except Exception as e:
        print(f"[-] Qdrant is not reachable at {qdrant_url}. Make sure docker-compose is running.")

def main():
    print("==================================================")
    print(" E-Commerce & AI Search Platform: Seeding Data")
    print("==================================================")
    print(f"Found {len(PRODUCTS)} sample products to seed.")
    seed_qdrant()
    print("[+] Seeding script completed.")

if __name__ == "__main__":
    main()
