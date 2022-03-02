BIN_NPX := npx
BIN_LERNA := $(BIN_NPX) lerna
# lerna commands
LERNA_PUBLISH := $(BIN_LERNA) publish
LERNA_RUN := $(BIN_LERNA) run

build_libs:
	$(LERNA_RUN) tsc

# lerna_add:
# 	lerna add @my-scope-name/design-system-button --scope=@my-scope-name/my-design-system-form

publish_libs:
	$(LERNA_PUBLISH)

dev_react:
	$(LERNA_RUN) --scope={@authdog/web-sdk,@authdog/demo-nextjs} dev_react

# WIP
build_react:
	$(LERNA_RUN) build_react --scope={@authdog/web-sdk,@authdog/demo-nextjs} --stream

install:
	yarn install && \
	npx lerna run install_deps --stream

test:
	$(LERNA_RUN) test --stream

pretty:
	$(BIN_NPX) prettier --write .


