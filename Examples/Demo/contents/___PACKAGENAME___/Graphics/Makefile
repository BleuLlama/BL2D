



# to smallen images, use imagemagick's "mogrify"
#mogrify -geometry 50%x50% * ; cd ..


# set this to the root of your BL2D Distro (for finding bss.pl)
BL2DDIR := /Users/sdl/src/git/BL2D/


# list of directories to source imagery from
DIRLIST := \
	testImgs1 \
	testImgs2 \
	testImgs3

SPRITESHEET := test_sprites

all: $(SPRITESHEET)


$(SPRITESHEET):
	ls $(BL2DDIR)
	perl $(BL2DDIR)/Examples/bss.pl $@ $(DIRLIST)

.PHONY: $(SPRITESHEET)

clean:
	- rm -f test_sprites.png test_sprites.h test_sprites.plist
.PHONY: clean
