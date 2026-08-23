# Force Intel/x86-64 toolchain even on Apple Silicon
FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y --no-install-recommends \
    nasm gcc make gdb build-essential vim less git strace \
    clang libclang-rt-dev valgrind ncurses-bin qemu-user \
 && rm -rf /var/lib/apt/lists/*

# shim so `gdb ./a.out -q -x gdbcfg` works despite the emulation:
# it reroutes through qemu-x86_64's gdb stub (see gdb-wrap)
COPY gdb-wrap /usr/local/bin/gdb
RUN chmod +x /usr/local/bin/gdb

# testers use tput for colors; needs a TERM even without a tty
ENV TERM=xterm-256color

WORKDIR /app
