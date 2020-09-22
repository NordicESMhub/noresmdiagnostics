---
layout: episode
title: "Exercise part 1"
#teaching: 20
exercises: 90
questions:
  - "The NorESM Diagnostic Tool"
keypoints:
  - "This is an important key point."
  - "Another important key point."
  - "One more key point."

---

## Task 1
### Task1.1 Set up the environment and get familiar

```bash
# Logon FRAM
ssh -l username fram.sigma2.no
cat <<EOF >> ~/.bashrc
# add alias for diag_run
if [ -f /tos-project1/NS2345K/diagnostics/noresmdiagnostics/bin/diag_run ];then
    alias diag_run='/tos-project1/NS2345K/diagnostics/noresmdiagnostics/bin/diag_run'
fi
EOF
# source to take effect
source ~/.bashrc
```
If you have no access to NS2345K:
```bash
cd ~/
git clone https://github.com/NordicESMhub/noresmdiagnostics
cd noresmdiagnostics/bin
./linkdata.sh
```
It will link the data under either:
```
/tos-project1/NS2345K/www/diagnostics/noresmdiagnostics/inputdata
```
or
```
/cluster/work/users/$USER/noresmdiagnostics
```
to your installed copy.

Note, if you need to download the code to your home folder, you should donwload the observational data by `bin/dloaddata.sh` to a direcory that has large quota, e.g., to `/cluster/work/users/$USER`, not directly under your home directory. Then link the downloaded data with `bin/linkdata.sh`

Next, get known with the `diag_run` optins
```bash
# run this wraper script without parameters shows basic usage
$ diag_run
```

>## Challenge
For those alread have account on NIRD and have access to NS2345K:
Try to copy/sync data from FRAM to NIrD, and use the `diag_run` on NIRD
{: .challenge}

---

### Task 1.2 Model-obs comparison of a fully coupled simulation

**Demo**
```bash
# Compare model to observation
$ diag_run  -m all -c CASENAEME -s START_YEAR -e  END_YEAR -i INPUT -o OUTPUT –w WEBPAGE​
# diag_run -m all -c N1850OC_f19_tn14_noresm-dev -s 1 -e 2
# diag_run -m all -c NHIST_f19_tn14_20190710 -s 2010 -e 2014 -i /projects/NS2345K/workshop/cases &>~/diag_run.log1 &
$ diag_run -m cam -c N1850frc2_f19_tnx1v4_workshop -s 1 -e 5 -i /cluster/work/users/agu002/archive -o /tos-project1/NS2345K/diagnostics/noresmdiagnostics/out/$USER -w /tos-project1/NS2345K/www/diagnostics/noresmdiagnostics/$USER
```
>## Challenge
* Use your own finished experiment, and the component you are interested in.
* You should specify a different `-o` and `-w` option if you have no access to NS2345K.\
{: .challenge}

For example:
```
-o /cluster/work/users/\$USER/noresmdiagnostics
-w /cluster/work/users/\$USER/www
```
Make sure these two directories exist. Otherwise, use `mkdir` to create them:
```
mkdir -p /cluster/work/users/$USER/noresmdiagnostics /cluster/work/users/$USER/www
```

For those dont' have succefully model run, ideally longer than 2-years.

You can find the case by Alok, under:
`/cluster/work/users/agu002/archive/`

* N1850frc2_f19_tnx1v4_workshop (5-year long)
* NOINY_T62_tnx1v4_workshop
* NF2000climo_f19_f19_mg17_workshop
* NOINY_T62_tnx1v4_workshop3
* N1850frc2_f19_tnx1v4_workshop2
* NOINY_T62_tn14_Workshop2020
* NOINY_T62_tn14_Workshop2020_clone
* N1850frc2_f19_tn14_Workshop2020


For those have access to NS2345K and NS9560K on NIRD, there are plent of CMIP6 experiments:
* /projects/NS2345K/noresm/cases
* /projects/NS9560K/noresm/cases

Find out where is the casename and the location of each experiment:
[https://noresmhub.github.io/noresm-exp/intro.html](https://noresmhub.github.io/noresm-exp/intro.html)

---

### Task1.3 Model-model comparison
#### Compare model to model

```bash
$ diag_run  -m all -c1 CASENAEME1 -s1 START_YEAR1 -e1  END_YEAR1 -c2 CASENAME2 -s2 START_YEAR2 -e2 –END_YEAR2 -i1 INPUT1 -i2 INPUT2 -o OUTPUT –w WEBPAGE
$ diag_run  -m all -c1 NHIST_f19_tn14_20190710 –s1 2010 -e1 2014 –i1 /projects/NS2345K/workshop/cases -c2 N1850_f19_tn14_20190621 -s2 1750 -e2 1754 -i2 /projects/NS2345K/workshop/cases &>~/diag_run.log2 &
```

>## Challenge
* User your own experiment
{: .challenge}

## Task 2
### Task 2.1
Diagnose only ocean component with passive mode `-p`

```bash
# Example
$ diag_run -m blom -c N1850frc2_f19_tnx1v4_workshop -s 1 -e 5 \
                    -i /cluster/work/users/agu002/archive  -p
```
In the standard output, you can find lines like:
```
...
BLOM DIAGNOSTICS SUCCESSFULLY CONFIGURED in /tos-project1/NS2345K/diagnostics/noresmdiagnostics/out/$USER/BLOM_DIAG
...
```
Go the that directory and check the shell script there, which is job script for each component.

### Task 2.2

In the configuration file by Task2.2, e.g., by default `/tos-project1/NS2345K/diagnostics/noresmdiagnostics/out/$USER/BLOM_DIAG/blom_diag_template.sh`

Switch on only some sets, e.g. set_1 and set_3, and switch off other sets \
change: 

```
set_1=1
set_3=1
others =0
```
and then submit the job script, e.g., `blom_diag_template.sh`

### Task 2.3
Plot only part of the period of a simulation, instead of the whole period.\
Only plot part of the time series between xxx and xxx

Change for example:\
`/tos-project1/NS2345K/diagnostics/noresmdiagnostics/out/$USER/BLOM_DIAG/blom_diag_template.sh`

```
TRENDS_ALL=0
FIRST_YR_TS1=1
LAST_YR_TS1=4
```
and then resubmit `blom_diag_template.sh`

## Task 3

### Task 3.1
Find out where are the climo_ts, config, logs, diag locates, and understand these processed data
e.g., /tos-project1/NS2345K/diagnostics/noresmdiagnostics/out/$USER/BLOM_DIAG

### Task 3.2
How to edit the source code and apply your change?

