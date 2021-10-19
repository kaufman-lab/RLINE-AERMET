## 1. Implementation of AERMET in Linux

This document is adapted from the instruction found at https://linux.vbird.org/enve/aermet-op.php

### 1.1 Download and compile AERMET executable 

First load required module for Fortran compiler. In order for the AERMET program to compile properly, we need to operate the following procedures on the head node. 

```
[yunhanwu@deohs-brain ~]$ module load GCC/gcc-8.3.0 

```

Create folder structure,

```
[yunhanwu@deohs-brain ~]$ mkdir aermet
[yunhanwu@deohs-brain ~]$ cd aermet
[yunhanwu@deohs-brain ~]$ cd ~/aermet
[yunhanwu@deohs-brain aermet]$ mkdir build
[yunhanwu@deohs-brain aermet]$ cd build

```

We will store the source code of AERMET in the subfolder \'build\'. This document relies on AERMET version v21112, which published on April 2021, and its the most recent version as the document is created (September 2021).    For now, we obtain the source code from EPA website. However, the link is not permanent so we will later use singularity to securely store the source code and establish reproducibility. 

Download and unzip AERMET executable,

```
[yunhanwu@deohs-brain aermet]$ wget --no-check-certificate 
https://gaftp.epa.gov/Air/aqmg/SCRAM/models/met/aermet/aermet_source.zip

[yunhanwu@deohs-brain aermet]$ unzip aermet_source.zip
```

### 1.2 Compile AERMET 

Now we prepare the compile file

