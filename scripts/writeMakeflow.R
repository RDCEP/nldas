
## 1979/004  %1$s
## 19790104 %2$s

date <- seq(
  from= as.Date( "1980-01-01"),
  to=   as.Date( "2013-07-04"),
  by= "day")

snarfFile <- function( fn) {
  readChar( fn, file.info( fn)$size)
}

makeflowHeader <-   snarfFile( "data/nldas.makeflow.header")
## makeflowTemplate <- readLines( "data/nldas.makeflow.sprintf")
makeflowTemplate <- readLines( "data/nldas.makeflow.noCollect.sprintf")

## makeflowStanza <- sprintf(
##   makeflowTemplate,
##   format( date, "%Y/%j"),
##   format( date, "%Y%m%d"))

makeflowLines <- lapply( 
  makeflowTemplate,
  sprintf,
  format( date, "%Y/%j"),
  format( date, "%Y%m%d"))


makeflowStanza <- lapply(
  1:length( date),
  function( ix) lapply(
    makeflowLines, 
    function( x) x[[ ix]]))

cat(
  makeflowHeader,
  unlist( makeflowStanza),
  file= "scripts/nldas2013185.makeflow",
  sep= "\n")
