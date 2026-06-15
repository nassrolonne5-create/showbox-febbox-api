FROM node:18-bullseye

# Install Python
RUN apt-get update && apt-get install -y python3 python3-venv python3-pip

WORKDIR /app

COPY api/ ./api/
COPY bypass/ ./bypass/

WORKDIR /app/api
RUN npm install

WORKDIR /app/bypass
# 👇 THE BULLETPROOF LAYER: 
# 1. Installs all Python packages
# 2. Installs Linux OS libraries for the browser (install-deps)
# 3. Fetches the stealth browser (camoufox)
RUN python3 -m venv venv && \
    . venv/bin/activate && \
    pip install -r requirements.txt && \
    python3 -m playwright install-deps && \
    python3 -m camoufox fetch

WORKDIR /app
RUN echo '#!/bin/bash' > start.sh && \
    echo 'cd /app/bypass && . venv/bin/activate && python server.py &' >> start.sh && \
    echo 'cd /app/api && npm start' >> start.sh && \
    chmod +x start.sh

EXPOSE 3000
CMD ["./start.sh"]
