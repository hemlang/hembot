# Hembot

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
   hemlock hembot.hml
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
| `--model <name>` | `local` | Model name to send to server |
| `--system <path>` | `system_prompt.txt` | System prompt file |
| `--no-exec` | off | Don't execute code blocks, just show them |
| `--retry` | off | Auto-retry up to 3 times when extracted code fails |

## Slash commands (at the prompt)

- `/reset` — clear conversation (keeps system prompt)
- `/save <file>` — save conversation as JSON
- `/load <file>` — resume a saved conversation
- `/help` — this list

## Why was this prompt chosen?

The `system_prompt.txt` shipped here is the winner from a benchmark sweep on Hemlock-Apothecary-7B (Q8_0): it beat the baseline prompt by ~13 points on [hembench](https://github.com/hemlang/hemlock/tree/main/benchmark), taking L4 (systems programming) from 57% to 86%. See the `hemlock` repo's benchmark results for details.

## License

MIT
