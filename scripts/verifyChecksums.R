## library( doMC, quietly= TRUE)
library( doMPI, quietly= TRUE)
library( XML, quietly= TRUE)
library( stringr, quietly= TRUE)

# create and register a doMPI cluster if necessary
if (!identical(getDoParName(), 'doMPI')) {
  cl <- startMPIcluster()
  registerDoMPI(cl)
}

## registerDoMC()

source( "scripts/isValidCheckSum.R")

xmlFiles <-
  list.files(
    "data/NLDAS_FORA0125_H.002",
    patt= "grb\\.xml$",
    full.names= TRUE,
    recursive= TRUE)

## failures <-
##   foreach(
##     xmlFile= xmlFiles,
##     .combine= c) %dopar% {
##         if( isValidChecksum( xmlFile)) NULL else xmlFile
##       }

## cat( failures, sep= "\n")

valid <- 
  foreach(
    xmlFile= xmlFiles,
    .combine= c) %dopar% {
      if( isValidChecksum( xmlFile)) NULL else xmlFile
    ## cat( paste( xmlFile, isValidChecksum( xmlFile)), sep= "\n")
  }

cat( valid, sep= "\n")
