---
layout: episode
title: "Special post-processing"
teaching: 20
#exercises: 90
#questions:
  #- "A question that this episode will answer?"
  #- "Another question?"
objectives:
  - "Pre-process the NorESM output on irregular grid to commonly used grid system"
  #- "This is another objective of this episode."
  #- "Yet another objective."
  #- "And not to forget this objective."
#keypoints:
  #- "This is an important key point."
  #- "Another important key point."
  #- "One more key point."

---
> ## NorESM horizontal and vertical grid system
Needs to remap irregular model grids to standard grid to facilitate comparision with observations and multiple model intercomparision.
{: .callout}

<img src="{{ site.baseurl }}/images/grid.png" width="800px" alt="NorESM horizontal and vertical grid system">

---
>## Convert CAM hybrid-sigma coordinate to pressure levels
{: .objectives}

|The vertical coordinate of CAM is a hybrid sigma-pressure system. In this system, the upper regions of the atmosphere are discretized by pressure only. Lower vertical levels use the sigma (i.e. p/ps) vertical coordinate smoothly merged in, with the lowest levels being pure sigma. A schematic representation of the hybrid vertical coordinate and vertical indexing is presented in the right.|<img src="{{ site.baseurl }}/images/hyb_coord.gif" width="400px" alt="NorESM horizontal and vertical grid system"> |

```bash
# Extract variable
ncks -O -v ${VAR},ilev $filename var_tmp.nc
# Add layer interface 'ilev' as bounds of vertical coordinate 'lev’
ncatted -a bounds,lev,c,c,"ilev" var_tmp.nc
# Interpolate from hybrid sigma-pressure to pressure levels
cdo ml2pl,3000.,5000.,7000.,10000.,15000.,20000.,25000.,30000.,35000.,40000., \
    var_tmp.nc var_ml2pl.nc
# Convert Pa to hPA
ncap2 -O -s 'plev=plev/100' var_ml2pl.nc var_ml2pl.nc
# Change the "units" from Pa to hPa
ncatted -a units,plev,m,c,"hPa" var_ml2pl.nc
# Make zonal mean
cdo -s zonmean var_ml2pl.nc var_ml2pl_zm.nc
# View result
ncview var_ml2pl2_zm.nc &
```

---
>## Regrid ocean tripolar grid to 1x1 degree grid
{: .objectives}

<img src="{{ site.baseurl }}/images/tripolar.png" width="300px" alt="sst tripolar">
<img src="{{ site.baseurl }}/images/1x1d.png" width="500px" alt="sst tripolar">

```bash
# Regrid data
ncks -A -v plat,plon grid.nc blom_sst.nc
cdo -O remapbil,global_1 blom_sst.nc blom_sst_1x1d.nc

# Make difference between model and observation
ncdiff -O blom_sst_1x1d.nc HadISST_sst.nc sst_diff.nc
```

---
>## Rotate vector from model `i,j` direction to zonal and meridional directions.
{: .objectives}

<img src="{{ site.baseurl }}/images/rotateno.png" width="400px" alt="sst tripolar">
<img src="{{ site.baseurl }}/images/rotateyes.png" width="400px" alt="sst tripolar">

Rotate BLOM vectors using NCO
```bash
# Extract ubaro,vbaro
ncks -O -v ubaro,vbaro $filename uv.nc
# Add vector angle to micom variable file
ncks -A -v angle grid.nc uv.nc
# Generate roated new verctors
ncap2 -O -s "urot=ubaro*cos(angle)-vbaro*sin(angle);vrot=ubaro*sin(angle)+vbaro*cos(angle)"
    \ uv.nc uvrot.nc 
# View the data
ncview uvrot.nc
```
