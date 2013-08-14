## library( doMC, quietly= TRUE)
library( doMPI, quietly= TRUE)
library( XML, quietly= TRUE)
library( stringr, quietly= TRUE)

# create and register a doMPI cluster if necessary
if (!identical(getDoParName(), 'doMPI')) {
  cl <- startMPIcluster() # count= mpi.comm.size(0) - 1)
  registerDoMPI(cl)
}

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


source( "isValidCheckSum.R")

oldWd <- setwd( "data")

tableAsDataFrame <- function(x) as.data.frame( table(x))

result <-
  foreach(
    ## date= head( nldasDates,4),
    date= nldasDates,
    ## url= head( nldasDataUrls,4),
    url= nldasDataUrls,
    ## wgetCommand= head( nldasWgetCommands, 4),
    wgetCommand= nldasWgetCommands,
    .combine= rbind ) %dopar% {
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
           sum( areValidChecksums)) {
          break
        } else {
          wgetFailures <- append(
            wgetFailures,
            names( areValidChecksums)[ -which( areValidChecksums)])
        }
      }
      if( length( wgetFailures) > 0) {
        write.csv( tableAsDataFrame( wgetFailures),
                  file= format( date, "../log/wgetFailures/%Y%j.csv"),
                  row.names= FALSE,
                  col.names= FALSE)
      } else {
        system( format( date, "touch ../log/wgetFailures/%Y%j.csv"))
      }
      if( is.null( wgetFailures)) {
        data.frame( Var1=NULL, Freq= NULL)
      } else {
        tableAsDataFrame( wgetFailures)
      }
    }

write.csv(  
  result,
  row.names= FALSE,
  col.names= FALSE,
  quote= FALSE)

## cat( log, sep= "\n", file= "log", append= TRUE)

## cat(
##   log,
##   warnings(),
##   sep= "\n")

setwd( oldWd)

closeCluster( cl)
