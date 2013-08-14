#!/home/nbest/local/bin/r

## --interactive

##startDate <- as.Date( argv[ 1])
##endDate   <- as.Date( argv[ 2])
stripe    <- as.integer( argv[ 1])

startDate <- as.Date( "1979-01-01")
endDate   <- as.Date( "2013-07-04")
## stripe    <- 32

library( ncdf4)
library( raster)
library( abind)
## library( ascii)
## options( asciiType= "org")
library( stringr)

library( doMC)  
registerDoMC( multicore:::detectCores())
## registerDoMC( 4)

## options( error= recover)

nldasDates <- seq(
  from= startDate,
  to=   endDate,
  by= "day")

dailyFiles <- format(
  nldasDates,
  "data/NLDAS_FORA0125_H.002/%Y/%j/NLDAS_FORA0125_H.A%Y%m%d.daily.nc")
  
nldasVars <- c( "precip", "solar", "tmin", "tmax")

nldasMask <- setMinMax(
  raster( "data/output/nldasRegion.tif"))
  
nldasAnchorPoints <- {
  nldasRes <- res( nldasMask)[ 1]
  cbind(
    lon= seq(
      from= xmin( nldasMask) + nldasRes / 2,
      to= xmax( nldasMask) - nldasRes / 2,
      by= 2), 
    lat= ymax( nldasMask))
}

readNldasValues <- function(  ncFn, varid, lon, n= 24) {
  nc <- nc_open( ncFn)
  column <-
    which( nc$dim$lon$vals > lon)[ 1]
  row <-
    which( nc$dim$lat$vals > ymin( nldasMask))[ 1]
  m <-
    ncvar_get(
      nc,
      varid= varid,
      start= c( column, row, 1,
        if( varid %in% c( "tmin", "tmax")) 1 else NULL),
      count= c( n, nrow( nldasMask), 1,
        if( varid %in% c( "tmin", "tmax")) 1 else NULL),
                                        # collapse_degen seems to have
      collapse_degen= FALSE)            # no effect
  nldasDays <-
    as.integer(
      as.Date(
        str_extract(
          nc$dim$time$units,
          "....-..-..")
        ) - as.Date( "1978-12-31"))
  dn <- list(
    longitude= nc$dim$lon$vals[ column:(column +n -1)],
    latitude=  nc$dim$lat$vals[ row:( row +nrow( nldasMask) -1)],
    time= nldasDays)
  dim(m) <- c( dim(m), 1)             # to compensate for apparent
  dimnames( m) <- dn                    # collapse_degen bug
  m
}

## cat( sprintf( "Time to load data for stripe %d:", stripe))

## system.time( {

nldasValues <-
  foreach(
    var= nldasVars) %:%
  foreach(
    ncFn= dailyFiles,
    .combine= abind,
    .multicombine= TRUE ) %dopar% {
      readNldasValues(
        ncFn,
        var,
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
  compression= NA
  ) {
  list(
    ncvar_def(
      ##name= sprintf( "%s/tmin", ncGroupName),
      name= "tmin",
      units= "C",
      longname= "daily minimum temperature",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),
      compression= compression),
    ncvar_def(
      ## name= sprintf( "%s/tmax", ncGroupName),
      name= "tmax",
      units= "C",
      longname= "daily maximum temperature",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"),  ## sprintf( "%s/time", ncGroupName)),
      compression= compression),
    ncvar_def(
      ## name= sprintf( "%s/precip", ncGroupName),
      name= "precip",
      units= "mm",
      longname= "daily total precipitation",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"), ## sprintf( "%s/time", ncGroupName)),
      compression= compression),
    ncvar_def(
      ## name= sprintf( "%s/solar", ncGroupName),
      name= "solar",
      units= "MJ/m^2/day",
      longname= "daily average downward short-wave radiation flux",
      dim= ncDimsFunc( xy, ncDays,
        ncTimeUnits,
        ncTimeName= "time"), ## sprintf( "%s/time", ncGroupName)),            
      compression= compression))
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
      dimnames( nldasValues[[ "tmin"]])$time),
    resWorld= 5/60,
    ncTimeUnits= "days since 1978-12-31 23:00:00")  
  for( var in names( nldasValues)) {
    vals <- nldasValues[[ var]][ col, row,]
    vals <- switch( var,
        solar= vals *86400 /1000000, # Change units to MJ /m^2 /day
        tmin= vals -273.15,          # change K to C
        tmax= vals -273.15,
        precip= vals *3600 *24)      # Change mm/s to mm/day
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
