## 1. Overview

This project details the pipeline for implementing AERMET and RLINE in Linux environment. We use AERMET to prepare meteorological '.sfc' file, which serves as an input for RLINE. 

The repo provides RLINE and AERMET source code (written in fortran) and their corresponding compilation scripts. In addition, the instructions for obtaining required data and helper functions are included. We use data analysis examples to illustrate the pipeline. 

## 2. Singularity Container

We guarantee reproduciblility of the entire process by encapsulating it in a singularity environment container. Thus, the version of AERMET and RLINE we adopt in the pipeline might not be the most recent ones. This document relies on AERMET version v21112, which published in April 2021, and its the most recent version as the document is created (December 2021). One could download the same executable from EPA website (https://gaftp.epa.gov/Air/aqmg/SCRAM/models/met/aermet/aermet_source.zip), before a newer version releases. The RLINE version considered is v1.2 and it is available from https://www.cmascenter.org/r-line/.  

The singularity image can be found in package of this Github repo. We already complied RLINE and AERMET such that upon entering the image, user will be ready to implement either or both programs given the required data input.




## 3. Implementation of AERMET from image


We acknowledge that part of the following scripts are adapted from the instruction found at https://linux.vbird.org/enve/aermet-op.php. We will prepare meteorological data for Los Angeles as an example. 


### 3.1 Prepare Executables 

The executables for AERMET and RLINE are already compiled within the singularity image. Since the folders and files within the image cannot be modified, we need to copy compiled executable to file system in the local host.

First create a local directory on the host, then download the most recent version of the image from Github repo (suffix might need to be changed to match the most recent one) and enter the singularity image. 

```
[yunhanwu@deohs-brain ~]$ mkdir aermet_testrun
[yunhanwu@deohs-brain ~]$ cd aermet_testrun

[yunhanwu@deohs-brain aermet_testrun]$ singularity shell oras://ghcr.io/kaufman-lab/aermet_rline_func:dev
```

To access the files from the image, we need to use '/' before specifying the directory. For example, the following command could be used to check files within the singularity image.  The executables for AERMET and RLINE are stored in their corresponding folders. 

```
Singularity> ls /

Singularity> ls /aermet_demo

Singularity> ls /RLINE

```


Now we copy the directory named 'build' under 'aermet_demo', which contains the source code and executables.

```
Singularity> cp /aermet_demo/build -r build

```

Lastly, we link the executable 'aermet.exe'.

```
Singularity> ln -s build/aermet.exe 

```


### 3.2 Obtaining Source Data

AERMET requires at least two data input. The first is surface meteorological data from ground stations, which is available from Integrated Surface Database (ISD) website (ftp://ftp.ncdc.noaa.gov/pub/data/noaa/). The second is upper air data, which is available from NOAA/ESRL Radiosonde Database (https://ruc.noaa.gov/raobs/). 

Our Github repo facilitates the data downloading process through the following venues:

1. **Upper Air Data**: The release called "Upper Air Data" hosts data downloaded from NOAA/ESRL Radiosonde Database. Data from 1991-2010 are available and they are identified by the unique WBAN identifier for the stations.

2. **Master List for Stations**: In the folder 'station_list', there are two separate lists detailing the information about ground stations and upper air stations. Relevant information includes coordinates (longitude, latitude and altitude), WBAN identifier, start and end dates.

3. **Helper Functions**: We provide two helper functions for downloading the surface and upper air data. The xy_to_id.R function generates a list of stations ordered by the distance to the coordinates provided. The get_surf_up.R function downloads data for specified WABN identifier and year.

Now we turn to the LA example. First we call xy_to_id.R to examine the candidate lists for stations. The arguments of the function are year (for the surface and upper air data), longitude and latitudes for the location of interest (negative for W). The default of the function is to return three closest stations for ground and upper air stations respectively, and the user could get a longer list by specifying the length in the end as an additional argument.  

```
Singularity> Rscript --vanilla /xy_to_id.R 2010 -118.2437 34.0522

```

The output looks like the following. Now the function only support station search for a single year, if the user is interested in multiple years, we suggest the user to run the function for each year and find the station with most available data. The preferable choice is usually the first row. However, as we proceed to the first stage of AERMET, we might find the quality of the data not acceptable. In that case, we might switch stations by going down through the list.

The output is prepared based on the master lists hosted under the folder 'station_list'. Information about the station including WABN identifier, longitude, latitude and altitude will also be needed for AERMET procedures.


```

$isd_station
       USAF  WBAN                      STATION.NAME CTRY STATE ICAO    LAT
1955 722874 93134          DOWNTOWN L.A./USC CAMPUS   US    CA KCQT 34.024
2016 722956  3167        NRTHORP FLD/HATHRN MUNI AP   US    CA KHHR 33.923
2009 722950 23174 LOS ANGELES INTERNATIONAL AIRPORT   US    CA KLAX 33.938
          LON ELEV.M.    BEGIN      END dist_to_xy
1955 -118.291    54.6 20000101 20211019   5375.195
2016 -118.334    19.2 20060101 20211019  16623.024
2009 -118.389    29.6 19440101 20211019  18478.267

$upper_air_station
    init  wban   wmo latitude longitude elev start_date end_date
614  NTD 93111 72391    34.10   -119.12    2   19770107 99999999
47   EDW  3197 72381    34.90   -117.92  724   19930104 99999999
621  NSI 93116 72291    33.25   -119.45   14   19959999 99999999
                   station_name state dist_to_xy
614               POINT MUGU CA    CA   80974.26
47     EDWARDS AFB UPPER AIR CA    CA   98940.95
621 SAN NICOLAS ISLAND SITE1 CA    CA  143070.73

```

In this case, we pick the closest ones. We use the WABN identifiers as arguments for the function get_surf_up.R. The order is year, WBAN for ground station and WABN for upper air station.

```
Singularity> cp /get_surf_up.R get_surf_up.R

Singularity> Rscript --vanilla get_surf_up.R 2010 93134 93111

```


AERMET requires all file names to be capitalized, so we rename them.


```
Singularity> cp air_dat/SURF_DAT SURF_DAT

Singularity> cp air_dat/UP_AIR UP_AIR

```

### 3.3 Run AERMET in Linux

#### 3.3.1 Stage 1


We first get the sample control files for our LA example. 

```
Singularity> wget --no-check-certificate https://github.com/kaufman-lab/AERMET/blob/main/AERMET_example/S1.INP?raw\=true

Singularity> mv S1.INP?raw\=true S1.INP

```


There is not much parameters to set in stage 1.
 
1. **XDATES**: The period of time for AERMET to process 
2. **LOCATION**: Longitude, latitude and altitude for the station, also requires WBAN identifier. The second last item is the factor to
convert the time of each data record to local standard time. Since LA is in GMT-8, we use 8 as the time difference.
3. **AUDIT**: Adds variables to the list of default variables to be tracked during QA. Here we use a default list.



```

JOB

    REPORT    LA_TEST_S1.RPT
    MESSAGES  LA_TEST_S1.MSG


SURFACE

    DATA      SURF_DAT  ISHD
    EXTRACT   LA_TEST_SURF.IQA
    QAOUT     LA_TEST_SURF.OQA

    XDATES    10/1/1  TO  10/12/31

    LOCATION  93134  34.024N  118.291W  8  54.6


UPPERAIR

    DATA      UP_AIR  FSL
    EXTRACT   LA_TEST_UPAIR.IQA
    QAOUT     LA_TEST_UPAIR.OQA

    XDATES    10/1/1  TO  10/12/31

    LOCATION  93111  34.10N  119.12W  0  2
    AUDIT     UATT  UAWS  UALR


```


Now we execute stage 1 and the data quality information could be found under the .RPT file.

```

Singularity> ./aermet.exe S1.INP
Singularity> view LA_TEST_S1.RPT

```

####  3.3.2 Stage 2


Similarly, we download the control file for stage 2.

```
Singularity> wget --no-check-certificate https://github.com/kaufman-lab/AERMET/blob/main/AERMET_example/S2.INP?raw\=true

Singularity> mv S2.INP?raw\=true S2.INP

```


```

JOB
    REPORT     LA_TEST_S2.RPT
    MESSAGES   LA_TEST_S2.MSG

UPPERAIR
    QAOUT      LA_TEST_UPAIR.OQA

SURFACE
    QAOUT      LA_TEST_SURF.OQA

MERGE
    OUTPUT     LA_TEST_MR.MET

    XDATES     10/01/01 10/12/31

```

```

Singularity> ./aermet.exe S2.INP
Singularity> view LA_TEST_S2.RPT

```


#### 3.3.3 Stage 3

Stage 3 is the actual processing stage and it requires some parameters and builds upon the output from stage 2. Here we primarily used the default settings. The choice of surface parameters is defined under \'SITE_CHAR\'. Here we used the albedo, midday Bowen ratio and surface roughness length from example 1 in the AERMET documentation. We note that this is inaccurate and further investigation is needed to better determine these parameters, perhaps using AERSURFACE. In addition the usage of \'SECTOR'\ is not explored in this implementation.

```
Singularity> wget --no-check-certificate https://github.com/kaufman-lab/AERMET/blob/main/AERMET_example/S3.INP?raw\=true

Singularity> mv S3.INP?raw\=true S3.INP

```


```
JOB
    REPORT    LA_TEST_S3.RPT
    MESSAGES  LA_TEST_S3.MSG

METPREP
    DATA      LA_TEST_MR.MET

    OUTPUT    LA_TEST_MP.SFC
    PROFILE   LA_TEST_MP.PFL

    METHOD    REFLEVEL  SUBNWS
    METHOD    WIND_DIR  RANDOM
    NWS_HGT   WIND      7.9
    FREQ_SECT ANNUAL 1
    SECTOR    1    0     360
    SITE_CHAR 1 1  0.15  2.0  0.12


```


```

Singularity> ./aermet.exe S3.INP
Singularity> view LA_TEST_S3.RPT

```


## 4. Implementation of RLINE in Linux

```
Singularity> mkdir rline_testrun
Singularity> cd rline_testrun

```

```
Singularity> cp /RLINE/RLINE_source/ -r RLINE_source
Singularity> cp ../../aermet_testrun/LA_TEST_MP.SFC Met_Example.sfc
```



get example prediction locations and source data


