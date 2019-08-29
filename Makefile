prefix ?= /usr/local
bindir = $(prefix)/bin

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/Palmyra" "$(bindir)"

uninstall:
	rm -rf "$(bindir)/Palmyra"

clean:
	rm -rf .build

.PHONY: build install uninstall clean