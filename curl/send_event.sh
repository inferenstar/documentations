curl -i \
        -X POST  \
        -H "X-API-Key: $X_API_KEY" \
        -d @./event_data.json \
        'https://events.inferenstar.com/'
