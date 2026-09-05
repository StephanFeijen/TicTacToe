# TicTacToe

A Business Central Per-Tenant Extension (PTE) that implements a playable game of Tic-Tac-Toe inside BC, built with [AL-Go for GitHub](https://aka.ms/AL-Go).

## What it does

- **Board** (`TTT Board` table/page) — a 3x3 grid stored as nine cell fields. Moves are validated server-side: only one cell may change per move, a filled cell cannot be overwritten, and a move must be placed by the player whose turn it is.
- **Marks & status** (`TTT Mark`, `TTT Game Status` enums) — tracks `None`/`X`/`O` per cell and the game's overall state (`Open`, `X Won`, `O Won`, `Draw`).

## Project structure

```
TicTacToe/
  app/
    Game/       Tic-Tac-Toe board, page, and enums
    Setup/      Extension setup, KPIs, permissions, role center
    Integration/ Copilot capability registration, install/upgrade logic
    Example/    Sample customer card extension and public API
  .vscode/      Editor settings (launch.json is gitignored, machine-specific)
.AL-Go/         AL-Go for GitHub Actions CI/CD configuration
```

## Development

Open `TicTacToe.code-workspace` in VS Code (includes the `TicTacToe/` app folder and `.AL-Go/`). Build and publish via the AL Language extension, or let AL-Go's CI workflow build and test on push/PR.

## Publisher

`Stephan` — id range `50000-99999`.
