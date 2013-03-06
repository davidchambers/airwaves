.PHONY: clean release setup test

bin = node_modules/.bin

lib/airwaves.js: src/airwaves.coffee
	@cat $< | $(bin)/coffee --compile --stdio > $@

clean:
	@rm -rf lib/*
	@rm -rf node_modules

release:
ifndef VERSION
	$(error VERSION not set)
endif
	@sed -i '' 's!\("version": "\)[0-9.]*\("\)!\1$(VERSION)\2!' package.json
	@sed -i '' "s!\(version: '\)[0-9.]*\('\)!\1$(VERSION)\2!" src/airwaves.coffee
	@make
	@git commit --all --message $(VERSION)
	@echo 'remember to run `npm publish`'

setup:
	@npm install

test:
	@$(bin)/mocha test --compilers coffee:coffee-script
