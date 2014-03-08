COFFEE = node_modules/.bin/coffee
ISTANBUL = node_modules/.bin/istanbul
SEMVER = node_modules/.bin/semver

JS_FILES = $(patsubst src/%.coffee,lib/%.js,$(shell find src -type f))


.PHONY: all
all: $(JS_FILES)

lib/%.js: src/%.coffee
	$(COFFEE) --compile --output $(@D) -- $<


.PHONY: clean
clean:
	rm -f -- $(JS_FILES)


.PHONY: release-patch release-minor release-major
VERSION = $(shell node -p 'require("./package.json").version')
release-patch: NEXT_VERSION = $(shell $(SEMVER) -i patch $(VERSION))
release-minor: NEXT_VERSION = $(shell $(SEMVER) -i minor $(VERSION))
release-major: NEXT_VERSION = $(shell $(SEMVER) -i major $(VERSION))
release-patch: release
release-minor: release
release-major: release

.PHONY: release
release:
	sed -i '' 's/"version": "[^"]*"/"version": "$(NEXT_VERSION)"/' package.json
	sed -i '' "s/, version: '[^']*'/, version: '$(NEXT_VERSION)'/" src/airwaves.coffee
	make
	git commit --all --message $(NEXT_VERSION)
	git tag $(NEXT_VERSION)
	@echo 'remember to run `npm publish`'


.PHONY: setup
setup:
	npm install


.PHONY: test
test: all
	$(ISTANBUL) cover node_modules/.bin/_mocha -- --compilers coffee:coffee-script/register
