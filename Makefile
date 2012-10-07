.PHONY: compile setup test

compile:
	@./node_modules/coffee-script/bin/coffee --compile --print airwaves

setup:
	@npm install

test:
	@./node_modules/mocha/bin/mocha test --compilers coffee:coffee-script --reporter spec
