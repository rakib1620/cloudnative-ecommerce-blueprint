package main

import (
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"
)

// Idempotency cache simulation (In production, backed by Redis Sentinel / Postgres)
var (
	processedKeys = make(map[string]bool)
	cacheMu       sync.Mutex
)

type PaymentRequest struct {
	IdempotencyKey string  `json:"idempotency_key"`
	OrderID        string  `json:"order_id"`
	Amount         float64 `json:"amount"`
	Currency       string  `json:"currency"`
}

type PaymentResponse struct {
	PaymentID      string `json:"payment_id"`
	OrderID        string `json:"order_id"`
	Status         string `json:"status"` // "COMPLETED", "DUPLICATE", "FAILED"
	IdempotencyKey string `json:"idempotency_key"`
	Timestamp      string `json:"timestamp"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":    "UP",
		"service":   "payment-service",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	})
}

func processPaymentHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req PaymentRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	if req.IdempotencyKey == "" {
		http.Error(w, "Missing required header/field 'idempotency_key'", http.StatusBadRequest)
		return
	}

	cacheMu.Lock()
	if processedKeys[req.IdempotencyKey] {
		cacheMu.Unlock()
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(PaymentResponse{
			OrderID:        req.OrderID,
			Status:         "DUPLICATE",
			IdempotencyKey: req.IdempotencyKey,
			Timestamp:      time.Now().UTC().Format(time.RFC3339),
		})
		return
	}
	processedKeys[req.IdempotencyKey] = true
	cacheMu.Unlock()

	// Simulate payment processing
	h := sha256.New()
	h.Write([]byte(fmt.Sprintf("%s-%d", req.OrderID, time.Now().UnixNano())))
	paymentID := "pay_" + hex.EncodeToString(h.Sum(nil))[:16]

	resp := PaymentResponse{
		PaymentID:      paymentID,
		OrderID:        req.OrderID,
		Status:         "COMPLETED",
		IdempotencyKey: req.IdempotencyKey,
		Timestamp:      time.Now().UTC().Format(time.RFC3339),
	}

	fmt.Printf("[payment-service] Emitting event to Kafka 'payment.completed': %+v\n", resp)

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(resp)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8084"
	}

	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/v1/payments", processPaymentHandler)

	fmt.Printf("[payment-service] Listening on port %s...\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}
