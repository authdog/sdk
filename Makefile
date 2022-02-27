BIN_NPX := npx
BIN_LERNA := $(BIN_NPX) lerna

# lerna commands
LERNA_RUN := $(BIN_LERNA) run

install:
	yarn install

test:
	$(LERNA_RUN) test

build:
	$(LERNA_RUN) tsc