# The NorESM diagnostics tool package
Table of contents
-----------------
1.  Basic usage
2.  Major changes to the NCAR versions

**The NorESM Diagnostic Package:**
>is a NorESM model evaluation tool written with a set of scripts (bash, NCL etc) to provide a general evaluation and quick preview of the model performance with only one command line. This toolpackage works on the original model output and has NorESM-specific diagnostics.

**The tool package consists of:**
* CAM_DIAG: (NCAR’s AMWG Diagnostics Package)
* CLM_DIAG: (CESM Land Model Diagnostics Package)
* CICE_DIAG: snow/sea ice volume/area
* HAMOCC_DIAG: time series, climaotology, zonal mean, regional mean
* BLOM_DIAG: time series, climatologies, zonal mean, fluxes, etc

## Basic usage

A user manual of diag_run is avalable on the NorESM documentation (https://noresm-docs.readthedocs.io/en/noresm2/diagnostics/diag_run.html), and also appears if you run ./bin/diag_run

## Major changes to the NCAR versions

The diagnostic tool package is developed on the basis of the [NCAR diagnostic package](http://www.cesm.ucar.edu/working_groups/Atmosphere/amwg-diagnostics-package/)

The following major changes have been made in all diagnostic packages:
- The calculation of the climatology has been improved, using the ncclimo oporator from nco.
- The bash/csh variables publish_html and publish_html_root have been added in order to enable publication of the html on the NIRD web server.
- There is now the option to calculate time series over the entire simulation (default). Hence, the start and end years of the time series must no longer be specified.
- The bash/csh variable CLIMO_TIME_SERIES_SWITCH has been added in order to allow for diag_run to compute only climatology or time series if desired.
- The environmental variable ncclimo_dir has been added in order to allow for diag_run to be run by cron.

### CAM_DIAG specific major changes

- The CAM diagnostics (amwg) now calculate the annual and global mean time series of the net TOA radiation balance. The results are published on the web server together with the other figures.

### CLM_DIAG specific major changes

- The amount of variables used in the time series calculations have been dramatically reduced in order to reduce time and computational resources
- If time series or climatology is computed is now determined by the selected sets in the computation.

### CICE_DIAG specific major changes

- The switch CNTL has been added in order to determine whether one or two cases should be plotted.

### BLOM_DIAG (new)

Has two modes: compare to the observations and anthor model run;
Includes diagnostics of:
- Time series plots
    * Sections transports
    * Global averages
    * Maximum AMOC
    * Hovmoeller plots
    * ENSO indices
- Climatology plots
    * Horizontal fields - annual means
    * Horizontal fields - seasonal/monthly means
    * Overturning circulation
    * Zonal means (lat-depth)
    * Equatorial cross sections
    * Meridional fluxes (vertically integrated)

### HAMOCC_DIAG (new)

Has two modes: compare to the observations and anthor model run;
Includes diagnostics of:
- Time series plots
    * Global fluxes
    * Global averages
- Climatology plots
    * Horizontal fields
    * Zonal mean fields
    * Regionally-averaged monthly climatologies

**Author:**
- Johan Liakka, NERSC (05/2018)
- Yanchun He, NERSC
_Last updated: Jun 2020_

**Contact information**
Please report issues in the Github issue page, or contact by email to Yanchun He (yanchun.he@nersc.no)
