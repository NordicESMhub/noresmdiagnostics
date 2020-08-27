---
layout: episode
title: "The NorESM Diagnostic Package"
teaching: 20
exercises: 25
questions:
  - "A question that this episode will answer?"
  - "Another question?"
objectives:
  - "This is one objective of this episode."
  - "This is another objective of this episode."
  - "Yet another objective."
  - "And not to forget this objective."
keypoints:
  - "This is an important key point."
  - "Another important key point."
  - "One more key point."
---

## Task 1

### Task1.1 Set up the environment
- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

```bash
# login nird
$ ssh -Y -l username login.nird.sigma2.no
# append in your .bashrc alias
$ echo "# add alias for diag_run" >> ~/.bashrc
$ echo "alias diag_run='/projects/NS2345K/noresm_diagnostics_dev/bin/diag_run'" >> ~/.bashrc
$ source ~/.bashrc

# Logon FRAM
ssh -l username fram.sigma2.no
cd /cluster/work/users/$USER/archive
rsync -vazu /cluster/work/users/$USER/archive/ login.nird.sigma2.no:/projects/NS2345K/noresm/cases/

# Log on FRAM:
mkdir -p tos-project1/NS2345K/noresm/cases/$USER
cp -r /cluster/work/users/$USER/archive/YOUR_CASE_NAME /tos-project1/NS2345K/noresm/cases/$USER/
```
---

### Task 1.2 Model-obs comparison of a fully coupled simulation
- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

```bash
# Compare model to observation
$ diag_run  -m all -c CASENAEME -s START_YEAR -e  END_YEAR -i INPUT -o OUTPUT –w WEBPAGE​
$ diag_run -m all -c N1850OC_f19_tn14_noresm-dev -s 1 -e 2
$ diag_run -m all -c NHIST_f19_tn14_20190710 -s 2010 -e 2014 -i /projects/NS2345K/workshop/cases &>~/diag_run.log1 &
```

---

### Task1.3 Model-model comparison
# Compare model to model

```bash
$ diag_run  -m all -c1 CASENAEME1 -s1 START_YEAR1 -e1  END_YEAR1 -c2 CASENAME2 -s2 START_YEAR2 -e2 –END_YEAR2 -i1 INPUT1 -i2 INPUT2 -o OUTPUT –w WEBPAGE
$ diag_run  -m all -c1 NHIST_f19_tn14_20190710 –s1 2010 -e1 2014 –i1 /projects/NS2345K/workshop/cases -c2 N1850_f19_tn14_20190621 -s2 1750 -e2 1754 -i2 /projects/NS2345K/workshop/cases &>~/diag_run.log2 &
```

## Another section

- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
- Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

```python
def foo():
    print('foo!')
```
