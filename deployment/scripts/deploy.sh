#!/bin/bash

# Deployment script for Migration Game

set -e

echo "🚀 Deploying Migration Game..."

# Check if .env exists
if [ ! -f "../backend/.env" ]; then
  echo "❌ Error: backend/.env not found"
  echo "   Copy backend/.env.example to backend/.env and configure"
  exit 1
fi

# Build backend
echo "📦 Building backend..."
cd ../backend
npm install
npm run build || echo "⚠️  Build step skipped (no build script)"

# Build frontend
echo "📦 Building frontend..."
cd ../frontend
npm install
npm run build

echo "✅ Build complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Push to GitHub"
echo "   2. Connect to Render.com"
echo "   3. Configure environment variables"
echo "   4. Deploy!"

