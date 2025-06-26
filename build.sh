#!/bin/bash

# Build script for dev-capsule Docker image
set -e

echo "🚀 Building dev-capsule Docker image..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default image name
IMAGE_NAME=${DEV_CAPSULE_IMAGE:-"dev-capsule/dev-server:latest"}

echo -e "${YELLOW}📋 Build Configuration:${NC}"
echo "  Image name: $IMAGE_NAME"
echo "  Context: $(pwd)"
echo ""

# Check if we need to build code-server
if [ ! -d "editor/release" ]; then
    echo -e "${YELLOW}⚠️  Editor release not found.${NC}"
    echo ""
    echo -e "${YELLOW}Options to get code-server release:${NC}"
    echo "1. 📦 Use pre-built release (recommended)"
    echo "2. 🔨 Build from source (takes 15-30 minutes)"
    echo ""
    
    read -p "Do you want to build from source? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ ! -d "editor" ]; then
            echo -e "${RED}❌ Editor directory not found. Please ensure the code-server submodule is initialized.${NC}"
            echo "Run: git submodule update --init --recursive"
            exit 1
        fi
        
        echo "📦 Building code-server from source..."
        cd editor
        
        # Initialize and update submodules (VS Code)
        echo "🔄 Initializing VS Code submodule..."
        git submodule update --init --recursive
        
        # Check if node_modules exists
        if [ ! -d "node_modules" ]; then
            echo "📥 Installing dependencies..."
            npm install
        fi
        
        echo "🔨 Building code-server..."
        VERSION='1.0.0' npm run build
        
        echo "🏗️  Building VS Code..."
        VERSION='1.0.0' npm run build:vscode
        
        echo "📦 Creating release..."
        VERSION='1.0.0' npm run release
        
        cd ..
        echo -e "${GREEN}✅ Code-server built successfully!${NC}"
    else
        echo -e "${YELLOW}💡 Recommendation: Download a pre-built release${NC}"
        echo ""
        echo "1. Go to: https://github.com/chatsparty/code-server/releases"
        echo "2. Download the latest release"
        echo "3. Extract to: editor/release/"
        echo ""
        echo "Or use the official code-server:"
        echo "  wget https://github.com/coder/code-server/releases/download/v4.22.1/code-server-4.22.1-linux-amd64.tar.gz"
        echo "  tar -xzf code-server-*.tar.gz"
        echo "  mv code-server-*-linux-amd64 editor/release"
        echo ""
        exit 1
    fi
else
    echo -e "${GREEN}✅ Editor release found, proceeding with Docker build...${NC}"
fi

# Build Docker image
echo "🐳 Building Docker image..."
docker build -t "$IMAGE_NAME" .

# Verify the build
echo ""
echo -e "${GREEN}✅ Docker image built successfully!${NC}"
echo ""
echo -e "${YELLOW}📊 Image details:${NC}"
docker images "$IMAGE_NAME"

echo ""
echo -e "${GREEN}🎉 Build complete!${NC}"
echo ""
echo -e "${YELLOW}🚀 To test the image:${NC}"
echo "  docker run -it -p 8080:8080 -p 3000:3000 $IMAGE_NAME"
echo ""
echo -e "${YELLOW}🌐 Access VS Code at:${NC}"
echo "  http://localhost:8080"