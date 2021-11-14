#' Function to download upper air data and surface data
#' 
#' @param year year for the surface data 
#' @param isd_wban WBAN identifier for surface data 
#' @param upper_air_wban WBAN identifier for upper air data 
#' @param folder_name name for the folder that stores data
#' @examples
#' get_air_dat (year = 2009, isd_wban = 54829, upper_air_wba= 53823)
#' 
get_air_dat <- function(year, isd_wban, upper_air_wban, folder_name = 'air_dat') {

### load libraries (install them if in singularity environment)

library(tidyverse)
library(rstudioapi)

### get the directory of the scripts and set it as working directory
getCurrentFileLocation <-  function()
{
  this_file <- commandArgs() %>% 
    tibble::enframe(name = NULL) %>%
    tidyr::separate(col=value, into=c("key", "value"), sep="=", fill='right') %>%
    dplyr::filter(key == "--file") %>%
    dplyr::pull(value)
  if (length(this_file)==0)
  {
    this_file <- rstudioapi::getSourceEditorContext()$path
  }
  return(dirname(this_file))
}

script.dir <- getCurrentFileLocation()


### prepare reference table for data 
setwd(script.dir)
system(paste0('mkdir -p ',folder_name,sep=''))

setwd(paste0(script.dir,'/',folder_name,sep=''))


isd_ref <- read_csv('https://raw.githubusercontent.com/kaufman-lab/AERMET/main/station_list/isd_ref.csv')
upper_air_ref<- read_csv('https://raw.githubusercontent.com/kaufman-lab/AERMET/main/station_list/upper_air_ref.csv')

### get upper air data from github release 

system (paste0('wget --no-check-certificate ', 
               'https://github.com/kaufman-lab/AERMET/releases/download/v1.0.0/raob_soundings_',
               upper_air_wban,'_1991_2020.txt',sep=''))



### get surface data from github release 

isd_usaf <- isd_ref[isd_ref$WBAN==isd_wban,]$USAF[1]

system (paste0('wget --no-check-certificate ', 
               'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/',year,'/',isd_usaf,'-',isd_wban,'-',year,'.gz',
               sep=''))

}
