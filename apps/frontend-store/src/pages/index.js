import React, { useState } from 'react';

export default function Home() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);

  const handleSearch = async (e) => {
    e.preventDefault();
    if (!query) return;
    setLoading(true);
    try {
      const res = await fetch('/api/v1/search/semantic', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query, top_k: 5 }),
      });
      const data = await res.json();
      setResults(data.results || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ fontFamily: 'sans-serif', maxWidth: '800px', margin: '40px auto', padding: '0 20px' }}>
      <h1>🚀 Next-Gen Event-Driven E-Commerce & AI Platform</h1>
      <p style={{ color: '#666' }}>
        Cloud-Native Microservices (Go, Node.js, Python FastAPI, Kafka, Qdrant, ArgoCD)
      </p>

      <form onSubmit={handleSearch} style={{ display: 'flex', gap: '10px', margin: '30px 0' }}>
        <input
          type="text"
          placeholder="Ask AI Copilot (e.g. 'comfortable chair for coding long hours')..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          style={{ flex: 1, padding: '12px', fontSize: '16px', borderRadius: '6px', border: '1px solid #ccc' }}
        />
        <button
          type="submit"
          style={{ padding: '12px 24px', background: '#0066cc', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer' }}
        >
          {loading ? 'Searching...' : 'AI Search'}
        </button>
      </form>

      <div>
        <h3>Catalog Results:</h3>
        {results.length === 0 ? (
          <p style={{ color: '#888' }}>No results yet. Try searching above!</p>
        ) : (
          results.map((item) => (
            <div
              key={item.id}
              style={{
                border: '1px solid #eee',
                borderRadius: '8px',
                padding: '16px',
                marginBottom: '12px',
                boxShadow: '0 2px 4px rgba(0,0,0,0.05)'
              }}
            >
              <h4>{item.title}</h4>
              <p style={{ margin: '4px 0', color: '#555' }}>Category: {item.category}</p>
              <p style={{ margin: '4px 0', fontWeight: 'bold' }}>Price: ${item.price}</p>
              <p style={{ margin: '4px 0', color: '#28a745', fontSize: '14px' }}>
                AI Relevance Match: {(item.relevance_score * 100).toFixed(0)}%
              </p>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
