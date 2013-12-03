#!/usr/bin/Rscript

library( raster)
nldasMask5min <- raster( "data/output/nldasMask5min.tif")
nldasRegion <- trim( nldasMask5min, filename= "data/output/nldasRegion.tif")

griddesFormat <- 
  "gridtype = lonlat
xsize    = %d
ysize    = %d
xfirst   = %13.8f
xinc     = %13.8f
yfirst   = %13.8f
yinc     = %13.8f\n"

griddes <- 
  sprintf(
    griddesFormat,
    ncol( nldasRegion),
    nrow( nldasRegion),
    xmin( nldasRegion),
    res( nldasRegion)[1],
    ymin( nldasRegion),
    res( nldasRegion)[2])

cat( griddes, file= "data/output/nldas_5min.grid")
