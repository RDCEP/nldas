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
