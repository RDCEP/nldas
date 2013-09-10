#!/home/nbest/local/bin/r

## --interactive

grbFn <- argv[ 1]
xmlFn <- argv[ 2]


library( XML, quietly= TRUE)
library( stringr)


## xmlFn <-
##  "data/NLDAS_FORA0125_H.002/1979/001/NLDAS_FORA0125_H.A19790101.1300.002.grb.xml"
## grbFn <- gsub( ".xml$", "", xmlFn)

isValidChecksum <- function(
  grbFn,
  xmlFn= paste( grbFn, sep=".", "xml")
  {
    nldasMeta <-
      xmlParseDoc( xmlFn)
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
    checksumComputed != checksumExpected
  }
  
if( !isValidChecksum( grbFn)) {
  cat( grbFn, ": checksum mismatch\n")
  file.remove( xmlFn, grbFn)
  quit( save= "no", status= 10, runLast= FALSE)
}
