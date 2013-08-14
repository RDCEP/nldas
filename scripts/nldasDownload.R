library( doMC, quietly= TRUE)
library( XML, quietly= TRUE)
library( stringr, quietly= TRUE)

## registerDoMC( cores= 4)
registerDoMC( cores= multicore:::detectCores())

baseUrl <- "ftp://hydro1.sci.gsfc.nasa.gov/data/s4pa/NLDAS/NLDAS_FORA0125_H.002"

maxWgetAttempts <- 10

nldasDates <-
  seq(
    from= ISOdate( 1979,1,1,13),
    to= as.POSIXlt( Sys.Date() - 4),
    by= "day")

nldasDataUrls <-
  paste(
    baseUrl,
    ## format( nldasDates, "%Y/%j/NLDAS_FORA0125_H.A%Y%m%d.%H00.002.grb"),
    format( nldasDates, "%Y/%j"),
    "*.grb*",
    sep= "/")

## composeDataUrl <- function(
##   date,
##   baseUrl= paste(
##     "ftp://hydro1.sci.gsfc.nasa.gov",
##     "data/s4pa/NLDAS/NLDAS_FORA0125_H.002",
##     sep= "/"))
## {
##   paste(
##     baseUrl,
##     format( date, "%Y/%j"),
##     sep= "/")
## }


  
nldasWgetCommands <-
  paste(
    "wget",
    "--recursive",
    "--progress=dot:mega",
    ## "--no-verbose",
    "--no-remove-listing",
    "--retry-connrefused",
    "--continue",
    "--timestamping",
    "--no-host-directories",
    "--cut-dirs=3",
    nldasDataUrls,
    "2>&1")

## composeWgetCommand <- function( url) {
##   paste(
##     "wget",
##     "--recursive",
##     "--progress=dot:mega",
##     ## "--no-verbose",
##     "--no-remove-listing",
##     "--retry-connrefused",
##     "--continue",
##     "--timestamping",
##     "--no-host-directories",
##     "--cut-dirs=3",
##     url,
##     "2>&1")
## }


isValidChecksum <- function( grbXmlFn) {
  grbFn <- gsub( ".xml$", "", grbXmlFn)
  if( any( !file.exists( grbXmlFn, grbFn))) {
    return( NA) }
  nldasMeta <-
    xmlParseDoc( grbXmlFn)
  checksumExpected <-
    as.numeric(
      xpathSApply(
        nldasMeta,
        "//CheckSumValue",
        xmlValue))
  checksumComputed <-
    as.numeric(
      str_split_fixed(
        system(
          paste( "cksum", grbFn),
          intern= TRUE),
        pattern= " ",
        n= 3)[, 1])
  if( checksumComputed == checksumExpected) {
    return( TRUE)
  } else {
    cat( grbFn, ": checksum mismatch . . . deleting.\n")
    file.remove( grbXmlFn, grbFn)
    return( FALSE)
  }
}

oldWd <- setwd( "data")

tableAsDataFrame <- function(x) as.data.frame( table(x))

write.table(  
  as.data.frame(
    foreach(
      date= nldasDates,
      url= nldasDataUrls,
      wgetCommand= nldasWgetCommands,
      .combine= tableAsDataFrame) %dopar% {
        wgetFailures <- NULL
        for( attempt in 1:maxWgetAttempts) {
          cat(
            system( wgetCommand, intern= TRUE), "\n",
            sep= "\n")
          dataPath <- paste(
            str_split( url, "/")[[1]][-(1:6)],
            collapse= "/")
          wgetResults <- list.files(
            path= dataPath,
            pattern= "xml$",
            full.names= TRUE)
          areValidChecksums <-
            sapply( wgetResults, isValidChecksum)
          if( length( areValidChecksums) ==
             sum( areValidCheckSums)) {
            break
          } else {
            wgetFailures <- append(
              wgetFailures,
              names( areValidChecksums)[ -which( areValidChecksums)])
          }
        }
        write.csv( tableAsDataFrame( wgetFailures),
                  row.names= FALSE,
                  col.names= FALSE)
        wgetFailures
      }),
row.names= FALSE,
col.names= FALSE,
quote= FALSE)

## cat( log, sep= "\n", file= "log", append= TRUE)

## cat(
##   log,
##   warnings(),
##   sep= "\n")

setwd( oldWd)
