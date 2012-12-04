.PHONY: compile clean setup test

compile:
	@node_modules/coffee-script/bin/coffee --compile --output lib src

clean:
	@rm -rf node_modules
	@git checkout -- lib

setup:
	@npm install

test:
	@node_modules/mocha/bin/mocha test --compilers coffee:coffee-script --reporter spec
