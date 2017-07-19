
OUTDIR := iconpngs
INFILE := IconSource.png

all: dir files


dir:
	@echo creating $(OUTDIR)
	mkdir -p $(OUTDIR)

files:
	@echo
	convert $(INFILE) -geometry 20x20 $(OUTDIR)/20_20.png
	convert $(INFILE) -geometry 40x40 $(OUTDIR)/40_40.png
	convert $(INFILE) -geometry 60x60 $(OUTDIR)/60_60.png
	convert $(INFILE) -geometry 80x80 $(OUTDIR)/80_80.png
	@echo
	convert $(INFILE) -geometry 120x120 $(OUTDIR)/120_120.png
	convert $(INFILE) -geometry 180x180 $(OUTDIR)/180_180.png
	@echo
	convert $(INFILE) -geometry 29x29 $(OUTDIR)/29_29.png
	convert $(INFILE) -geometry 58x58 $(OUTDIR)/58_58.png
	convert $(INFILE) -geometry 87x87 $(OUTDIR)/87_87.png
	@echo
	convert $(INFILE) -geometry 76x76 $(OUTDIR)/76_76.png
	convert $(INFILE) -geometry 152x152 $(OUTDIR)/152_152.png
	convert $(INFILE) -geometry 167x167 $(OUTDIR)/167_167.png
	@echo
	convert $(INFILE) -geometry 1024x1024 $(OUTDIR)/1024_1024.png

	


clean:
	@echo removing $(OUTDIR)
	rm -r $(OUTDIR)