```
[yunhanwu@deohs-brain aermet]$ vim compile.sh

COMPILE_FLAGS=" -fbounds-check -Wuninitialized -Ofast -static -march=native -ffast-math 
-funroll-loops"
LINK_FLAGS=" -static -Ofast -march=native -ffast-math -funroll-loops"
sources="mod_AsosCommDates.for AERMET.FOR AERSURF.FOR AERSURF2.FOR ASOSREC.FOR AUDIT.FOR
        AUTCHK.FOR AVGCRD.FOR BANNER.FOR BULKRI.FOR CALMS.FOR CBLHT.FOR
        CHRCRD.FOR CHRCRD2.FOR CHROND.FOR CLHT.FOR CLMCRD.FOR CLOUDS.FOR
        COMPDT.FOR CUBIC.FOR CVG.FOR D028LV.FOR D144HD.FOR D144LV.FOR
        D3280H.FOR D3280L.FOR D6201H.FOR D6201L.FOR DATCRD.FOR DATER.FOR
        DEF256.FOR DEFINE.FOR DOCLDS.FOR DTCRD.FOR EQ_CCVR.FOR ERRHDL.FOR
        FDKEY.FOR FDPATH.FOR FETCH.FOR FLIWK1.FOR FLIWK2.FOR FLOPEN.FOR
        FLOS.FOR FLSDG.FOR FLSFC.FOR FLWRK1.FOR FLWRK2.FOR FMTCRD.FOR
        FNDCOMDT.FOR GEO.FOR GET620.FOR GETASOS.FOR GETCCVR.FOR GETFIL.FOR
        GETFLD.FOR GETFSL.FOR GETSFC.FOR GETTEMP.FOR GETWRD.FOR GMTLST.FOR
        GREG.FOR HDPROC.FOR HEADER.FOR HEAT.FOR HGTCRD.FOR HR0024.FOR
        HTCALC.FOR HTKEY.FOR HUMID.FOR HUSWX.FOR ICHRND.FOR INCRAD.FOR
        INTEQA.FOR INTHF.FOR ISHWX.FOR JBCARD.FOR LATLON.FOR LOCCRD.FOR
        LWRUPR.FOR MANDEL.FOR MDCARD.FOR MERGE.FOR MIDNITE.FOR MODEL.FOR
        MPCARD.FOR MPFIN.FOR MPHEAD.FOR MPMET.FOR MPOUT.FOR MPPBL.FOR
        MPPROC.FOR MPTEST.FOR MRCARD.FOR MRHDR.FOR MRPATH.FOR NETRAD.FOR
        NR_ANG.FOR NWSHGT.FOR OAUDIT.FOR OSCARD.FOR OSCHK.FOR OSDTCD.FOR
        OSDUMP.FOR OSFILL.FOR OSFILL2.FOR OSHRAV.FOR OSNEXT.FOR OSPATH.FOR
        OSPRNT.FOR OSQACK.FOR OSQAST.FOR OSRANGE.FOR OSREAD.FOR OSSMRY.FOR
        OSSUMS.FOR OSSWAP.FOR OSTEST.FOR OSTRA.FOR OSWRTE.FOR OTHHDR.FOR
        P2MSUB.FOR PRESET.FOR PTAREA.FOR PTGRAD.FOR RDHUSW.FOR RDISHD.FOR
        RDLREC.FOR RDSAMS.FOR READRL.FOR REALQA.FOR RHOCAL.FOR RNGCRD.FOR
        SAMWX.FOR SAUDIT.FOR SBLHT.FOR SCNGEN.FOR SECCRD.FOR SECCRD2.FOR
        SETHUS.FOR SETSAM.FOR SETUP.FOR SFCARD.FOR SFCCH.FOR SFCCH2.FOR
        SFCCRD.FOR SFCCRD2.FOR SFCHK.FOR SFCWXX.FOR SFEXST.FOR SFEXT.FOR
        SFPATH.FOR SFQASM.FOR SFQAST.FOR SFQATM.FOR SFTRA.FOR SMTHZI.FOR
        STONUM.FOR SUBST.FOR SUMHF.FOR SUMRY1.FOR SUMRY2.FOR SUNDAT.FOR
        TDPEST.FOR TEST.FOR THRESH1MIN.FOR UACARD.FOR UACHK.FOR UAEXST.FOR
        UAEXT.FOR UAMOVE.FOR UAPATH.FOR UAQASM.FOR UAQAST.FOR UATRA.FOR
        UAUDIT.FOR UAWNDW.FOR UCALCO.FOR UCALST.FOR VALCRD.FOR VARCRD.FOR
        VRCARD.FOR WRTCRD.FOR YR2TOYR4.FOR YR4TOYR2.FOR XDTCRD.FOR XTNDUA.FOR"

for file in ${sources}
do
        gfortran -m64 -c ${COMPILE_FLAGS} ${file}
done

gfortran -m64 -o aermet.exe ${LINK_FLAGS}  mod_AsosCommDates.o AERMET.o AERSURF.o  AERSURF2.o ASOSREC.o AUDIT.o  AUTCHK.o  AVGCRD.o  \
        BANNER.o  BULKRI.o  CALMS.o  CBLHT.o  CHRCRD.o  CHRCRD2.o  CHROND.o  CLHT.o  CLMCRD.o  CLOUDS.o  \
        COMPDT.o  CUBIC.o  CVG.o  D028LV.o  D144HD.o  D144LV.o  D3280H.o  D3280L.o  D6201H.o  D6201L.o   \
        DATCRD.o  DATER.o  DEF256.o  DEFINE.o  DOCLDS.o  DTCRD.o  EQ_CCVR.o  ERRHDL.o  FDKEY.o FDPATH.o  \
        FETCH.o  FLIWK1.o  FLIWK2.o  FLOPEN.o  FLOS.o  FLSDG.o  FLSFC.o  FLWRK1.o  FLWRK2.o  FNDCOMDT.o  \
        FMTCRD.o  GEO.o  GET620.o  GETASOS.o  GETCCVR.o  GETFIL.o  GETFLD.o  GETFSL.o  GETSFC.o  GETTEMP.o  GETWRD.o  GMTLST.o  GREG.o  HDPROC.o  HEADER.o  HEAT.o \
        HGTCRD.o  HR0024.o  HTCALC.o  HTKEY.o  HUMID.o  HUSWX.o  ICHRND.o  INCRAD.o  INTEQA.o  INTHF.o  ISHWX.o  JBCARD.o \
        LATLON.o  LOCCRD.o  LWRUPR.o  MANDEL.o  MDCARD.o  MERGE.o  MIDNITE.o  MODEL.o  MPCARD.o  MPFIN.o  MPHEAD.o  MPMET.o \
        MPOUT.o  MPPBL.o  MPPROC.o  MPTEST.o  MRCARD.o  MRHDR.o  MRPATH.o  NETRAD.o  NR_ANG.o  NWSHGT.o  OAUDIT.o  OSCARD.o \
        OSCHK.o  OSDTCD.o  OSDUMP.o  OSFILL.o  OSFILL2.o  OSHRAV.o  OSNEXT.o  OSPATH.o  OSPRNT.o  OSQACK.o  OSQAST.o  OSRANGE.o  OSREAD.o  OSSMRY.o \
        OSSUMS.o  OSSWAP.o OSTEST.o  OSTRA.o  OSWRTE.o  OTHHDR.o  P2MSUB.o  PRESET.o  PTAREA.o  PTGRAD.o  RDHUSW.o  RDISHD.o  RDLREC.o \
        RDSAMS.o  READRL.o  REALQA.o  RHOCAL.o  RNGCRD.o  SAMWX.o  SAUDIT.o  SBLHT.o  SCNGEN.o  SECCRD.o  SECCRD2.o  SETHUS.o \
        SETSAM.o  SETUP.o  SFCARD.o  SFCCH.o  SFCCH2.o  SFCCRD.o  SFCCRD2.o  SFCHK.o  SFCWXX.o  SFEXST.o  SFEXT.o  SFPATH.o  \
        SFQASM.o  SFQAST.o  SFQATM.o  SFTRA.o  SMTHZI.o  STONUM.o  SUBST.o  SUMHF.o  SUMRY1.o  SUMRY2.o  SUNDAT.o  TDPEST.o \
        TEST.o  THRESH1MIN.o UACARD.o  UACHK.o  UAEXST.o  UAEXT.o  UAMOVE.o  UAPATH.o  UAQASM.o  UAQAST.o  UATRA.o  UAUDIT.o  UAWNDW.o  \
        UCALCO.o  UCALST.o  VALCRD.o  VARCRD.o  VRCARD.o  WRTCRD.o  YR2TOYR4.o  YR4TOYR2.o  XDTCRD.o  XTNDUA.o

```



