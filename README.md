# Hembot

[![test](https://github.com/hemlang/hembot/actions/workflows/test.yml/badge.svg)](https://github.com/hemlang/hembot/actions/workflows/test.yml)

An interactive coding agent for the [Hemlock](https://github.com/hemlang/hemlock) programming language. Written in Hemlock, of course.

Hembot talks to a local `llama-server` running a Hemlock-tuned model (default: [`Hemlock-Apothecary-7B`](https://huggingface.co/nbeerbower/Hemlock-Apothecary-7B)), extracts Hemlock code from its responses, runs it in a sandbox, and can optionally feed errors back so the model fixes its own bugs.

## Setup

1. Install Hemlock 2.0+ and make sure `hemlock` is on your `PATH`.
2. Install `llama-server` from [llama.cpp](https://github.com/ggerganov/llama.cpp).
3. Grab a GGUF of a Hemlock-tuned model, e.g. [`Hemlock-Apothecary-7B`](https://huggingface.co/nbeerbower/Hemlock-Apothecary-7B) quantized to Q8_0.
4. Launch the server in another terminal:
   ```bash
   llama-server -m Hemlock-Apothecary-7B-Q8_0.gguf --port 8199 --ctx-size 8192 -ngl -1
   ```
5. Run Hembot:
   ```bash
   hemlock src/hembot.hml
   ```

## Usage

```
╔══════════════════════════════════════╗
║  Hembot — Hemlock Coding Agent       ║
╚══════════════════════════════════════╝

you> write a program that prints the first 10 fibonacci numbers
Hembot: ```hemlock
fn main() {
    let a = 0; let b = 1;
    for (let i = 0; i < 10; i++) {
        print(a);
        let t = a + b; a = b; b = t;
    }
}
main();
```
── sandbox: ✓ ran cleanly
0
1
1
2
3
5
8
13
21
34
──
```

## Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--url <url>` | `http://127.0.0.1:8199/v1/chat/completions` | OpenAI-compatible endpoint |
| `--model <name>` | `local` | Model name sent to the server |
| `--system <path>` | `system_prompt.txt` | System prompt file |
| `--no-exec` | off | Don't execute code blocks, just show them |
| `--retry` | off | Auto-retry up to 3 times when extracted code fails |

## Slash commands

At the `you>` prompt:

- `/reset` — clear conversation (keeps system prompt)
- `/save <file>` — save conversation as JSON
- `/load <file>` — resume a saved conversation
- `/help` — list the above

## Project layout

```
.
├── src/
│   ├── hembot.hml        # Agent entry point (main loop, I/O, chat)
│   ├── extract.hml       # Pure helpers for parsing LLM responses
│   └── config.hml        # CLI argument parsing and defaults
├── tests/
│   ├── test_extract.hml  # 11 unit tests for extraction
│   └── test_config.hml   # 7 unit tests for config
├── .github/workflows/
│   └── test.yml          # CI: build Hemlock, run the unit tests
├── system_prompt.txt     # The winning hembench prompt
├── package.json          # hpm metadata
└── README.md
```

## Testing

```bash
# Run unit tests (no LLM needed)
hemlock tests/test_extract.hml
hemlock tests/test_config.hml

# Or via hpm (if you have a working hpm build)
hpm test
```

CI builds Hemlock from source on each push/PR and runs the full test suite.

## Why was this system prompt chosen?

The `system_prompt.txt` shipped here won a prompt sweep on Hemlock-Apothecary-7B (Q8_0) using [hembench](https://github.com/hemlang/hemlock/tree/main/benchmark). It beat the benchmark's baseline prompt by ~13 points overall and pushed L4 (systems programming) from 57% to 86% pass rate.

Key ingredients:
- Hembot persona (aligns with how the base model was fine-tuned)
- Mention of interpreter availability so the model "mentally traces" before writing code
- Seven common-pitfall reminders (semicolons, `print()` single-arg, `/` float, `ptr_deref_*`, etc.)

## License

MIT
