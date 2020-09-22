---
layout: episode
title: "The NorESM Diagnostic Tool Package"
teaching: 20
#exercises: 90
questions:
  - "Make a suit of model diagnostics with a command"
#objectives:
  #- "This is one objective of this episode."
#keypoints:
  #- "This is an important key point."
  #- "Another important key point."
  #- "One more key point."

---
>## NorESM Diagnostic Package:
... is a NorESM model evaluation tool written with a set of scripts (bash, NCL etc) to provide a general evaluation and quick preview of the model performance with only one command line.
{: .callout}

>## The tool package consists of:
* CAM_DIAG: (NCAR's AMWG Diagnostics Package)
* CLM_DIAG: (CESM Land Model Diagnostics Package)
* CICE_DIAG: snow/sea ice volume/area
* HAMOCC_DIAG: time series, climaotology, zonal mean, regional mean
* BLOM_DIAG: time series, climatologies, zonal mean, fluxes, etc
{: .checklist}

---
**It has a one-line command interface, and is simple-to-use.**
```bash
# run this wraper script without parameters shows basic usage
$ diag_run
-------------------------------------------------
Program:
/projects/NS2345K/noresm_diagnostics_dev/bin/diag_run
Version: 6.0
-------------------------------------------------
Short description:
A wrapper script for NorESM diagnostic packages.

Basic usage:
# model-obs diagnostics
diag_run -m [model] -c [test case name] -s [test case start yr] -e [test case end yr]
# model1-model2 diagnostics
diag_run -m [model] -c [test case name] -s [test case start yr] -e [test case end yr] -c2 [cntl case name] -s2 [cntl case start yr] -e2 [cntl case end yr]
...
```
## Two types of analysis
**#1. Compare model with observations**
```bash
$ diag_run --model=cam,cice,micom \ 
--case1=CASENAME1 \ 
--start_year1=51 \ 
--end_year1=100 \ 
--input-dir1=/PATH/TO/MODEL/FOLDER \ 
--output-dir=/PATH/TO/PUT/OUTPUT/DATA \ 
--web-dir=/PATH/TO/PUT/CREATED/WEBPAGES \
```
**#2. Compare model with another model simulation**
```bash
$ diag_run --model=cam,cice,micom \ 
--case1=CASENAME1 \
--start_year1=51 \
--end_year1=100 \
--input-dir1=/PATH/TO/MODEL/FOLDER1 \
--case2=CASENAME2 \
--start_year2=2 \
--end_year2=50 \
--input-dir2=/PATH/TO/MODEL/FOLDER2 \
--output-dir=/PATH/TO/PUT/OUTPUT/DATA \
--web-dir=/PATH/TO/PUT/CREATED/WEBPAGES \
```

>Browse plots online at:
[http://ns2345k.web.sigma2.no/diagnostics/noresmdiagnostics](http://ns2345k.web.sigma2.no/diagnostics/noresmdiagnostics)
 <img src="https://hotemoji.com/images/emoji/x/6mnhuxe873ax.png" width="35px">
{: .checklist}
<img src="{{ site.baseurl }}/images/diagplot.png" width="800px" >

>## Challenge
If you don't have access to the NS2345K project, you have to specify another directory to write your webpage output by `-w` option. \
You can then make a tarball (`tar -cvzf casenme.tar.gz /path/to/the/weboutput`) \
And download to your local computer to view with your browser.
{: .challenge}

>## Code structure
{: .callout}
<img src="{{ site.baseurl }}/images/code.png" alt="code structure" width="800px" >
<img src="{{ site.baseurl }}/images/languages.png" alt="code languages" width="200px" >

>## Resources
{: .callout}

### Where is it?
* Github: https://github.com/NordicESMhub/noresmdiagnostics
* NIRD: /tos-project1/NS2345K/diagnostics/noresmdiagnostics
* FRAM: /tos-project1/NS2345K/diagnostics/noresmdiagnostics (NOT recommned to run it on FRAM!)

Do **NOT** directly modify /tos-project1/NS2345K/diagnostics/noresmdiagnostics!

### Install your own copy?
Yes you can, if you:
* don't have access to NIRD/FRAM at all.
* or have account on NIRD/FRAM, but don't have access to project NS2345K.  \
then
```
git clone https://github.com/NordicESMhub/noresmdiagnostics
```
* or you want to make changes of the code at your will and/or want to contribute to the code. \
then \
You can first `fork` to your private repository and `clone` to install. \
and then make soft links by the tool `bin/linkdata.sh` to `/tos-project1/NS2345K/www/diagnostics/noresmdiagnostics/inputdata`,\
or download the observational data by `bin/dldata.sh` from [http://noresm.org/diagnostics](http://noresm.org/diagnostics).

>Find the full doocumentation:
[https://noresm-docs.readthedocs.io/en/noresm2/diagnostics/diag_run.html](https://noresm-docs.readthedocs.io/en/noresm2/diagnostics/diag_run.html)
{: .callout}

---

