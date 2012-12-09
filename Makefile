.PHONY: compile clean setup test

bin = node_modules/.bin

compile:
	@$(bin)/coffee --compile --output lib src

clean:
	@rm -rf node_modules
	@git checkout -- lib

setup:
	@npm install

test:
	@$(bin)/mocha test --compilers coffee:coffee-script --reporter spec
