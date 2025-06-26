#!/bin/bash

# Build script for simple dev-capsule (using built-in VS Code Server)
set -e

echo "🚀 Building simple dev-capsule Docker image..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default image name
IMAGE_NAME=${DEV_CAPSULE_IMAGE:-"dev-capsule/simple:latest"}

echo -e "${YELLOW}📋 Build Configuration:${NC}"
echo "  Image name: $IMAGE_NAME"
echo "  Dockerfile: Dockerfile.simple"
echo "  Approach: Built-in VS Code Server + Custom Extensions"
echo ""

# Check if Dockerfile.simple exists
if [ ! -f "Dockerfile.simple" ]; then
    echo -e "${RED}❌ Dockerfile.simple not found!${NC}"
    exit 1
fi

# Check if vscode-settings.json exists
if [ ! -f "vscode-settings.json" ]; then
    echo -e "${YELLOW}⚠️  vscode-settings.json not found. Using default settings.${NC}"
fi

# Detect platform and set build args
PLATFORM=""
if [[ $(uname -m) == "arm64" ]]; then
    echo -e "${YELLOW}🍎 Detected Mac ARM64 - using linux/amd64 platform${NC}"
    PLATFORM="--platform linux/amd64"
fi

# Build Docker image
echo -e "${BLUE}🐳 Building Docker image...${NC}"
docker build $PLATFORM -f Dockerfile.simple -t "$IMAGE_NAME" .

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
echo ""
echo -e "${BLUE}📦 Pre-installed extensions:${NC}"
echo "  - Python"
echo "  - TypeScript"
echo "  - Tailwind CSS"
echo "  - Prettier"
echo "  - Docker"
echo "  - GitHub Copilot"
echo "  - Playwright"