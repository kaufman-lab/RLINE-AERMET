#' Function to download upper air data and surface data
#' 
#' @param year year for the surface data 
#' @param isd_wban WBAN identifier for surface data 
#' @param upper_air_wban WBAN identifier for upper air data 
#' @param folder_name name for the folder that stores data
#' @examples
#' get_air_dat (year = 2009, isd_wban = 54829, upper_air_wban = 53823)
#' 
#' 

#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
if (length(args)!=3) {
  stop("Three arguments must be supplied (year, WBAN identifier for 
       surface data and WBAN identifier for upper air data ", call.=FALSE)
} 

get_air_dat <- function(year, isd_wban, upper_air_wban, folder_name = 'air_dat') {


  
### get the directory of the scripts and set it as working directory


### prepare reference table for data 
system(paste0('mkdir -p ',folder_name,sep=''))
script.dir <- getwd()
setwd(paste0(script.dir,'/',folder_name,sep=''))

isd_ref <- read.csv('https://raw.githubusercontent.com/kaufman-lab/AERMET/main/station_list/isd_ref.csv')
upper_air_ref<- read.csv('https://raw.githubusercontent.com/kaufman-lab/AERMET/main/station_list/upper_air_ref.csv')

### get upper air data from github release 

system (paste0('wget --no-check-certificate ', 
               'https://github.com/kaufman-lab/AERMET/releases/latest/download/raob_soundings_',
               upper_air_wban,'_1991_2020.txt',sep=''))

# rename upper air data
system (paste0('mv ','raob_soundings_',
               upper_air_wban,'_1991_2020.txt',' UP_AIR',
               sep=''))

### get surface data from github release 

isd_usaf <- isd_ref[isd_ref$WBAN==isd_wban,]$USAF[1]

system (paste0('wget --no-check-certificate ', 
               'ftp://ftp.ncdc.noaa.gov/pub/data/noaa/',year,'/',isd_usaf,'-',isd_wban,'-',year,'.gz',
               sep=''))


# unzip and rename the surface data

system (paste0('gunzip ',isd_usaf,'-',isd_wban,'-',year,'.gz',
               sep=''))

system (paste0('mv ',isd_usaf,'-',isd_wban,'-',year,' SURF_DAT',
               sep=''))

}


# get_air_dat (year = 2009, isd_wban = 54829, upper_air_wban = 53823) 
# Rscript --vanilla get_surf_up_v2.R 2009 54829 53823
get_air_dat (year = args[1], isd_wban = args[2], upper_air_wban= args[3])
