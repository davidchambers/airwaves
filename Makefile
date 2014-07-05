COFFEE = node_modules/.bin/coffee
ISTANBUL = node_modules/.bin/istanbul
XYZ = node_modules/.bin/xyz --message X.Y.Z --tag X.Y.Z --repo git@github.com:davidchambers/airwaves.git --script scripts/prepublish

SRC = $(shell find src -name '*.coffee')
LIB = $(patsubst src/%.coffee,lib/%.js,$(SRC))


.PHONY: all
all: $(LIB)

lib/%.js: src/%.coffee
	mkdir -p $(@D)
	$(COFFEE) --compile --print -- $< | \
		sed -e 's!\(__indexOf = .* ||\)!\1 /* istanbul ignore next */!' -e "s!'\(istanbul .*\)';!/* \1 */!" >$@


.PHONY: clean
clean:
	rm -f -- $(LIB)


.PHONY: release-major release-minor release-patch
release-major: LEVEL = major
release-minor: LEVEL = minor
release-patch: LEVEL = patch

release-major release-minor release-patch:
	@$(XYZ) --increment $(LEVEL)


.PHONY: setup
setup:
	npm install
	make clean
	git update-index --assume-unchanged -- $(LIB)


.PHONY: test
test: all
	$(ISTANBUL) cover node_modules/.bin/_mocha -- --compilers coffee:coffee-script/register
