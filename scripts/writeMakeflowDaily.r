#!/home/nbest/local/bin/r

## --interactive

## year    <- as.integer( argv[ 1])
## year <- 1979


years <- 1979:2013

## vars <- c(
##   "hmax", "hmin",
##   "pmax", "pmin",
##   "precip", "pres", "solar", "spfh",
##   "tmax", "tmin")

## vars <- c( "tmpEqTmax", "tmpEqTmin")

vars <- c(
  "presTmax", "presTmin",
  "spfhTmax", "spfhTmin")

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
      "/project/joshuaelliott/nldas/data/NLDAS_FORA0125_H.002/%Y/%j/NLDAS_FORA0125_H.A%Y%m%d",
      var,
      "nc",
      sep= "."))
  ruleTargetFormat <-
    "/project/joshuaelliott/nldas/data/annual/%1$d/%2$s_%1$d.nc"
  ruleTarget <- sprintf(
    ruleTargetFormat, year, var)
  ruleSource <- paste(
    inputFileNames, collapse= " ")
  ruleCommand <- sprintf(
    "(find /project/joshuaelliott/nldas/data/NLDAS_FORA0125_H.002/%1$d -name \"*.%2$s.nc\" | sort; echo  /project/joshuaelliott/nldas/data/annual/%1$d/%2$s_%1$d.nc) | xargs cdo -O -f nc mergetime", year, var) 
    ## paste(
    ## "cdo -f nc mergetime",
    ## ruleSource,
    ## ruleTarget,
    ## collapse= " ")
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


file.remove( "scripts/daily.makeflow")
l_ply(
  unlist( annualRules, recursive= FALSE),
  cat,
  file= "scripts/daily.makeflow",
  append= TRUE)

cat(
  "\n",
  file= "scripts/dailyAgg.makeflow",
  append= TRUE)

l_ply(
  unlist( annualRules, recursive= FALSE),
  cat,
  file= "scripts/dailyAgg.makeflow",
  append= TRUE)
