#!/usr/bin/R --vanilla

library( raster)

nldasMask5minByte <- setMinMax(
  raster( "data/output/nldasMask5minByte.tif"))

nldasMask5min <-
  raster( nldasMask5minByte)
NAvalue( nldasMask5min) <- 255

nldasMask5min[] <-
  ifelse( !is.na( nldasMask5minByte[]), 1, NA)

nldasMask5min <- writeRaster(
  nldasMask5min,
  filename= "data/output/nldasMask5min.tif",
  overwrite= TRUE,
  datatype= "LOG1S")

nldasCells5min <- which( as.logical( nldasMask5min[]))

cat(
  nldasCells5min,
  file= "data/output/nldasCells5min.txt",
  sep= "\n")
