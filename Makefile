
.PHONY=all clean distclean help package upload upload_x86 upload_x86_64
PKG_NAME:=chere
MAIN_VER:=$(shell src/chere -v | sed "s/.*version //g")
CYG_VER:=1

BIN_IPATH:=bin
MAN_IPATH:=usr/share/man/man1

HAVE_BIN=$(wildcard $(BIN_IPATH))
HAVE_MAN=$(wildcard $(MAN_IPATH))

ifneq ($(HAVE_BIN),$(BIN_IPATH))
  $(shell mkdir -p $(BIN_IPATH))
endif
ifneq ($(HAVE_MAN),$(MAN_IPATH))
  $(shell mkdir -p $(MAN_IPATH))
endif

INSTALL_ITEMS:=$(BIN_IPATH)/chere $(BIN_IPATH)/xhere $(MAN_IPATH)/chere.1.gz

VPATH:=src

all :
	@echo Done.

help :
	@echo Targets:
	@echo  all distclean clean help package

TARBALL:=$(PKG_NAME)-$(MAIN_VER)-$(CYG_VER).tar.bz2
package : clean $(TARBALL)

upload_% : package
	lftp -c "open -u cygwin, sftp://cygwin.com/; cd $*/release/$(PKG_NAME); put $(TARBALL); put setup.hint; put /dev/null -o !ready"

upload : upload_x86 upload_x86_64

%.tar.bz2 : $(INSTALL_ITEMS)
	tar -cjf $@ $^

# Remove emacs temporaries
clean :
	find -name "*~" | xargs -r rm

distclean :
	find $(BIN_IPATH) -name "*" -type f | xargs -r rm
	find $(MAN_IPATH) -name "*" -type f | xargs -r rm

$(BIN_IPATH)/%here : %here
	cp $< $@

$(MAN_IPATH)/%.gz : %
	gzip -c $< > $@
