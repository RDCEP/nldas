
library( whisker)
library( plyr)
library( doMC)
registerDoMC(4)

nldasHours <- seq(
  from= ISOdatetime(
    year=  fromYear,
    month= fromMonth,
    day=   fromDay,
    hour=  fromHour,
    min=      0,
    sec=      0,
    tz=   "GMT"),
  ## to= as.POSIXct( Sys.Date() - 4 -1/24),
  to= strptime( sprintf( "%s23", lastFullDay), format= "%Y%j%H", tz="GMT"),
  by= "hour")

nldasDates <- seq(
  from= as.Date( nldasHours[ 1]),
  ## to=   as.Date( nldasHours[ length( nldasHours)]),
  to= as.Date( lastFullDay, format= "%Y%j"),
  by= "day")

d_ply(
  .data= head( data.frame( POSIXct= nldasHours), n=35),
  ## .data= head(
  ##   nldasHours[ nldasHours > as.POSIXlt(
  ##     "1979-01-01 23:00:00",
  ##     tz= "GMT")],
  ##   24),
  .variables= .( as.Date( POSIXct)),
  .fun= dumpWhiskerOutput,
  renderFunction= renderDailyWhiskerData,
  template= dailyMergeRuleTemplate,
  partials= list(
    hourlyGrbFiles= hourlyGrbFileTemplate,
    dailyMergeFile= dailyMergeFileTemplate),
  dataDir= "data/NLDAS_FORA0125_H.002",
  file= "Makeflow.test")
cat(
  laply(
    .data= head( nldasDates, 2),
    .fun= renderDailyAggData,
    template= dailyAggRuleTemplate,
    partials= list(
      dailyMergeFile= dailyMergeFileTemplate),
    dataDir= "data/NLDAS_FORA0125_H.002"),
  file= "Makeflow.test",
  append= TRUE)
cat(
  unlist(
    dlply(
      .data= expand.grid(
        var= psimsVars,
        year= 1979),
      .variables= c( "var", "year"),
      .fun= renderAnnualRecipe,
      days= nldasDates[1:2])),
  file= "Makeflow.test",
  append= TRUE)
cat(
  laply(
    .data= psimsVars,
    .fun= renderAllTimeRecipe,
    years= 1979),
  file= "Makeflow.test",
  append= TRUE)
cat( "\n", remapRecipes, file= "Makeflow.test", append= TRUE)

d_ply( 
  .data= data.frame( POSIXct= nldasHours),
  .variables= .( as.Date( POSIXct)),
  .fun= dumpWhiskerOutput,
  .parallel= TRUE,
  renderFunction= renderDailyWhiskerData,
  template= dailyMergeRuleTemplate,
  partials= list(
    hourlyGrbFiles= hourlyGrbFileTemplate,
    dailyMergeFile= dailyMergeFileTemplate),
  dataDir= "data/NLDAS_FORA0125_H.002",
  file= "Makeflow")
cat(
  laply(
    .data= nldasDates,
    .fun= renderDailyAggData,
    template= dailyAggRuleTemplate,
    partials= list(
      dailyMergeFile= dailyMergeFileTemplate),
    dataDir= "data/NLDAS_FORA0125_H.002"),
  file= "Makeflow",
  append= TRUE)
cat(
  unlist(
    dlply(
      .data= expand.grid(
        var= psimsVars,
        year= 2013), ##1979:2013),
      .variables= c( "var", "year"),
      .fun= renderAnnualRecipe)),
  file= "Makeflow",
  append= TRUE)
cat(
  laply(
    .data= psimsVars,
    .fun= renderAllTimeRecipe),
  file= "Makeflow",
  append= TRUE)
cat( "\n", remapRecipes, file= "Makeflow", append= TRUE)
