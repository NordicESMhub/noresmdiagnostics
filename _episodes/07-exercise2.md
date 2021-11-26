---
layout: episode
title: "Exercise part 2"
#teaching: 20
exercises: 90
questions:
  - "Preprocess of model output of irregular grids"
#keypoints:
  #- "This is an important key point."
  #- "Another important key point."
  #- "One more key point."

---

>## Setup
Copy the demo scripts to your working directory
{: .callout}

```bash
# logon FRAM or Betzy
ssh -Y -l <username> fram.sigma2.no
# or
ssh -Y -l <username> betzy.sigma2.no


# clone the sample scripts to your working directory
cd /cluster/work/users/$USER
git clone https://github.com/YanchunHe/noresmpp
cd noresmpp
```

---

>## Interpolate CAM hybrid-sigma coordinate to pressure levels
Inspect the script, and you should be able to run `task1.sh` to interpolate air temperature (T) to pressure levels.
{: .callout}

```bash
cd task1
./task1.sh
```
>## Exercise
* Try interpolate specific humidity in the atmospheric output
* Only interpolate to 200,500,850,1000 hPa levels, and view lat/lon distribution on pressure levels
{: .challenge}

---
>## Remap BLOM tripolar grid 1x1 degree grid
You should be able to run `task2.sh` to interpolate `sst` to 1x1d grid in the NorESM2-LM historical run for year 2010-2014, and compare to HadISST.
{: .callout}

```bash
cd task2
./task2.sh
```

>## Exercise
* Try another experiment `NSSP370frc2_f19_tn14_20191014` for future SSP370 scenario. You only need to change the varilable `casename` in the script.
* Try only interpolate months 6, 7, 8 of years 2010-2014.
{: .challenge}

---
>## Rotate vector variable of BLOM from the model's `i,j` directions to `zonal,meridional` directions
* You should be able to run `task3.sh` to rotate barotropic flow to zonal and meridional directions.
* Run `ncl task3.ncl` to rotate and plot the velocity fieds, and find the difference before and after rotation.
{: .callout}

```bash
cd task3
# rotate with NCO and view with ncview
./task3.sh

# or
# rotate and view with NCL
ncl task3.ncl
```
>## Exercise
* Use your own program (python, NCL, matlab, fortran, etc)  to rotate the vectors.
{: .challenge}

>## Solution
For example, use NCL
```ncl
gid     = addfile("grid.nc","r") 
angle   = gid->angle
fid     = addfile("blom_output.nc","r")
U       = fid->mxlu
V       = fid->mxlv
Urot    = U*cos(angle)-V*sin(angle)
Vrot    = U*sin(angle)+V*cos(angle)
```
{: .solution}

