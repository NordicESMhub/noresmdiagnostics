---
layout: episode
title: "Basics on NorESM model output"
teaching: 20
#exercises: 25
questions:
  - "Where does the model data files stored?"
  - "What is the format of the data?"
  - "What are the irregularities of the data?"
#objectives:
  #- "This is one objective of this episode."
keypoints:
  - "NorESM has diffent output directories during compiling, running and long-term archive"
  - "Output from different components and with different frequncies are usually stored in seperate files"
  - "NorESM has irregular horizontal and vertical grids, which may need to be remapped to standard grids, e.g., when comparing with observations"
  - "BLOM file naming represents the middle of average period, while CAM represents end of average period."

---

>## Directories storing model output
1. Run directory: `/cluster/work/users/<username>/noresm/cases/$CASE` (on Fram/Betzy)
2. Short-term archive: `/cluster/work/users/<username>/archive/cases/$CASE` (on Fram/Betzy).\
   NOTE, files older than 21 days might be automatic deleted (see [Fram/Betzy documentation](https://documentation.sigma2.no/files_storage/clusters.html#user-work-area))
3. Medium/Long-term archive: should archive the data to the [NIRD](https://documentation.sigma2.no/files_storage/nird.html) project areas, e.g., `/projects/NS2345K` for INES project.
{: .callout}

<img src="{{ site.baseurl }}/images/archive.png" width="800px" alt="Archive structure of model output">
<!--
![archive]({{ site.baseurl }}/images/archive.png)
-->

---

>## History File Naming Conventions
* All history output files are written in NetCDF-3 format, and automatically converted to compressed NetCDF-4 format (with tool `noresm2netcdf4`)
* Output of each component store seperately as `<component>/hist`, e.g, `atm/hist` `ocn/hist`, etc. Restart files are stored under `rest/hist`.
{: .callout}

```bash
$ tree -L 2
.
├── archive.log.200921-151923
├── atm
│   └── hist
├── cpl
│   └── hist
├── esp
│   └── hist
├── ice
│   └── hist
├── lnd
│   └── hist
├── logs
│   ├── atm.log.781577.200921-144102.gz
│   ├── cesm.log.781577.200921-144102.gz
│   ├── cpl.log.781577.200921-144102.gz
│   ├── ice.log.781577.200921-144102.gz
│   ├── lnd.log.781577.200921-144102.gz
│   ├── ocn.log.781577.200921-144102.gz
│   └── rof.log.781577.200921-144102.gz
├── ocn
│   └── hist
├── rest
│   └── 0001-02-01-00000
└── rof
    └── hist
```
#### Example history file names:
- `<compset name>_<resolution sname>_<opt_desc_string>_<component>.<frequency>_<date>.nc`
- N1850frc2_f19_tn14_Workshop2021.blom.hm.0001-01.nc
- N1850frc2_f19_tn14_Workshop2021.cam.h0.0001-01.nc

By default, `h0,hm` denotes that the time sampling frequency is monthly.
Other frequencies are saved under the h1, h2, etc.

Different time sampling frequencies have distinct tags in the file names.
#### A full list of the tags:
```txt
    - blom.hy    = blom yearly
    - blom.hbgcy = blom/bgc yearly
    - blom.hm    = blom monthly
    - blom.hbgcm = blom/bgc monthly
    - blom.hd    = blom daily
    - blom.hbgcd = blom/bgc daily
    - cice.h     = ice monthly
    - cice.h1    = ice daily
    - cam.h0     = cam monthly 
    - cam.h1     = cam daily
    - cam.h2     = cam 6-hourly average
    - cam.h3     = cam 6-hourly instant
    - cam.h4     = cam 3-hourly average
    - cam.h5     = cam 3-hourly instant
    - clm2.h4    = clm yearly
    - clm2.h0    = clm monthly
    - clm2.h1    = clm daily
    - clm2.h2    = clm 3-hourly average
    - clm2.h3    = clm 3-hourly instant
```

> ## NorESM horizontal and vertical grid system
>
### Horizontal grids
* NorESM1 (MICOM) for CMIP5: bipolar grid
* NorESM2 (BLOM)  for CMIP6: tripolar grid
>
### Vertical grids
>* CAM: terrian-following sigma coordinate
>* BLOM: isopycnic (potential density $\sigma_2$) coordinated vertical coordinate
>* NorESM2 (BLOM)  for CMIP6: tripolar grid
{: .callout}

<img src="{{ site.baseurl }}/images/grid.png" width="800px" alt="NorESM horizontal and vertical grid system">

> ## Challenges
* Regrid ocean tripolar grid to 1x1 degree grid
* Interpolate CAM terrian-following sigma coordinate to pressure levels
* interpolate BLOM isopycninc vertical coordinate to depth (z) levels
{: .challenge}

> ## NorESM output time axis/variable
**BLOM** \
The time coordinate variable in ocean model BLOM history represents the middle of the averaging period for variables that are averages. No`time_bounds` for the `time` axis.
>
**CAM** \
The time coordinate variable in atmospheric model CAM history and timeseries files represents the end of the averaging period for variables that are averages (inherited from CESM). Its `time_bnds` attribute of `time` axis gives over which period the field is averaged.
>
**Example File:** `N1850frc2_f19_tn14_Workshop2020.cam.h0.0001-01.nc`\
When the time coordinate variable is translated, the time is 00Z Februray 1st 0001, even though the file holds averaged variables for January 0001.
{: .callout}

#### BLOM output
```bash
$ ncdump -t -v time N1850frc2_f19_tn14_Workshop2020.blom.hm.0001-01.nc |tail -4
data:

 time = "0001-01-17" ;
}
```

#### CAM output
```bash
$ ncdump -t -v time N1850frc2_f19_tn14_Workshop2020.cam.h0.0001-01.nc |tail -5
		:time_period_freq = "month_1" ;
data:

 time = "0001-02-01" ;
}

$ ncdump -t -v time_bnds N1850frc2_f19_tn14_Workshop2020.cam.h0.0001-01.nc |tail -5
data:

 time_bnds =
  "0001-01-01", "0001-02-01" ;
}
```
> ## Challenge
* Check the time-axis conventions in other components of NorESM (using your favorate tool)
* Check the time-axis of instantaneous output files, e.g, files with tags `cam.h3`,`cam.h5`, and `clm2.h3` in the name.
{: .challenge}
