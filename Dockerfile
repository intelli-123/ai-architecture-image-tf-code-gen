# Use a stable Node.js runtime (20 LTS)
FROM node:20-slim

# Install OS deps for downloading TFLint
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ---------- Install TFLint ----------
# Pin a version you trust; you can change this during build with --build-arg
ARG TFLINT_VERSION=v0.51.1
RUN curl -L "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_amd64.zip" -o /tmp/tflint.zip \
 && unzip /tmp/tflint.zip -d /usr/local/bin \
 && rm /tmp/tflint.zip \
 && tflint --version

# Optional (caches rulesets in image so first /lint is faster)
# This step needs network during build; ignore failures to keep builds robust
RUN tflint --init || true

# ---------- App setup ----------
WORKDIR /app

# Copy dependency manifests first to leverage Docker layer caching
# If you have both package.json and package-lock.json, this is ideal
COPY package*.json ./

# Install only production dependencies if you have a lockfile
# If no package.json exists, this will fail—see the note below for a minimal package.json
RUN if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then \
      npm ci --omit=dev; \
    else \
      npm install --omit=dev; \
    fi

# Copy the rest of your project
COPY . .

# Create required folders used by your app
RUN mkdir -p uploads public/generated \
 && chown -R node:node /app

# Environment
ENV NODE_ENV=production
ENV PORT=3001

# Run as non-root user for security
USER node

# Expose the app port (documentation only; mapping is done with -p)
EXPOSE 3001

# Start your server
CMD ["node", "src/app.js"]