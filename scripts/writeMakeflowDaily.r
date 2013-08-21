#!/home/nbest/local/bin/r

## --interactive

## year    <- as.integer( argv[ 1])
## year <- 1979


years <- 1979:2013

vars <- c(
  "hmax", "hmin",
  "pmax", "pmin",
  "precip", "pres", "solar", "spfh",
  "tmax", "tmin")

library( plyr)

## library( foreach)
library( doMC)
registerDoMC( 8)

annualRule <- function( year, var) {
  dates <- seq(
    from= as.Date( sprintf(
      "%d-01-01", year)),
    to=   as.Date( sprintf(
      if( year == 2013) "%d-07-04" else "%d-12-31", year)),
    by= "day")
  inputFileNames <- format(
    dates,
    paste(
      "data/NLDAS_FORA0125_H.002/%Y/%j/NLDAS_FORA0125_H.A%Y%m%d",
      var,
      "nc",
      sep= "."))
  ruleTargetFormat <-
    "data/annual/%1$d/%2$s_%1$d.nc"
  ruleTarget <- sprintf(
    ruleTargetFormat, year, var)
  ruleSource <- paste(
    inputFileNames, collapse= " ")
  ruleCommand <- paste(
    "cdo -f nc mergetime",
    ruleSource,
    ruleTarget,
    collapse= " ")
  paste(
    ruleTarget,
    ": ",
    ruleSource,
    "\n\t",
    ruleCommand,
    "\n\n",
    sep= "")
}

annualRules <- 
  foreach( year= years) %:%
  foreach( var= vars) %dopar% {
    annualRule( year, var)
  }


l_ply(
  unlist( annualRules, recursive= FALSE),
  cat,
  file= "scripts/daily.makeflow",
  append= TRUE)
