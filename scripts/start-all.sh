#!/bin/bash
# Start all services for SIT223-7.3HD

echo "Starting Todo API Services..."
echo "=============================="

# Build Docker image
echo "Building Docker image..."
docker build -t todo-api:latest -f dockerfile .

# Stop existing containers
echo "Stopping existing containers..."
docker rm -f todo-api-staging todo-api-production prometheus grafana 2>/dev/null

# Start staging
echo "Starting staging container on port 3000..."
docker run -d \
  --name todo-api-staging \
  -p 3000:3000 \
  -e NODE_ENV=staging \
  --restart unless-stopped \
  todo-api:latest

# Start production
echo "Starting production container on port 3001..."
docker run -d \
  --name todo-api-production \
  -p 3001:3000 \
  -e NODE_ENV=production \
  --restart unless-stopped \
  todo-api:latest

# Start Prometheus
echo "Starting Prometheus on port 9090..."
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v "$(pwd)/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml:ro" \
  --restart unless-stopped \
  prom/prometheus:latest

# Start Grafana
echo "Starting Grafana on port 3002..."
docker run -d \
  --name grafana \
  -p 3002:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  --restart unless-stopped \
  grafana/grafana:latest

echo ""
echo "=============================="
echo "All services started!"
echo "=============================="
echo "Staging API:    http://localhost:3000"
echo "Production API: http://localhost:3001"
echo "Prometheus:     http://localhost:9090"
echo "Grafana:        http://localhost:3002 (admin/admin)"
echo ""
echo "Check status: docker ps"
