---
layout: episode
title: "The NorESM Diagnostic Tool Package"
teaching: 20
#exercises: 90
#questions:
  #- "Make a suit of model diagnostics with a command"
objectives:
  - "Get an overview of diagnostic package."
#keypoints:
  #- "This is an important key point."
  #- "Another important key point."
  #- "One more key point."

---
>## NorESM Diagnostic Package:
... is a NorESM model evaluation tool written with a set of scripts and utilities (bash, NCL, NCO, CDO etc) to provide a general evaluation and quick preview of the model performance with only one command line.
{: .callout}

>## Components of the package:
The diagnostic tool package consists atmospheric/land components based on the NCAR package.
* CAM_DIAG: (NCAR's AMWG Diagnostics Package)
* CLM_DIAG: (CESM Land Model Diagnostics Package)
* CICE_DIAG: snow/sea ice volume/area
* HAMOCC_DIAG: time series, climaotology, zonal mean, regional mean
* BLOM_DIAG: time series, climatologies, zonal mean, fluxes, etc
{: .checklist}

---

It has a one-line command interface, and is simple-to-use.

```bash
# run this wraper script without parameters shows basic usage
$ diag_run
-------------------------------------------------
Program:
/projects/NS2345K/diagnostics/noresm/bin/diag_run
Version: 2.1
-------------------------------------------------
Short description:
A wrapper script for NorESM diagnostic packages.

Basic usage:
# model-obs diagnostics
$ diag_run -m [model] -c [test case name] -s [test case start yr] -e [test case end yr]
# model1-model2 diagnostics
$ diag_run -m [model] -c [test case name] -s [test case start yr] -e [test case end yr] -c2 [cntl case name] -s2 [cntl case start yr] -e2 [cntl case end yr]
...
```

## Two types of analysis

### 1. Compare model with observations
* sample plots: [Historical simulation of ocean compared to observations](http://ns2345k.web.sigma2.no/diagnostics/noresm/common/NHIST_f19_tn14_20190710/MICOM_DIAG/yrs1985to2014-obs.html)

| 2m Air temperature | Sea surface temperature |
|:---:|:---:|
|<img src="{{ site.baseurl }}/images/t2m_model2obsland2.png" width="500px" > | <img src="{{ site.baseurl }}/images/sst_model2obs2.png" width="500px" > |

```bash
$ diag_run --model=cam,cice,blom \ 
--case=CASENAME \ 
--start_year=51 \ 
--end_year=100 \ 
--input-dir=/PATH/TO/MODEL/FOLDER \ 
--output-dir=/PATH/TO/OUTPUT/DATA \ 
--web-dir=/PATH/TO/GENERATED/WEBPAGES \

# or its short version
$ diag_run -m cam,cice,blom -c CASENAME -s 51 -e 100 -i /PATH/TO/MODEL/FOLDER -o /PATH/TO/OUTPUT/DATA -w /PATH/TO/GENERATED/WEBPAGES
```

### 2. Compare model with control (another simulation)

* sample plots: [Historical simulation of atmosphere compared to PI control](http://ns2345k.web.sigma2.no/diagnostics/noresm/common/NHIST_f19_tn14_20190710/CAM_DIAG/yrs1985to2014-N1850_f19_tn14_20190621-yrs1735to1764.html)

| 2m Air temperature | Sea surface temperature |
|:---:|:---:|
|<img src="{{ site.baseurl }}/images/t2m_model2model2.png" width="500px" > | <img src="{{ site.baseurl }}/images/sst_model2model2.png" width="500px" > |


```bash
$ diag_run --model=cam,cice,blom \ 
--case1=CASENAME1 \
--start_year1=51 \
--end_year1=100 \
--input-dir1=/PATH/TO/MODEL/FOLDER1 \
--case2=CASENAME2 \
--start_year2=2 \
--end_year2=50 \
--input-dir2=/PATH/TO/MODEL/FOLDER2 \
--output-dir=/PATH/TO/OUTPUT/DATA \
--web-dir=/PATH/TO/GENERATED/WEBPAGES \

# or its short version
$ diag_run -m cam,cice,blom -c1 CASENAME1 -s1 51 -e1 100 -i1 /PATH/TO/MODEL/FOLDER1 \
                            -c2 CASENAME2 -s2 1  -e2 50  -i2 /PATH/TO/MODEL/FOLDER2 \
                            -o /PATH/TO/OUTPUT/DATA \
                            -w /PATH/TO/GENERATED/WEBPAGES
```

## Sets of diagnostics

|Atmospheric diagnostics ([example plots](http://ns2345k.web.sigma2.no/diagnostics/noresm/common/NHIST_f19_tn14_20190710/CAM_DIAG/yrs1985to2014-obs/sets.htm))|Ocean diagnostics([Example plots](http://ns2345k.web.sigma2.no/diagnostics/noresm/common/NHIST_f19_tn14_20190710/MICOM_DIAG/yrs1985to2014-obs.html))|Biogeochemistry diagnostics ([Example plots](http://ns2345k.web.sigma2.no/diagnostics/noresm/common/NHIST_f19_tn14_20190710/HAMOCC_DIAG/yrs1985to2014-obs.html))|
|:---:|:---:|:---:|
|<img src="{{ site.baseurl }}/images/diagatm.png" width="320px" >|<img src="{{ site.baseurl }}/images/diagocn.png" width="320px" >| <img src="{{ site.baseurl }}/images/diagbiog.png" width="320px" >| |
|Land diagnostics ([example plots](http://ns2345k.web.sigma2.no/diagnostics/noresm/common/NHIST_f19_tn14_20190625/CLM_DIAG/yrs1850to1949-obs.html))|Sea ice diagnostics ([Example plots](http://ns2345k.web.sigma2.no/diagnostics/noresm/common/NHIST_f19_tn14_20190710/CICE_DIAG/yrs1985to2014.html))| |
|<img src="{{ site.baseurl }}/images/diaglnd.png" width="320px" >|<img src="{{ site.baseurl }}/images/diagice.png" width="320px" >|

>Browse plots online at:
[http://ns2345k.web.sigma2.no/diagnostics/noresm](http://ns2345k.web.sigma2.no/diagnostics/noresm)
 <img src="https://hotemoji.com/images/emoji/x/6mnhuxe873ax.png" width="35px">
* shared diagnostics are stored under `commom/`
* personal diagnostics are store under `$username/`
{: .checklist}

>## Note
If you don't have access to the NS2345K project, you have to specify another directory to write your webpage output by `-w` option. \
You can then make a tarball (`tar -cvzf casenme.tar.gz /path/to/the/weboutput`) \
And download to your local computer to view with your browser.
{: .discussion}

>## Code structure
{: .callout}
<img src="{{ site.baseurl }}/images/code.png" alt="code structure" width="800px" >
<img src="{{ site.baseurl }}/images/languages.png" alt="code languages" width="200px" >

>## Resources
{: .callout}

### Where is it?
* Github: https://github.com/NordicESMhub/noresmdiagnostics
* NIRD: /projects/NS2345K/diagnostics/noresm
* Betzy: /trd-project1/NS2345K/diagnostics/noresm (NOT tested!)

Do **NOT** directly modify /trd-project1/NS2345K/diagnostics/noresm!

### Install your own copy?
Yes you can, when you:
* don't have access to NIRD at all.
* or have account on NIRD, but don't have access to project NS2345K.  \
then
```
# log on NIRD
git clone https://github.com/NordicESMhub/noresmdiagnostics
```
* or you want to make changes of the code at your will and/or want to contribute to the code. \
then \
You can first `fork` to your private repository and `clone` to install. \
and then make soft links by the tool `bin/linkdata.sh` to `/projects/NS2345K/www/diagnostics/inputdata`,\
or download the observational data by `bin/dldata.sh` from [http://noresm.org/diagnostics](http://noresm.org/diagnostics).

>Find the full doocumentation:
[https://noresm-docs.readthedocs.io/en/latest/diagnostics/diag_run.html](https://noresm-docs.readthedocs.io/en/latest/diagnostics/diag_run.html)
{: .callout}

---

