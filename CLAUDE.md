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

```
src/
  hembot.hml   – main entry, has `main()` at bottom; imports extract + config
  extract.hml  – pure helpers: extract_code(), build_retry_feedback()
  config.hml   – CLI parsing + defaults, exports parse_cli() and load_config()
tests/
  test_extract.hml  – 11 tests covering fenced-block edge cases + feedback
  test_config.hml   – 7 tests covering defaults and every CLI flag
system_prompt.txt   – winning prompt from hembench sweep on Apothecary Q8_0
package.json        – hpm manifest, `main: src/hembot.hml`, `scripts.test`
```

Pure helpers live in their own modules so tests don't need `llama-server` or stdin. Only `src/hembot.hml` does I/O + HTTP + `run_hemlock`; everything else is deterministic and testable.

## Key stdlib dependencies

- `@stdlib/http` — `post_json_timeout(url, data, timeout_ms)` for chat requests. Returns `{ status_code, headers, body }`.
- `@stdlib/json` — `parse(str)` / `stringify(obj)`.
- `@stdlib/fs` — `read_file`, `write_file`, `exists`.
- `@stdlib/shell` — `run_capture(command)`. Returns `{ success, stdout, stderr, code }`.
- `@stdlib/args` — `parse(argv, options?)`. **Must declare string options** via `options.strings: [...]`, or `--flag VALUE` gets parsed as flag+positional.
- `@stdlib/terminal` — ANSI color constants.
- `@stdlib/testing` — `describe`, `test`, `expect`, `run`.

## Testing

```bash
# Run each suite directly
hemlock tests/test_extract.hml
hemlock tests/test_config.hml
```

CI (GitHub Actions) builds Hemlock from source and runs both suites on every push/PR.

Don't use `hpm test` for now — there's an upstream bug where it crashes passing the test stats object to `exit()`. Invoke tests directly instead.

## Running the agent

```bash
# Start llama-server in another terminal first
llama-server -m ~/AI/hembench/Hemlock-Apothecary-7B-Q8_0.gguf --port 8199 --ctx-size 8192 -ngl -1

# Then the agent
hemlock src/hembot.hml

# With auto-retry on code failures
hemlock src/hembot.hml --retry

# Point at a different server / model
hemlock src/hembot.hml --url http://host:8080/v1/chat/completions --model my-model
```

## Gotchas encountered

- `print()` accepts only 1 argument — use template strings `` `x ${v}` `` for interpolation.
- `exec` lives in `@stdlib/process`, but `@stdlib/shell.run_capture()` is cleaner for capture-and-return-code patterns. Its result field is `.code`, not `.exit_code`.
- `@stdlib/args.parse()` needs `options: { strings: ["url", "model", ...] }` or it misreads `--url http://...` as a lone flag plus positional.
- Hemlock's global arg array is `args`, not `argv`.
- The CLI argument `args` collides with any function parameter named `args`; rename to `parsed` or similar in functions that take the parsed result.

## Future work

- **Smarter retry** — hembench showed retry-with-feedback helps L5 (+40 pts) but hurts L1/L4 (-11/-14). Branch on error type: retry on wrong-output, resample on runtime errors.
- **Streaming** — use `post_json_stream` to print tokens as they arrive.
- **Multi-file projects** — let the agent read/write multiple `.hml` files.
- **Tool calling** — if the base model learns to emit structured tool-call syntax, wire up `/v1/chat/completions` with `tools:` parameter.
- **Persistent history** — auto-save conversations between sessions.
