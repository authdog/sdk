BIN_NPX := npx
BIN_LERNA := $(BIN_NPX) lerna

# lerna commands
LERNA_RUN := $(BIN_LERNA) run

test:
	$(LERNA_RUN) test

build:
	$(LERNA_RUN) tsc