#' Function to identify nearby stations by coordinates 
#' 
#' @param year year for the surface and upper air data 
#' @param long longitude for the location of interest (negative for W)
#' @param lat latitude for the location of interest 
#' @param return_num number of cloest stations to return
#' @examples
#' xy_to_id (year = 2008, long = -122.3321, lat = 47.6062)
#' 
#' 


#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)
if (! length(args) %in% c(3,4)) {
  stop("Three arguments must be supplied (year, longitude and latitude)", call.=FALSE)
} 

xy_to_id <- function(year, long, lat,return_num = 3 ) {
  
  # check whether required package is installed 
  if("geosphere" %in% rownames(installed.packages()) == FALSE) {
    stop("Package 'geosphere' is not installed ", call.=FALSE)
  }
  
  library(geosphere)
  
  isd_ref <- read.csv('https://raw.githubusercontent.com/kaufman-lab/AERMET/main/station_list/isd_ref.csv')
  upper_air_ref<- read.csv('https://raw.githubusercontent.com/kaufman-lab/AERMET/main/station_list/upper_air_ref.csv')
  
  
  year_start <- as.numeric(paste0(year,'0101'))
  year_end <- as.numeric(paste0(year,'1231'))
  
  sub_isd <- isd_ref[isd_ref$BEGIN < year_start & isd_ref$END > year_end,]
  sub_upper <- upper_air_ref[upper_air_ref$start_date < year_start & upper_air_ref$end_date > year_end,]
  
  ## error messages when no data present in the year
  if (dim(sub_isd)[1]==0 & dim(sub_upper)[1]==0){
    stop("No surface data and no upper air data for the year provided ", call.=FALSE)
  }
  
  if (dim(sub_isd)[1]==0 ){
    stop("No surface data for the year provided", call.=FALSE)
  }
  
  if (dim(sub_upper)[1]==0 ){
    stop("No upper air data for the year provided", call.=FALSE)
  }
  
  sub_isd$dist_to_xy <- distHaversine(cbind(sub_isd$LON,sub_isd$LAT),cbind(long,lat))
  sub_isd <- sub_isd[order(sub_isd$dist_to_xy),]
  
  sub_upper$dist_to_xy <- distHaversine(cbind(-sub_upper$longitude,sub_upper$latitude),cbind(long,lat))
  sub_upper <- sub_upper[order(sub_upper$dist_to_xy),]
  sub_upper$longitude <- -sub_upper$longitude
  
  
  close_stat <- list(sub_isd[1:return_num,],sub_upper[1:return_num,])
  names(close_stat) <- c('isd_station','upper_air_station')
  
  return(close_stat)

}

# xy_to_id (year = 2008, long = -122.3321, lat = 47.6062)
# Rscript --vanilla xy_to_id.R 2008 -122.3321 47.6062

if (length(args)==4){
  r_num <- args[4]
}else {r_num <- 3}

xy_to_id (year = args[1], long = as.numeric(args[2]), lat = as.numeric(args[3]), return_num = r_num)
