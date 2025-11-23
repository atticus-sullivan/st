.PHONY: all clean dist install pkg clean_pkg pkg-dev pkg-release install-dev install-release

# st - simple terminal
# See LICENSE file for copyright and license details.
.POSIX:

include config.mk

SRC = st.c x.c
OBJ = $(SRC:.c=.o)

all: st

config.h:
	cp config.def.h config.h

.c.o:
	$(CC) $(STCFLAGS) -c $<

st.o: config.h st.h win.h
x.o: arg.h config.h st.h win.h

$(OBJ): config.h config.mk

st: clean $(OBJ)
	$(CC) -o $@ $(OBJ) $(STLDFLAGS)

clean:
	rm -f st $(OBJ) st-$(VERSION).tar.gz

dist: clean
	mkdir -p st-$(VERSION)
	cp -R FAQ LEGACY TODO LICENSE Makefile README config.mk\
		config.def.h st.info st.1 arg.h st.h win.h $(SRC)\
		st-$(VERSION)
	tar -cf - st-$(VERSION) | gzip > st-$(VERSION).tar.gz
	rm -rf st-$(VERSION)

install: install-dev

install-dev: pkg-dev
	f="$$(find . -iname "st-dev-[a-f0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | sort | tail -n1)" && sudo pacman -U "$$f"

install-release: pkg-release
	f="$$(find . -iname "st-[0-9.]*-x86_64.pkg.tar.zst" | grep -v "debug" | sort | tail -n1)" && sudo pacman -U "$$f"

pkg: pkg-dev

pkg-release:
	makepkg -D pkg-release -c
	mv pkg-release/*.tar.zst .
	curl -X PUT https://git.atticus-sullivan.de/api/packages/wm-tools/arch/extras/ --user lukas:$$(secret-tool lookup name "git.atticus-sullivan.de pkg-upload") --header "Content-Type: application/octet-stream" --data-binary "@$$(readlink -f $$(find . -iname 'st-[0-9.]*-x86_64.pkg.tar.zst' | grep -v 'debug' | sort | tail -n1))"

pkg-dev:
	makepkg -D pkg-dev -c
	mv pkg-dev/*.tar.zst .

clean_pkg:
	-$(RM) *.tar.gz *.tar.zst
