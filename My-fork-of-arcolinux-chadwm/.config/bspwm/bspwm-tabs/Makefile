CC       ?= cc
CFLAGS   ?= -std=c99 -pedantic -Wall -Os
CPPFLAGS  = -D_DEFAULT_SOURCE -D_XOPEN_SOURCE=700L
LDLIBS    = -lX11 -lXinerama
PREFIX   ?= /usr/local

all: bspwm-tabs

bspwm-tabs: bspwm-tabs.c
	${CC} ${CFLAGS} ${CPPFLAGS} -o $@ $< ${LDLIBS}

clean:
	rm -f bspwm-tabs

install: all
	mkdir -p ${DESTDIR}${PREFIX}/bin
	cp -f bspwm-tabs ${DESTDIR}${PREFIX}/bin
	chmod 755 ${DESTDIR}${PREFIX}/bin/bspwm-tabs

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/bspwm-tabs

.PHONY: all clean install uninstall
