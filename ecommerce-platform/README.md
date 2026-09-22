# Next-Gen Event-Driven E-Commerce & AI Platform
## Enterprise DevOps, Platform Engineering & SRE Master Blueprint

Welcome to the **Next-Gen Event-Driven E-Commerce & AI Platform** monorepo. This platform is engineered according to modern cloud-native standards, featuring:

- 🚀 **Event-Driven Microservices**: Asynchronous messaging via Apache Kafka (order creation, payment completion, idempotency, DLQ).
- 🧠 **AI Semantic Search & RAG**: FastAPI-powered Copilot with Qdrant vector database similarity indexing.
- 🔄 **GitOps & Progressive Delivery**: ArgoCD App-of-Apps and Argo Rollouts (5% -> 20% -> 100% automated canary analysis).
- 💰 **FinOps**: Karpenter sub-minute dynamic EC2 node provisioning with Spot instance orchestration and Kubecost pod allocation.
- 🛡️ **Zero-Trust Security**: Kyverno Policy-as-Code admission control, External Secrets Operator (ESO), and Cilium / Calico NetworkPolicies.
- 📊 **Full-Stack Observability**: OpenTelemetry distributed tracing, Prometheus golden signals, Grafana Loki, and Tempo.
- 🛠️ **SRE & Chaos Engineering**: Strict SLOs (99.9% availability, p95 < 300ms), Chaos Mesh resilience testing, and Velero disaster recovery.

---

## 📁 Monorepo Layout

```
ecommerce-platform/
├── .github/
│   ├── workflows/             # DevSecOps CI Pipelines (Trivy, Linters, Tests)
│   └── CODEOWNERS             # Mandatory Code Review Rules
├── apps/                      # Microservices Source Code
│   ├── auth-service/          # Go / JWT
│   ├── product-service/       # Node.js / Express
│   ├── order-service/         # Go / Kafka Event Publisher
│   ├── payment-service/       # Go / Idempotency / Kafka
│   ├── ai-search-service/     # Python FastAPI / Qdrant RAG
│   └── frontend-store/        # Next.js Storefront UI
├── infra/                     # Infrastructure as Code (IaC)
│   └── terraform/
│       ├── environments/      # dev, staging, prod
│       └── modules/           # vpc, eks, karpenter, rds, s3_dynamodb
├── k8s/                       # Kubernetes Manifests & GitOps
│   ├── base/                  # Strimzi Kafka, Qdrant StatefulSet, Argo Rollouts
│   ├── gitops/                # ArgoCD Root Application (App-of-Apps)
│   └── policies/              # Kyverno Admission & Network Policies
├── scripts/                   # Local Dev & Automation
│   ├── local-setup.sh         # Kind cluster setup (Linux/macOS)
│   ├── local-setup.ps1        # Kind cluster setup (Windows PowerShell)
│   ├── docker-compose.local.yml # Local Kafka, Redis, Postgres, Qdrant
│   └── seed-data.py           # Catalog & vector embedding seeder
└── docs/                      # Technical Architecture & Runbooks
```

---

## ⚡ Quickstart: Local Development Sandbox (Free / Zero Cloud Cost)

### Option 1: Docker Compose Stack (Lightweight)
Run Kafka, Redis, PostgreSQL, and Qdrant locally:

```bash
# Start local event-driven & data infrastructure
npm run local:up

# Check running services
npm run local:logs

# Seed mock products & Qdrant vector collection
npm run seed

# Stop services
npm run local:down
```

Local access endpoints:
- **Kafka Broker**: `localhost:9092`
- **Kafka UI**: [http://localhost:8080](http://localhost:8080)
- **PostgreSQL**: `localhost:5432` (`user: postgres`, `password: password123`, `db: ecommerce`)
- **Redis**: `localhost:6379`
- **Qdrant Vector DB Web Console**: [http://localhost:6333/dashboard](http://localhost:6333/dashboard)

---

### Option 2: Local Kubernetes Cluster (Kind)
Spin up a local Kubernetes cluster with ingress controller:

**On Linux/macOS:**
```bash
./scripts/local-setup.sh
```

**On Windows (PowerShell):**
```powershell
.\scripts\local-setup.ps1
```

---

## 🔐 Commit Governance
This repository enforces Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, etc.) via Commitlint and Husky.
Example valid commit:
```bash
git commit -m "feat(auth): implement jwt token generation and health endpoint"
```
