# Hembot — Makefile for local builds.
# `make build` produces a self-contained hembot binary via hemlockc.

NAME    := hembot
SRC     := src/hembot.hml
BIN     := $(NAME)
PREFIX  ?= /usr/local

TESTS   := tests/test_extract.hml tests/test_config.hml

.PHONY: all build test clean install uninstall run

all: build

build: $(BIN)

$(BIN): $(SRC) src/extract.hml src/config.hml
	hemlockc $(SRC) -o $@

test:
	@for t in $(TESTS); do \
		echo "── $$t ──"; \
		hemlock $$t || exit 1; \
	done

run:
	hemlock $(SRC)

clean:
	rm -f $(BIN) hembot-bin test_extract_bin test_config_bin

install: $(BIN)
	install -d $(DESTDIR)$(PREFIX)/bin
	install -m 755 $(BIN) $(DESTDIR)$(PREFIX)/bin/$(NAME)
	install -d $(DESTDIR)$(PREFIX)/share/$(NAME)
	install -m 644 system_prompt.txt $(DESTDIR)$(PREFIX)/share/$(NAME)/system_prompt.txt
	@echo "✓ installed $(NAME) → $(DESTDIR)$(PREFIX)/bin/"
	@echo "  prompt → $(DESTDIR)$(PREFIX)/share/$(NAME)/system_prompt.txt"

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/$(NAME)
	rm -rf $(DESTDIR)$(PREFIX)/share/$(NAME)
