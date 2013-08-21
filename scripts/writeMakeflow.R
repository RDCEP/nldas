## date <- as.Date( "1979-01-01")

date <- seq(
  from= as.Date( "1980-01-01"),
  ## to= as.Date( "1979-12-31"),
  to=   as.Date( "2013-07-04"),
  by= "day")

snarfFile <- function( fn) {
  readChar( fn, file.info( fn)$size)
}

## maybe/someday implement this

## hourlyTemplate <-
##   "$dataDir/%1$s/NLDAS_FORA0125_H.A%2$s.0000.002.nc: $dataDir/%1$s/NLDAS_FORA0125_H.A%2$s.0000.002.grb $cdoGrid
## 	$cdoExecutable -f nc $cdoRemapArgs $dataDir/%1$s/NLDAS_FORA0125_H.A%2$s.0000.002.grb $dataDir/%1$s/NLDAS_FORA0125_H.A%2$s.0000.002.nc"

makeflowHeader <-   snarfFile( "data/nldas.makeflow.header")
makeflowTemplate <- readLines( "data/nldas.makeflow.sprintf")

## 1979/004  %1$s
## 19790104 %2$s

createHourlyMakeflow <- function(
  dateVector,
  makeflowHeader=   snarfFile( "data/nldas.makeflow.header"),
  makeflowTemplate= readLines( "data/nldas.makeflow.sprintf"))
{
  makeflowLines <- lapply( 
    makeflowTemplate,
    sprintf,
    format( dateVector, "%Y/%j"),
    format( dateVector, "%Y%m%d"))
  makeflowStanza <- lapply(
    1:length( dateVector),
    function( ix) lapply(
      makeflowLines, 
      function( x) x[[ ix]]))
  c( makeflowHeader, unlist( makeflowStanza))
}

writeHourlyMakeflow <- function(
  dateVector,
  makeflowFilename= format(
    dateVector[ length( dateVector)],
    "scripts/nldas%Y%j.makeflow"),
  append= FALSE)
{
  cat(
    createHourlyMakeflow( dateVector),
    file= makeflowFilename,
    sep= "\n",
    append= append)
  makeflowFilename
}

failedDates <- sort( as.Date(
  c( "2007/004", "1990/020", "1982/046"),
  format= "%Y/%j"))

writeHourlyMakeflow( failedDates, "scripts/failedHourly.makeflow")
