#!/bin/bash
# Test the Todo API

echo "Testing Todo API..."
echo "==================="

STAGING_URL="http://localhost:3000"
PROD_URL="http://localhost:3001"

echo "Testing Staging ($STAGING_URL)..."
echo "Health check:"
curl -s $STAGING_URL/health | jq . 2>/dev/null || curl -s $STAGING_URL/health

echo -e "\nCreating todo:"
curl -s -X POST $STAGING_URL/todos -H "Content-Type: application/json" -d '{"title":"Test from script"}' | jq . 2>/dev/null || curl -s -X POST $STAGING_URL/todos -H "Content-Type: application/json" -d '{"title":"Test from script"}'

echo -e "\nGetting all todos:"
curl -s $STAGING_URL/todos | jq . 2>/dev/null || curl -s $STAGING_URL/todos

echo -e "\n\nTesting Production ($PROD_URL)..."
echo "Health check:"
curl -s $PROD_URL/health | jq . 2>/dev/null || curl -s $PROD_URL/health

echo -e "\nDone!"
