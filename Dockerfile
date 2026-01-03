FROM n8nio/n8n:1.121.3-amd64

COPY --chown=1000:1000 ./docker /home/node/.n8n/data