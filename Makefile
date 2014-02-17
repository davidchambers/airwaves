COFFEE = node_modules/.bin/coffee
MOCHA = node_modules/.bin/mocha --compilers coffee:coffee-script

JS_FILES = $(patsubst src/%.coffee,lib/%.js,$(shell find src -type f))


.PHONY: all
all: $(JS_FILES)

lib/%.js: src/%.coffee
	cat $< | $(COFFEE) --compile --stdio > $@


.PHONY: clean
clean:
	rm -f -- $(JS_FILES)
	rm -rf node_modules


.PHONY: release
release:
ifndef VERSION
	$(error VERSION not set)
endif
	sed -i '' 's!\("version": "\)[0-9.]*\("\)!\1$(VERSION)\2!' package.json
	sed -i '' "s!\(version: '\)[0-9.]*\('\)!\1$(VERSION)\2!" src/airwaves.coffee
	make
	git commit --all --message $(VERSION)
	@echo 'remember to run `npm publish`'


.PHONY: setup
setup:
	npm install


.PHONY: test
test:
	$(MOCHA)
