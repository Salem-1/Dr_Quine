# x86-64 (Intel) Linux dev environment on an ARM Mac — Docker + QEMU.
# Drop this directory into any project's root, cd into it, run `make shell`.
#
#   make shell    x86-64 Linux shell, project mounted at /app     (default)
#   make run CMD="nasm -v"    run one command in the container
#   make build    (re)build the docker images
#   make debug [BIN=./a.out] [ARGS="..."]    gdb via the dbg sidecar
#   make stop     stop and remove containers
#   make clean    stop + also remove the built images
#   make help     show this text

.DEFAULT_GOAL := shell

BIN  ?= ./a.out
ARGS ?=
CMD  ?= uname -m

docker-up:
	@docker info >/dev/null 2>&1 || \
		{ echo "Docker daemon isn't running — start Docker Desktop first" >&2; exit 1; }

shell: docker-up
	docker compose run --rm asm bash

run: docker-up
	docker compose run --rm asm sh -c '$(CMD)'

build: docker-up
	docker compose build

# native gdb can't ptrace under x86 emulation, so: qemu-x86_64 runs BIN with
# its gdb stub on :1234 and native arm64 gdb-multiarch connects to it.
# Config: `gdbcfg` in the project root if present, else the bundled one
# (mounted at /gdbcfg.default) — minus start/run lines, which remote stubs
# don't support (`continue` instead).
debug: docker-up
	docker compose run --rm dbg sh -c '\
		src=; [ -f /gdbcfg.default ] && src=/gdbcfg.default; \
		[ -f gdbcfg ] && src=gdbcfg; \
		cfg=; if [ -n "$$src" ]; then \
			sed -E "/^[[:space:]]*(start|run)([[:space:]]|$$)/d" $$src > /tmp/gdbrc; \
			cfg="-x /tmp/gdbrc"; \
		fi; \
		qemu-x86_64 -g 1234 $(BIN) $(ARGS) & \
		sleep 0.5; \
		gdb-multiarch -q $(BIN) -ex "target remote localhost:1234" $$cfg'

stop: docker-up
	docker compose down --remove-orphans

clean: docker-up
	docker compose down --remove-orphans --rmi local

help:
	@sed -n '2,10p' Makefile | sed 's/^# \{0,3\}//'

.PHONY: docker-up shell run build debug stop clean help
