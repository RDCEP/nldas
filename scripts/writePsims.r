#!/home/nbest/local/bin/r

## --interactive

stripe    <- as.integer( argv[ 1])
## stripe    <- 14

degreesPerStripe <- 0.5

##startYear <- as.Date( argv[ 1])
##endYear   <- as.Date( argv[ 2])
startYear <- 1979
endYear   <- 2013
years <- startYear:endYear


library( ncdf4)
library( raster)
library( abind)
## library( ascii)
## options( asciiType= "org")
library( stringr)

library( doMC)  
## registerDoMC( multicore:::detectCores())
registerDoMC( 4)

## options( error= recover)

## annualPaths <- sprintf(
##   "/scratch/midway/nbest/data/annual/%d", years)

nldasVars <- c(
  "tmin", "tmax", "precip", "solar",
  "pres",  "spfh", "u", "v") 

nldasMask <- setMinMax(
  raster( "data/output/nldasRegion.tif"))

nldasRes <- res( nldasMask)[ 1]
  
nldasAnchorPoints <-
  cbind(
    lon= seq(
      from= xmin( nldasMask) + nldasRes / 2,
      to= xmax( nldasMask) - nldasRes / 2,
      by= degreesPerStripe), 
    lat= ymax( nldasMask))

readNldasValues <-
  function(
    ncFn, lon,
    n= as.integer( degreesPerStripe / nldasRes))
  {
    nc <- nc_open( ncFn)
    varid <- names( nc$var)[ 1]
  column <-
    which( nc$dim$lon$vals > lon)[ 1] -1
  m <-
    ncvar_get(
      nc,
      varid= varid,
      start= c( column, 1, 1),
      count= c( n, -1, -1),
                                        # collapse_degen seems to have
      collapse_degen= FALSE)            # no effect
  ## nldasDays <- seq(
  ##   from= as.Date(
  ##     sprintf(
  ##       "%s-01-01",
  ##       str_match( nc$filename, "_([12][0-9]{3})\\.nc$")[,2])),
  ##   length.out= length( nc$dim$time$vals),
  ##   by= "day")
  nldasDays <- seq(
    from= as.Date( "1979-01-01"),
    length.out= length( nc$dim$time$vals),
    by= "day")
  dn <- list(
    longitude= nc$dim$lon$vals[ column:(column +n -1)],
    latitude=  nc$dim$lat$vals, ##[ row:( row +nrow( nldasMask) -1)],
    time= as.character( nldasDays))
  ## dim(m) <- c( dim(m), 1)             # to compensate for apparent
  dimnames( m) <- dn                    # collapse_degen bug
  nc_close( nc)
  m
}

## cat( sprintf( "Time to load data for stripe %d:", stripe))

## system.time( {

## This does not work because the annual files are in the original
## 0.125\deg grid
##
## nldasValues <-
##   foreach(
##     var= nldasVars) %:%
##     ## var= nldasVars[1:2]) %:%
##   foreach(
##     year= years,
##     .combine= abind,
##     .multicombine= TRUE ) %dopar% {
##       readNldasValues(
##         sprintf( "/scratch/midway/nbest/annual/%1$s_nldas_%2$d.nc4", var, year),
##         nldasAnchorPoints[ stripe, 1])
##     }

## nldasValues <- list(
##   precip= readNldasValues(
##     "/scratch/midway/nbest/full/precip_nldas_1979-2013.nc4",
##     nldasAnchorPoints[ stripe, 1],
##     n=6))

nldasValues <-
  foreach(
    var= nldasVars) %dopar% {
      readNldasValues(
        sprintf( "/scratch/midway/nbest/full/%1$s_nldas_1979-2013.nc4", var),
        nldasAnchorPoints[ stripe, 1])
    }

names( nldasValues) <- nldasVars
for( var in nldasVars)
  names( dimnames( nldasValues[[ var]])) <-
  c( "longitude", "latitude", "time")

## })

ncDimsFunc <- function(
  xy, ncDays,
  ncTimeName= "time",
  ncTimeUnits= "days since 1978-12-31 00:00:00") {
  list(
    ncdim_def(
      name= "longitude",
      units= "degrees_east",
      vals= xy[[ "lon"]]),
    ncdim_def(
      name= "latitude",
      units= "degrees_north",
      vals= xy[[ "lat"]]),
    ncdim_def(
      name= ncTimeName,
      units= ncTimeUnits,
      vals= ncDays,
      unlim= TRUE))
}

