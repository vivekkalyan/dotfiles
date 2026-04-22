# Local llama-server API

This machine runs a local `llama-server` with an OpenAI-compatible API.

## Endpoint

- Base URL: `http://127.0.0.1:8012/v1`
- Model: `qwen3.6-27b`
- API key: not required by the server, but some clients insist on one. Use any placeholder such as `EMPTY`.

## Server defaults

- Reasoning is off by default.
- Request-level params can override the server defaults.
- Default sampling:
  - `temperature: 0.6`
  - `top_p: 0.95`
  - `top_k: 20`
  - `min_p: 0.0`
  - `presence_penalty: 0.0`
  - `repeat_penalty: 1.0`

## OpenAI client settings

Point OpenAI-compatible clients at:

```text
OPENAI_BASE_URL=http://127.0.0.1:8012/v1
OPENAI_API_KEY=EMPTY
```

Use `qwen3.6-27b` as the model name.

## Quick checks

List models:

```bash
curl -s http://127.0.0.1:8012/v1/models | jq
```

Basic chat request:

```bash
curl -s http://127.0.0.1:8012/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen3.6-27b",
    "messages": [
      {"role": "user", "content": "Reply with exactly: local qwen is working"}
    ]
  }' | jq -r '.choices[0].message.content'
```

## Reasoning

Reasoning is available, but off by default.

Enable it per request with `chat_template_kwargs.enable_thinking = true`:

```bash
curl -s http://127.0.0.1:8012/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "qwen3.6-27b",
    "messages": [
      {"role": "user", "content": "Reply with exactly OK."}
    ],
    "reasoning_format": "deepseek",
    "chat_template_kwargs": {
      "enable_thinking": true
    }
  }' | jq '{content: .choices[0].message.content, reasoning: .choices[0].message.reasoning_content}'
```

Disable reasoning explicitly:

```json
{
  "chat_template_kwargs": {
    "enable_thinking": false
  }
}
```
