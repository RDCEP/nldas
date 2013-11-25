nldasPsimsReady <- raster( nldasMask)
dataType( nldasPsimsReady) <- "LOG1S"
nldasPsimsReady[] <- NA

psimsFiles <- list.files(
  "data/psims",
  patt="psims\\.nc$",
  recursive= TRUE)
psimsRowCol <- data.matrix(
  ldply( str_split( psimsFiles, "/"), rbind)[, 1:2])

nldasPsimsReadyCells <- cellFromXY(
  nldasPsimsReady,
  xyFromCell(
    world,
    cellFromRowCol(
      world,
      psimsRowCol[,1],
      psimsRowCol[,2])))

nldasPsimsReady[ nldasPsimsReadyCells] <- 1

nldasPsimsReady <- writeRaster(
  nldasPsimsReady,
  filename= "data/nldasPsimsReady.tif",
  overwrite= TRUE)
