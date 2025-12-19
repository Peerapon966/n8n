FROM n8nio/n8n:1.121.3-amd64

USER root

RUN apk add --no-cache aws-cli && chmod +x /usr/bin/aws

USER node