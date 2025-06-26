# Simple approach: Copy pre-built code-server using Microsoft Universal Dev Container
FROM mcr.microsoft.com/vscode/devcontainers/universal:2-linux

# Switch to root for installation
USER root

# Copy pre-built code-server from host
COPY editor/release /opt/code-server/

# Install runtime dependencies
WORKDIR /opt/code-server
RUN npm install --production --unsafe-perm

# Create code-server wrapper script
RUN echo '#!/bin/bash\ncd /opt/code-server\nnode out/node/entry.js "$@"' > /usr/local/bin/code-server \
    && chmod +x /usr/local/bin/code-server

# Expose essential ports only
EXPOSE 8080
EXPOSE 3000

# Create workspace directory and set permissions
RUN mkdir -p /workspace && chown vscode:vscode /workspace

# Switch to vscode user (consistent with dev containers)
USER vscode
WORKDIR /workspace

# Default command
CMD ["bash"]