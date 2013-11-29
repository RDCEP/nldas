Makeflow: scripts/writeMakeflow.R
	$<

data/output/nldasRegionByte.tif: scripts/writeNldasRegion.sh
	$<

data/output/nldasRegion.tif data/output/nldas_5min.grid: scripts/writeNldasRegion.R
	$<

data/output/nldasMask5min.tif data/output/nldasCells5min.txt: scripts/writeNldasMask.R data/output/nldasMask5minByte.tif
	$<

data/output/nldasMask5minByte.tif: scripts/writeNldasMask.sh data/NLDAS_FORA0125_H.002 
	$<

data/NLDAS_FORA0125_H.002: scripts/parallelWget.sh data/nldasDataUrls
	$<

data/nldasDataUrls: scripts/nldasDownload.R
	$< > $@

$SCRIPTS  = scripts/parallelWget.sh 
$SCRIPTS += scripts/nldasDownload.R 
$SCRIPTS += scripts/writeNldasMask.sh
$SCRIPTS += scripts/writeNldasMask.R
$SCRIPTS += scripts/writeNldasRegion.R
$SCRIPTS += scripts/writeNldasRegion.sh
$SCRIPTS += scripts/writeMakeflow.R

$SCRIPTS: tangle

tangle: nldas.org
	emacs --quick --batch \
	  --file=nldas.org -f org-babel-tangle 2>&1 \
	  | grep tangle
	rsync -arq tangle/ scripts 
	chmod ug+x scripts/*.{R,sh}

# TODO check for symlink existence.  This only needs to happen once per clone.

# ln -fs ../../git-hooks/pre-commit .git/hooks/pre-commit

.PHONY: tangle
