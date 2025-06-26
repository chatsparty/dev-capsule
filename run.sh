#!/bin/bash

# Run script for dev-capsule Docker container
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default image name (matches build-simple.sh)
IMAGE_NAME=${DEV_CAPSULE_IMAGE:-"dev-capsule/simple:latest"}

# Default ports
CODE_SERVER_PORT=${CODE_SERVER_PORT:-8080}
DEV_PORT=${DEV_PORT:-3000}

# Container name
CONTAINER_NAME=${CONTAINER_NAME:-"dev-capsule"}

echo -e "${BLUE}🚀 Starting dev-capsule container...${NC}"
echo ""
echo -e "${YELLOW}📋 Configuration:${NC}"
echo "  Image: $IMAGE_NAME"
echo "  Container: $CONTAINER_NAME"
echo "  Code Server Port: $CODE_SERVER_PORT"
echo "  Dev Server Port: $DEV_PORT"
echo ""

# Stop and remove existing container if it exists
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo -e "${YELLOW}🛑 Stopping existing container...${NC}"
    docker stop $CONTAINER_NAME >/dev/null 2>&1 || true
    docker rm $CONTAINER_NAME >/dev/null 2>&1 || true
fi

# Detect platform for Mac ARM64 compatibility
PLATFORM_ARG=""
if [[ $(uname -m) == "arm64" ]]; then
    echo -e "${YELLOW}🍎 Mac ARM64 detected - using linux/amd64 platform${NC}"
    PLATFORM_ARG="--platform linux/amd64"
fi

# Run the container
echo -e "${BLUE}🐳 Starting new container...${NC}"
docker run -it --rm \
    $PLATFORM_ARG \
    --name $CONTAINER_NAME \
    -p $CODE_SERVER_PORT:8080 \
    -p $DEV_PORT:3000 \
    -v "$(pwd)/workspace:/workspace" \
    $IMAGE_NAME

echo ""
echo -e "${GREEN}✅ Container started successfully!${NC}"
echo ""
echo -e "${YELLOW}🌐 Access points:${NC}"
echo "  VS Code Server: http://localhost:$CODE_SERVER_PORT"
echo "  Dev Server: http://localhost:$DEV_PORT"
echo ""
echo -e "${YELLOW}💾 Workspace:${NC}"
echo "  Local: $(pwd)/workspace"
echo "  Container: /workspace"