Execute compile.sh

```
[yunhanwu@deohs-brain ~]$ sh compile.sh
```


We might receive some warnings. It shouldn\'t affect implementation of AERMET and I don\'t know how to deal with them except ignoring. Note that the only requirement is GCC/gcc-8.3.0 for compiling fortran code in AERMET. 

```
GETFSL.FOR:95:72:

       pause
                                                                        1
Warning: Deleted feature: PAUSE statement at (1)
SCNGEN.FOR:59:0:

          IF( LOC2.NE.LOC1 .OR. IWORK1(N1).NE.IYR )THEN
 
Warning: ?MEM[(c_char * {ref-all})&loc2]? may be used uninitialized in this function
 [-Wmaybe-uninitialized]

```


Link aermet.exe. When we actually run AERMET, we will call this executable.

```
[yunhanwu@deohs-brain aermet]$ cd ~/aermet/
[yunhanwu@deohs-brain aermet]$ ln -s build/aermet.exe 

```

The above described procedure is planned to be wrapped as a singularity image.


### 1.3 Running AERMET 
#### 1.3.1 Overview

The minimal requirement for AERMET is hourly surface (ground) observation and upper air data. The details of the data source is described in the previous section about AERMET. The surface data are available through automated downloading while the upper air sounding is obtained by manually selection the station and period for downloading. Here we uses both data source from Oakland Airport in California as an example, since both ground observations and upper air data are available at the same location. Usually, a meteorological station doesn\'t host both kinds of data. We will explore about the procedure of paring upper air data and surface observations later.

As described earlier, AERMET implementation consists of three stages: the first stage check the data quality of both data sources; the second stage merge surface data and upper air data; and the third stage processes the data, and is the main part of AERMET.  Each stage requires a separate script that passes along stage specific parameters and calls the same executable.  
 
