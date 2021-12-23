## 1. Summary for AERMET

This document describes the procedure of running AERMET and details the data sources.


### 1. AERMET procedure

The following flow chart summarizes steps for AERMET. There are three major stages and each of the stages will be run separately. After gathering the required data, we will form a command line file for each of the stages. AERMET will produce report that indicates whether the process is successfully implemented. In the end, we will have the .met file serves as the input for RLINE.

![a pic](aermet_flow.jpg)

### 2. Input for AERMET

#### 2.1. Data source 

The first two data sources meet the minimal requirement for AERMET input. The rest data sources will be helpful to get better accuracy for the output.

1. **Surface meteorological data**: ISHD surface met data (Integrated Surface Hourly Database)
available at ftp://ftp.ncdc.noaa.gov/pub/data/noaa/

2. **Upper air data **: available from NOAA/ESRL Radiosonde Database at http://esrl.noaa.gov/raobs/ in FSL format. Specific downloading parameters need to be determined. 

3. **1-minute Automated Surface Observing Systems (ASOS) data (Wind)**: available at ftp://ftp.ncdc.noaa.gov/pub/data/asosonemin/.
Need to use AERMINUTE preprocess the data.

4. **4.	Monthly Surface Characteristics**: Surface characteristics (Bowen ratio, albedo, and surface roughness length) could be customized in AERMET. They need to be calculated beforehand using AERSURFACE. Further investigation is needed, about source data, etc.

#### 2.2. Pairing of surface ASOS station and upper air data:

The surface data are more commonly available throughout US, while there are only less than 100 stations that provide upper air data. AERMET is not a spatial model, i.e. it will provide static meteorological output that does not vary across space. Thus, decisions will be made about which surface station and upper air station to use when calculating meteorological output for a give location.

For now, we will pair them using geographical distance. We will partition a region of interest by their proximity to the stations described. Further details will be discussed as we generalize the procedure nationwide.


#### 2.3 Useful links

**Upper air data stations map**:
https://www.weather.gov/upperair/nws_upper

**Upper air data stations, location and identifiers**https://ruc.noaa.gov/raobs/stat2000.txt

**Surface met data station links**
https://www1.ncdc.noaa.gov/pub/data/noaa/isd-history.txt


