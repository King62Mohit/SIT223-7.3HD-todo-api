#!/bin/bash
# Stop all services
echo "Stopping all containers..."
docker rm -f todo-api-staging todo-api-production prometheus grafana 2>/dev/null
echo "All containers stopped!"
