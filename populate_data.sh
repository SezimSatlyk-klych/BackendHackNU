#!/bin/bash

# Script to populate the database with sample data
# This script should be run after the Docker containers are up and running

echo "🚀 Starting database population..."

# Check if Docker containers are running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Docker containers are not running. Please start them first with:"
    echo "   docker-compose up -d"
    exit 1
fi

echo "📊 Populating database with sample data..."

# Run the population script inside the web container
docker-compose exec web python populate_database.py

echo "✅ Database population completed!"
echo ""
echo "🔑 Test Accounts Created:"
echo "1. Adult User: aiaulym@example.com / password123"
echo "2. Adult User: john@example.com / password123"
echo "3. Child User: alice@example.com / password123"
echo ""
echo "🌐 You can now test the iOS app with these accounts!"
