---
layout: episode
title: "Exercise part 1"
#teaching: 20
exercises: 90
questions:
  - "The NorESM Diagnostic Tool"
keypoints:
  - "`diag_run` has two modes: compare to observation and compare to another model simulation."
  - "Some parameters can be omitted if they are default values"
  - "Use `-p` to enter passive mode, and customize the diagnostic output"

---

## Task 1

### Task 1.0 Archive data to NIRD
Transfer your data from Fram/Betzy to NIRD

```bash
# copy files from Fram/Betzy to NIRD
rsync -aP --chown=OWNER:GROUP <path/to/noresm/output> <username>@login.nird.sigma2.no:<path/to/project/storage>
#.e.g.,
rsync -aP --chown=yanchun:NS2345K /cluster/work/users/$USER/archive/NHISTfrc2_workshop2021/ yanchun@login.nird.sigma2.no:/projects/NS2345K/workshop2021/NHISTfrc2_workshop2021/
```
See more information on archiving NorESM output at the [NorESM documentation](https://noresm-docs.readthedocs.io/en/latest/output/archive_output.html)


### Task1.1 Set up

#### Option 1: use pre-installed tool
Use pre-installed tool under NS2345K project of NIRD (Recommended)

```bash
# Fist, Logon NIRD
ssh -l <your_username> login.nird.sigma2.no

# Next, add alias for diag_run
cat <<EOF >> ~/.bashrc
if [ -f /projects/NS2345K/diagnostics/noresm/bin/diag_run ];then
    alias diag_run='/projects/NS2345K/diagnostics/noresm/bin/diag_run'
fi
EOF

# source to take effect
source ~/.bashrc
```

#### Option 2: install your own copy
If you have no access to NS2345K on NIRD. You can install your own copy.
```bash
cd ~/
git clone https://github.com/NordicESMhub/noresmdiagnostics
cd noresmdiagnostics/bin
./linkdata.sh
```
It will link the data under either:
```
/projects/NS2345K/www/diagnostics/inputdata/
```
to your installed copy.

---
Note, if you need to download the code to your home folder, you should donwload the observational data by `bin/dloaddata.sh` to a direcory that has large quota, e.g., to `/cluster/work/users/$USER`, not directly under your home directory. Then link the downloaded data with `bin/linkdata.sh`

Next, get familiar with the `diag_run` optins
```bash
# run this wraper script without parameters
$ diag_run
```
Will shows basic usage:

```bash
-------------------------------------------------
Program:
/projects/NS2345K/diagnostics/noresm/bin/diag_run
Version: 2.1
-------------------------------------------------
Short description:
A wrapper script for NorESM diagnostic packages.

Basic usage:
diag_run -m [model] -c [test case name] -s [test case start yr] -e [test case end yr] # Run model-obs diagnostics
diag_run -m [model] -c [test case name] -s [test case start yr] -e [test case end yr] -c2 [cntl case name] -s2 [cntl case start yr] -e2 [cntl case end yr] # Run model1-model2 diagnostics
nohup /projects/NS2345K/diagnostics/noresm/bin/diag_run -m [model] -c [test case name] -s [test case start yr] -e [test case end yr] &> out & # Run model-obs diagnostics in the background with nohup
...
...
```

---

### Task 1.2 Model-obs comparison of a fully coupled simulation

**Demo**
```bash
## Compare model to observation
# syntax:
$ diag_run  -m MODEL -c CASENAEME -s START_YEAR -e  END_YEAR -i INPUT -o OUTPUT -w WEBPAGE​
# examples:
# 1, compare NorESM2-LM historical run (years 1985 - 2014) with observations 
$ diag_run -m blom -c NHIST_f19_tn14_20190710 -s 1985 -e 2014 -i /projects/NS9560K/noresm/cases -o /projects/NS2345K/diagnostics/noresm/out/$USER -w /projects/NS2345K/www/diagnostics/noresm/$USER
# 2, compare NorESM2-LM piControl run (years 1735 - 1764, equivalent to 1985 - 2014), only diagnose the ocean component, and omit the -o and -w options (default to the above settings).
$ diag_run -m blom -c N1850_f19_tn14_20190621 -s 1735 -e 1764 -i /projects/NS9560K/noresm/cases
```
>## Challenge
* Use your own finished experiment, and chose the component you want to diagnose
* You should specify the `-i`, `-o` and `-w` option if they are not default paths.
Such as, on NIRD:
```text
-i /projects/NS2345K/workshop2021
-o /projects/NS2345K/diagnostics/noresm/out/$USER
-w /projects/NS2345K/www/diagnostics/noresm/$USER
# or
-w /projects/NSxxxxK/www
```
Make sure these two directories exist.
An example:
```bash
$ diag_run -m blom -c N1850frc2_workshop2021 -s 1 -e 10 -i /projects/NS2345K/workshop2021
```
{: .challenge}


For those dont' have succefully model run, ideally longer than 2-years.

You can find sample cases, under:
`/projects/NS2345K/workshop2021`

* N1850frc2_workshop2021 (model years, 1-10)
* NHISTfrc2_workshop2021 (model years, 1850-1859)

For those have access to NS2345K and NS9560K on NIRD, there are plent of CMIP6 experiments:
* /projects/NS2345K/noresm/cases
* /projects/NS9560K/noresm/cases

Find out where is the casename and the location of each experiment:
[https://noresmhub.github.io/noresm-exp/intro.html](https://noresmhub.github.io/noresm-exp/intro.html)

---

### Task1.3 Model-model comparison
#### Compare model to model

```bash
# Syntax:
$ diag_run  -m cam -c1 CASENAEME1 -s1 START_YEAR1 -e1  END_YEAR1 -c2 CASENAME2 -s2 START_YEAR2 -e2 –END_YEAR2 -i1 INPUT1 -i2 INPUT2 -o OUTPUT –w WEBPAGE
# example, compare NorESM2-LM historical run, years, 1985 to 2014 to piControl (years, 1735 - 1764)
$ diag_run  -m cam -c1 NHIST_f19_tn14_20190710 –s1 1985 -e1 2014 –i1 /projects/NS9560K/noresm/cases -c2 N1850_f19_tn14_20190621 -s2 1735 -e2 1764 -i2 /projects/NS9560K/noresm/cases
```

>## Challenge
* User your own experiment
For example:
```bash
$ diag_run -m blom -c1 NHISTfrc2_workshop2021 -s1 1850 -e1 1859 -i1 /projects/NS2345K/workshop2021 -c2 N1850frc2_workshop2021 -s2 1 -e2 10 -i2 /projects/NS2345K/workshop2021 -o /projects/NS2345K/diagnostics/noresm/out/$USER -w /projects/NS2345K/www/diagnostics/noresm/$USER
```
{: .challenge}

## Task 2
### Task 2.1
Diagnose only ocean component with passive mode `-p`

```bash
# Example
$ diag_run -m blom -c NHIST_f19_tn14_20190710 -s 1985 -e 2014 -p
```
In the standard output, you can find lines like:
```
...
BLOM DIAGNOSTICS SUCCESSFULLY CONFIGURED in /projects/NS2345K/diagnostics/noresm/out/$USER/BLOM_DIAG
...
```
Go the that directory and check the shell script there, which is job script for each component.

### Task 2.2

In the configuration file by Task2.2, e.g., by default `/projects/NS2345K/diagnostics/noresm/out/$USER/BLOM_DIAG/blom_diag_template.sh`

Switch on only some sets, e.g. set_1 and set_3, and switch off other sets \
change: 

```
set_1=1
set_3=1
others =0
```
and then submit the job script, i.e, `./blom_diag_template.sh`

### Task 2.3
Plot only part of the period of a simulation, instead of the whole period.\
Only plot part of the time series between xxx and xxx

Change for example:\
`/projects/NS2345K/diagnostics/noresm/out/$USER/BLOM_DIAG/blom_diag_template.sh`

```
TRENDS_ALL=0
FIRST_YR_TS1=1
LAST_YR_TS1=10
```
and then resubmit `blom_diag_template.sh`

### Task 2.4
Diagnose only atmospheric component with passive mode `-p`, and switch offf significance and switch off chemistry sets

```bash
# Example
$ diag_run -m cam -c NHIST_f19_tn14_20190710 -s 1985 -e 2014 -p
```
In the standard output, you can find lines like:
```
...
CAM DIAGNOSTICS SUCCESSFULLY CONFIGURED in /projects/NS2345K/diagnostics/noresm/out/$USER/CAM_DIAG
...
```
Go the that directory and check the shell script there, `amwg_template.csh`

Set in:
`/projects/NS2345K/diagnostics/noresm/out/$USER/CAM_DIAG/amwg_template.csh`
```text
set significance = 0        # (0=ON,1=OFF)
...
set all_waccm_sets = 1 # (0=ON,1=OFF)  Do all the WACCM sets
set all_chem_sets = 0  # (0=ON,1=OFF)   Do all the CHEM sets
```
then start the scripit `./amwg_template.csh`.


## Task 3

### Task 3.1
Find out where the climo_ts/, config/, logs/, diag/ locate, and understand these processed data
e.g., /projects/NS2345K/diagnostics/noresm/out/$USER/BLOM_DIAG

### Task 3.2
Q: How to edit the source code and apply your change?

A: The best way is to fork the NorESM Diagnostic Tool repository, and clone and install your own copy.
