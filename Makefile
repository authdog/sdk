BIN_NPX := npx
BIN_LERNA := $(BIN_NPX) lerna
# lerna commands
LERNA_PUBLISH := $(BIN_LERNA) publish
LERNA_RUN := $(BIN_LERNA) run

PKG_FOLDER := packages


# netlify
BIN_NETLIFY := $(BIN_NPX) netlify
NETLIFY_DEPLOY := $(BIN_NETLIFY) deploy

DEMO_NEXTJS_PKG_NAME := demo-nextjs
DEMO_NEXTJS_SITE_ID := "0862262d-87e4-4b2c-a9cf-16ba26570352"


build_libs:
	$(LERNA_RUN) tsc

publish_libs:
	$(LERNA_PUBLISH)

dev_react:
	$(LERNA_RUN) --scope={@authdog/web-sdk,@authdog/demo-nextjs} dev_react

build_react_demo:
	export STAGE=prod && $(LERNA_RUN) build_react --scope={@authdog/web-sdk,@authdog/demo-nextjs} --stream

deploy_demo_react:
	make build_react_demo && \
	NETLIFY_SITE_ID=$(DEMO_NEXTJS_SITE_ID) $(NETLIFY_DEPLOY) \
		--dir=$(PKG_FOLDER)/$(DEMO_NEXTJS_PKG_NAME)/out --prod

install:
	yarn install && \
	npx lerna run install_deps --stream

test:
	$(LERNA_RUN) test --stream

pretty:
	$(BIN_NPX) prettier --write .