#### 1.3.2 Stage 1

In this stage we make sure the data are in place and check their quality.

Here is the scripts for downloading surface observations. \'23230\' is the WBAN code for this meteorological station. Modifications will be needed if we want to automate the process. For dealing with data in multiple years, we need to download the yearly data separately and concatenate them into one file. 

```
[yunhanwu@deohs-brain aermet]$ lftp ftp.ncdc.noaa.gov
[yunhanwu@deohs-brain aermet]$ cd /pub/data/noaa/2010
[yunhanwu@deohs-brain aermet]$ get 724930-23230-2010.gz
[yunhanwu@deohs-brain aermet]$ unzip 724930-23230-2010.gz
[yunhanwu@deohs-brain aermet]$ cp 724930-23230-2010 SURF_DAT
```

For now, we manually download the upper air data and put them into the correct folder, which is name \'UP_AIR\'

The command line for stage 1 is displayed as the following. Note that all file names need to be capitalized, otherwise the program is not able to locate the file. 

```
[yunhanwu@deohs-brain aermet]$ vim S1.INP

JOB

    REPORT    OAK_TEST_S1.RPT
    MESSAGES  OAK_TEST_S1.MSG


SURFACE

    DATA      SURF_DAT  ISHD
    EXTRACT   OAK_TEST_SURF.IQA
    QAOUT     OAK_TEST_SURF.OQA

    XDATES    10/1/1  TO  10/12/31

    LOCATION  23230  37.721N  122.221W  0  1.8


UPPERAIR

    DATA      UP_AIR  FSL
    EXTRACT   OAK_TEST_UPAIR.IQA
    QAOUT     OAK_TEST_UPAIR.OQA

    XDATES    10/1/1  TO  10/12/31

    LOCATION  23230  37.721N  122.221W  0  1.8
    AUDIT     UATT  UAWS  UALR

```

There is not much parameters to set in stage 1 command lines. 
1. **XDATES**: The period of time for AERMET to process 
2. **LOCATION**: Longitude, latitude and altitude for the station, also requires WBAN identifier
3. **AUDIT**: Adds variables to the list of default variables to be tracked during QA. Here we use a default list.


#### 1.3.2 Stage 2

Stage 2, the merging step, is simple when we only have the two data sources. In the future when we add  1-min ASOS data, this step will be more involved.

```
[yunhanwu@deohs-brain aermet]$ vim S2.INP

JOB
    REPORT     OAK_TEST_S2.RPT
    MESSAGES   OAK_TEST_S2.MSG

UPPERAIR
    QAOUT      OAK_TEST_UPAIR.OQA

SURFACE
    QAOUT      OAK_TEST_SURF.OQA

MERGE
    OUTPUT     OAK_TEST_MR.MET

    XDATES     10/01/01 10/12/31


```


#### 1.3.2 Stage 3

Stage 3 is the actual processing stage and it requires some parameters and builds upon the output from stage 2. Here we primarily used the default settings. The choice of surface parameters is defined under \'SITE_CHAR\'. Here we used the albedo, midday Bowen ratio and surface roughness length from example 1 in the AERMET documentation. We note that this is inaccurate and further investigation is needed to better determine these parameters, perhaps using AERSURFACE. In addition the usage of \'SECTOR'\ is not explored in this implementation.

```
[yunhanwu@deohs-brain aermet]$ vim S3.INP

JOB
    REPORT    OAK_TEST_S3.RPT
    MESSAGES  OAK_TEST_S3.MSG

METPREP
    DATA      OAK_TEST_MR.MET

    OUTPUT    OAK_TEST_MP.SFC
    PROFILE   OAK_TEST_MP.PFL

    METHOD    REFLEVEL  SUBNWS
    METHOD    WIND_DIR  RANDOM
    NWS_HGT   WIND      6.1
    FREQ_SECT ANNUAL 1
    SECTOR    1    0     360
    SITE_CHAR 1 1  0.15  2.0  0.12



```
