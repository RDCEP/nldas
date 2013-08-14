#!/home/nbest/local/bin/r

## --interactive

xmlFn <- argv[ 1]

grbFn <- gsub( ".xml$", "", xmlFn)

library( XML, quietly= TRUE)

## xmlFn <-
##  "data/NLDAS_FORA0125_H.002/1979/001/NLDAS_FORA0125_H.A19790101.1300.002.grb.xml"

nldasMeta <-
  xmlParseDoc( xmlFn)

checksumExpected <-
  as.numeric(
    xpathSApply(
      nldasMeta,
      "//CheckSumValue",
      xmlValue))

library( stringr)

checksumComputed <-
  as.numeric(
    str_split_fixed(
      system(
        ## paste( "cksum data/NLDAS_FORA0125_H.002/1979/001",
        ##   "NLDAS_FORA0125_H.A19790101.1300.002.grb",
        ##   sep= "/"),
        paste( "cksum", grbFn),
        intern= TRUE),
      pattern= " ",
      n= 3)[, 1])

if( checksumComputed != checksumExpected) {
  cat( grbFn, ": checksum mismatch . . . deleting.")
  ## file.remove( xmlFn, grbFn)
}
