package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

type OrderRequest struct {
	UserID    string  `json:"user_id"`
	ProductID int     `json:"product_id"`
	Quantity  int     `json:"quantity"`
	Amount    float64 `json:"amount"`
}

type OrderEvent struct {
	EventID   string    `json:"event_id"`
	EventType string    `json:"event_type"` // "order.created"
	OrderID   string    `json:"order_id"`
	UserID    string    `json:"user_id"`
	Amount    float64   `json:"amount"`
	Status    string    `json:"status"` // "PENDING", "CONFIRMED"
	CreatedAt time.Time `json:"created_at"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":    "UP",
		"service":   "order-service",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	})
}

func createOrderHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req OrderRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid payload", http.StatusBadRequest)
		return
	}

	orderID := fmt.Sprintf("ord_%d", time.Now().UnixNano())
	event := OrderEvent{
		EventID:   fmt.Sprintf("evt_%d", time.Now().UnixNano()),
		EventType: "order.created",
		OrderID:   orderID,
		UserID:    req.UserID,
		Amount:    req.Amount,
		Status:    "PENDING",
		CreatedAt: time.Now().UTC(),
	}

	// In full deployment, this writes to Kafka topic "order.created"
	fmt.Printf("[order-service] Event emitted to Kafka 'order.created': %+v\n", event)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(event)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8083"
	}

	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/orders", createOrderHandler)

	fmt.Printf("[order-service] Listening on port %s...\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