ncVarsFunc <- function(
  xy, ncDays,
  ncGroupName= "narr",
  ncTimeUnits= "days since 1978-12-31 00:00:00",
  compression= NA,
  missval= ncdf4:::default_missval_ncdf4()
  ) {
  list(
    ncvar_def(
      name= "tmin",
      units= "C",
      longname= "daily minimum temperature",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval),
    ncvar_def(
      name= "tmax",
      units= "C",
      longname= "daily maximum temperature",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval),
    ncvar_def(
      name= "precip",
      units= "mm",
      longname= "daily total precipitation",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval),
    ncvar_def(
      name= "solar",
      units= "MJ/m^2/day",
      longname= "daily average downward short-wave radiation flux",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval),
    ncvar_def(
      name= "pres",
      units= "Pa",
      longname= "pressure",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval),
    ncvar_def(
      name= "spfh",
      units= "kg/kg",
      longname= "specific humidity",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval),
    ncvar_def(
      name= "u",
      units= "m/s",
      longname= "u wind",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval),
    ncvar_def(
      name= "v",
      units= "m/s",
      longname= "v wind",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression,
      missval= missval))
}

psimsNcFromXY <- function(
  xy, ncDays,
  resWorld= 0.5,
  ncTimeUnits= "days since 1860-01-01 00:00:00") {
  if( xy[[ "lon"]] > 180) {
    xy[[ "lon"]] <- xy[[ "lon"]] - 360
  }
  world <- raster()
  res( world) <- resWorld
  rowCol <- as.list( rowColFromCell( world, cellFromXY( world, xy))[1,])
  ncFile <- sprintf( "data/psims/%1$03d/%2$03d/%1$03d_%2$03d.psims.nc", rowCol$row, rowCol$col)
  if( !file.exists( dirname( ncFile))) {
    dir.create( path= dirname( ncFile), recursive= TRUE)
  }
  if( file.exists( ncFile)) file.remove( ncFile)
  nc_create(
    filename= ncFile,
    vars= ncVarsFunc( xy, ncDays, 
      ncGroupName= "nldas",
      ncTimeUnits= ncTimeUnits),
    force_v4= FALSE,
    verbose= FALSE)
}

writePsimsNc <- function( nldasValues, col, row) {
  xy <- c(
    lon= as.numeric( dimnames( nldasValues[[ "tmin"]])$longitude[ col]),
    lat= as.numeric( dimnames( nldasValues[[ "tmin"]])$latitude[  row]))
  if( is.na( extract( nldasMask, rbind( xy)))) return( NA)
  psimsNc <- psimsNcFromXY(
    xy,
    ncDays= as.integer(
     as.Date(  dimnames( nldasValues[[ "tmin"]])$time) -
      as.Date( "1978-12-31")),
    resWorld= nldasRes,
    ncTimeUnits= "days since 1978-12-31 23:00:00")  
  for( var in names( nldasValues)) {
    vals <- nldasValues[[ var]][ col, row,]
    vals <- switch(
      var,
      solar= vals *86400 /1000000, # Change units to MJ /m^2 /day
      tmin= vals -273.15,          # change K to C
      tmax= vals -273.15,
      ## precip= vals *3600 *24,      # Change mm/s to mm/day
      vals )
    ## browser()
    ncvar_put(
      nc= psimsNc,
      varid= var, ## sprintf( "nldas/%s", var),
      vals= vals,
      count= c( 1, 1, -1))
  }
  nc_close( psimsNc)
  psimsNc$filename
}

registerDoMC()

## time <-
##   system.time(

psimsNcFile <-
  foreach( col= 1:dim( nldasValues$tmax)[1], .combine= c) %:%
  foreach( row= 1:dim( nldasValues$tmax)[2], .combine= c) %dopar% {
    writePsimsNc( nldasValues, col, row)
  }

##   )

cat(
  psimsNcFile,
  ## sprintf( "\n\nTime to write %d files:", length( psimsNcFile)),
  sep= "\n")

## print( time)
