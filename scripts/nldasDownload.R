#!/usr/bin/R --vanilla

library( XML)
library( stringr)

baseUrl <- "ftp://hydro1.sci.gsfc.nasa.gov/data/s4pa/NLDAS/NLDAS_FORA0125_H.002"

nldasDates <-
  seq(
    from= ISOdate(
      year=  fromYear,
      month= fromMonth,
      day=   fromDay,
      hour=  fromHour),
    to= as.POSIXlt( Sys.Date() - 4),
    by= "hour")

nldasDataUrls <-
  paste(
    baseUrl,
    format( nldasDates, "%Y/%j/NLDAS_FORA0125_H.A%Y%m%d.%H00.002.grb*"),
    ## format( nldasDates, "%Y/%j"),
    ## "*.grb*",
    sep= "/")

cat( nldasDataUrls, sep= "\n")
