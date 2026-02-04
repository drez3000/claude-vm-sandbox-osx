FROM node:24-slim

RUN apt-get update \
	&& apt-get install -y curl git ca-certificates \
	&& rm -rf /var/lib/apt/lists/* \
	&& useradd -m -s /bin/bash claude \
	&& npm install -g @anthropic-ai/claude-code

USER claude

WORKDIR /workspace
CMD ["claude"]
