
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

dailyAggRuleTemplate <- paste(
  "",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.tmax.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,tmax -timmax -selname,TMP {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.tmax.nc\n",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.tmin.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,tmin -timmin -selname,TMP {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.tmin.nc\n",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.precip.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,precip -timsum -selname,APCP {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.precip.nc\n",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.solar.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,solar -timavg -selname,DSWRF {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.solar.nc\n",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.pres.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,pres -timavg -selname,PRES {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.pres.nc\n",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.spfh.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,spfh -timavg -selname,SPFH {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.spfh.nc\n",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.u.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,u -timavg -selname,UGRD {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.u.nc\n",
  "$projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.v.nc: {{> dailyMergeFile}}",
  "cdo setzaxis,surface -setname,v -timavg -selname,VGRD {{> dailyMergeFile}} $projectDir/{{dataDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.v.nc\n",
    sep= "\n")

renderDailyAggData <- function( nldasDate, template, partials, ...) {
  data <- list(
    dailyYj= format( nldasDate, "%Y/%j"),
    dailyYmd= format( nldasDate, "%Y%m%d"),
    ...)
  whisker.render(
    template,
    data= data,
    partials= partials)
}

psimsVars <- c( "tmax", "tmin", "precip", "solar", "pres", "spfh", "u", "v")

annualTargetTemplate <-
  "{{outputDir}}/{{var}}_nldas_{{year}}_0125.nc4"

annualSourceTemplate <-
  "{{inputDir}}/{{dailyYj}}/NLDAS_FORA0125_H.A{{dailyYmd}}.{{var}}.nc"

annualRecipeTemplate <- c(
  "\n{{> annualTarget}}: {{# days}}{{> annualSource}} {{/ days}}\n",
  "\n(find {{inputDir}}/{{year}} -name \"*.{{var}}.nc\" | sort; echo {{> annualTarget}}) | xargs cdo -O -f nc4 -z zip mergetime\n")

renderAnnualRecipe <- function(
  ## var,  year,
  df,
  template= annualRecipeTemplate,
  partials= list(
    annualTarget= annualTargetTemplate,
    annualSource= annualSourceTemplate),
  days= nldasDates[ format( nldasDates, "%Y") == df$year],
  ...)
{
  data <- with( df, list(
    var= var,
    year= year,
    days= unname(
      rowSplit(
        data.frame(
          var= var,
          dailyYj= format( days, "%Y/%j"),
          dailyYmd= format( days, "%Y%m%d")))),
    inputDir= "$projectDir/data/NLDAS_FORA0125_H.002",
    outputDir= "$projectDir/data/annual"))
  whisker.render(
    template,
    data,
    partials)
}

psimsVars <- c( "tmax", "tmin", "precip", "solar", "pres", "spfh", "u", "v")

allTimeTargetTemplate <-
  "{{outputDir}}/{{var}}_nldas_1979-2013_0125.nc4"

allTimeSourceTemplate <-
  "{{annualDir}}/{{var}}_nldas_{{year}}_0125.nc4"

allTimeRecipeTemplate <- c(
  "\n{{> allTimeTarget}}: {{# years}}{{> allTimeSource}} {{/ years}}\n",
  "\n(find {{annualDir}} -name \"{{var}}_nldas_????_0125.nc4\" | sort; echo {{> allTimeTarget}}) | xargs cdo -O -f nc4 -z zip mergetime\n")

renderAllTimeRecipe <- function(
  var,
  template= allTimeRecipeTemplate,
  partials= list(
    allTimeTarget= allTimeTargetTemplate,
    allTimeSource= allTimeSourceTemplate),
  years= 1979:2013,
  ...)
{
  data <- list(
    var= var,
    years= iteratelist( years, value= "year"),
    annualDir= "$projectDir/data/annual",
    outputDir= "$projectDir/data/full",
    ...)
  whisker.render(
    template,
    data,
    partials)
}

remapRecipeData <- unname(
  rowSplit(
    data.frame(
      var= psimsVars,
      inputDir= "$projectDir/data/annual",
      outputDir= "$projectDir/data/full")))

## remapRecipeTemplate <- "
## {{# remapRecipeData}}
## {{> remapTarget}}: {{> allTimeTarget}}
##
## cdo remapnn,data/nldas_5min.grid {{> allTimeTarget}} {{> remapTarget}}
##
## {{/ remapRecipeData}}"

remapRecipeTemplate <- c(
"{{# remapRecipeData}}",
"{{> remapTarget}}: {{> allTimeTarget}}",
"",
"\ncdo remapnn,$projectDir/data/nldas_5min.grid {{> allTimeTarget}} {{> remapTarget}}",
"",
"{{/ remapRecipeData}}")
##remapRecipeTemplate <- paste( remapRecipeTemplate, sep= "\n")
remapRecipeTemplate <- paste( remapRecipeTemplate, collapse= "\n")
                            
  
remapRecipes <-
  whisker.render(
    remapRecipeTemplate,
    partials= list(
      allTimeTarget= allTimeTargetTemplate,
      remapTarget= remapTargetTemplate))

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
