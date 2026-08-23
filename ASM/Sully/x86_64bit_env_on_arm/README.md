# x86-64 (Intel) dev environment on an ARM Mac

Write, build, run, and debug **x86-64 Linux** code (NASM assembly, C, …) on
Apple Silicon, using Docker's amd64 emulation. Plug and play: no per-project
configuration.

## Use it in any project

1. Copy this whole directory into the project root:

   ```
   my_project/
   ├── x86_64bit_env_on_arm/   <- this directory
   ├── my_code.s
   └── ...
   ```

2. One command:

   ```sh
   cd x86_64bit_env_on_arm && make shell
   ```

You land in an x86-64 Ubuntu 24.04 shell with the project root mounted at
`/app` — edit on the Mac, build/run in the shell. The first `make shell` ever
builds the image (a few minutes); after that it starts instantly, and because
the image names are fixed (`x86_64_env/asm`, `x86_64_env/dbg`) **every project
that carries this directory reuses the same images** — no rebuild per project.

Only requirement: Docker Desktop running.

## Commands

| Command | What it does |
|---|---|
| `make shell` (or just `make`) | x86-64 Linux shell in the project root |
| `make run CMD="nasm -v"` | run a one-off command in the container |
| `make build` | (re)build the images (e.g. after editing the Dockerfile) |
| `make debug BIN=./a.out ARGS="1 2 3"` | gdb the binary via the debugger sidecar |
| `make stop` | stop and remove containers |
| `make clean` | stop + remove the built images |

## What's inside

- **`asm` service** (linux/amd64): `nasm`, `gcc`, `clang`, `make`, `gdb`,
  `valgrind`, `strace`, `git`, `vim` — the full Intel toolchain.
- **gdb inside the shell just works.** Native ptrace can't cross the
  emulation, so a transparent shim ([gdb-wrap](gdb-wrap)) reroutes
  `gdb ./a.out ...` through `qemu-x86_64`'s gdb stub — same usage, including
  `-x <config>`. Set `REAL_GDB_NATIVE=1` to bypass the shim.
- **`dbg` service** (linux/arm64): native `gdb-multiarch` attached to qemu's
  gdb stub — this is what `make debug` uses.
- **[gdbcfg](gdbcfg)** — bundled gdb config: Intel disassembly flavor plus a
  live view on every stop (next instructions at `$rip`, all GP registers,
  stack, eflags), ending at a breakpoint on `main` — edit that line to your
  function under test. `make debug` loads it automatically; a `gdbcfg` in the
  **project root** takes priority if you want a per-project one (`start`/`run`
  lines are stripped for the remote stub; use `continue`). It is also mounted
  in both containers at `/gdbcfg.default`, so inside `make shell` you can run
  `gdb ./a.out -q -x /gdbcfg.default`.
