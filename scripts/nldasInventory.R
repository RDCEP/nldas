nldasFiles <- list.files(
  path= "data/NLDAS_FORA0125_H.002",
  patt= "grb$",
  recursive= TRUE)

library( stringr)
nldasFileMatches <- str_match(
  string= nldasFiles,
  pattern= paste(
    "^([0-9]{4})/([0-9]{3})",
    "NLDAS_FORA0125_H.A[0-9]{8}.([0-9]{2})00.002.grb",
    sep= "/"))

nldasTimes <- as.data.frame( nldasFileMatches[, -1])
names( nldasTimes) <- c( "year", "day", "hour")

nldasTimes <- within(
  nldasTimes,
  time <- as.POSIXct(
    strptime(
      x= paste( year, day, hour),
      format= "%Y %j %H",
      tz= "GMT")))

nldasTimesExpected <- seq(
  from= ISOdate( 1979, 1, 1, 13),
  to= Sys.time(),
  by= "hour")

nldasTimesMissing <-
  nldasTimesExpected[ !( nldasTimesExpected %in% nldasTimes$time)]
