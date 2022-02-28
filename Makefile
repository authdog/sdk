BIN_NPX := npx
BIN_LERNA := $(BIN_NPX) lerna
# lerna commands
LERNA_RUN := $(BIN_LERNA) run

build_libs:
	$(LERNA_RUN) tsc

dev_react:
	$(LERNA_RUN) dev_react --scope={@authdog/web-sdk,@authdog/demo-nextjs} --stream

install:
	yarn install

test:
	$(LERNA_RUN) test --stream

pretty:
	$(BIN_NPX) prettier --write .


