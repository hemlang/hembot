# Hembot

An interactive Hemlock coding agent, written in Hemlock. Talks to a local `llama-server` running a Hemlock-tuned model via the OpenAI-compatible `/v1/chat/completions` endpoint.

## Design

```
user input  →  [Hembot]  →  llama-server (OpenAI-compatible API)
                   ↓           ↓
              extract code  ← response
                   ↓
              run hemlock (sandbox)
                   ↓
              print result
                   ↓
              (optional) feed error back → retry
```

Everything runs locally. No API keys, no telemetry.

## Code layout

- `hembot.hml` — the agent (single file, <300 lines)
- `system_prompt.txt` — the winning prompt from hembench benchmarking
- `README.md` — user-facing docs
- `examples/` — saved example sessions (JSON)

## Key dependencies (Hemlock stdlib)

- `@stdlib/http` — `post_json_timeout(url, data, timeout_ms)` for chat requests
- `@stdlib/json` — `parse(str)` / `stringify(obj)`
- `@stdlib/fs` — `read_file`, `write_file`, `exists`
- `@stdlib/shell` — `exec(cmd)` for sandbox execution
- `@stdlib/args` — `parse_args`, `get_option`, `has_flag`
- `@stdlib/terminal` — ANSI color codes

## Testing

```bash
# Start llama-server first (in another terminal)
llama-server -m /path/to/Hemlock-Apothecary-7B-Q8_0.gguf --port 8199 --ctx-size 8192 -ngl -1

# Run Hembot
hemlock hembot.hml

# Or with auto-retry on code failure
hemlock hembot.hml --retry
```

## Known gotchas

- `print()` takes only 1 argument — use template strings for interpolation
- `exec()` result may use `.stdout` or `.output` depending on stdlib version — the code handles both
- HTTP responses have `.status_code`, `.headers`, `.body` fields
- `read_line()` returns `null` on EOF (Ctrl-D)

## Future work

- Smarter retry: only retry on wrong-output (benchmark showed retry hurts L4 but helps L5)
- Token streaming via `post_json_stream` for incremental display
- Multi-file projects: let the agent read/write several .hml files
- Tool-calling if the base model supports it (/v1/chat/completions with `tools`)
- Persistent session memory across runs
