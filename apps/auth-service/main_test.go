package main

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestHealthHandler(t *testing.T) {
	req := httptest.NewRequest("GET", "/health", nil)
	w := httptest.NewRecorder()

	healthHandler(w, req)

	resp := w.Result()
	if resp.StatusCode != http.StatusOK {
		t.Errorf("Expected status OK; got %v", resp.StatusCode)
	}

	body := w.Body.String()
	if !strings.Contains(body, "auth-service") {
		t.Errorf("Expected body to contain 'auth-service'; got %s", body)
	}
}

func TestLoginHandler_Invalid(t *testing.T) {
	reqBody := strings.NewReader(`{"username":"admin","password":"wrongpassword"}`)
	req := httptest.NewRequest("POST", "/api/v1/auth/login", reqBody)
	w := httptest.NewRecorder()

	loginHandler(w, req)

	resp := w.Result()
	if resp.StatusCode != http.StatusUnauthorized {
		t.Errorf("Expected status 401 Unauthorized; got %v", resp.StatusCode)
	}
}
