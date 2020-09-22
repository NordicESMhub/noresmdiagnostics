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

Get known with the `diag_run` optins
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
{: .challenge}

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
### Task 2.2
Switch  on only some sets, e.g. set_1 and set_3, and switch off other sets \
change: 
```
set_1=1
set_3=1
others =0
```
in the output directory specified by `-o` \
`$OUT_ROOT/out/$USER/BLOM_DIAG/blom_diag_template.sh`\
by default, `OUT_ROOT=/tos-project1/NS2345K/diagnostics/noresmdiagnostics`


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

## Task 3

### Task 3.1
Find out where are the climo_ts, config, logs, diag locates, and understand these processed data
e.g., /tos-project1/NS2345K/diagnostics/noresmdiagnostics/out/$USER/BLOM_DIAG

### Task 3.2
How to edit the source code and apply your change?

