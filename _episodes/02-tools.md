---
layout: episode
title: "Tools for file operation and visualization"
teaching: 20
keypoints:
  - "File operations"
  - "Data visualisation"
  - "Quick image edition"

---
>## 1. File operations
* NetCDF Utilities
* NCO
* CDO
{: .callout}

### NetCDF Utilities
#### ncdump
Convert NetCDF file to text form called called CDL (network Common Data form Language)
```bash
# Look at the structure of the data in the netCDF file foo.nc:
ncdump -c foo.nc

# Output data for only the variables uwind and vwind from the netCDF file foo.nc, and show the floating-point data with only three significant digits of precision:
ncdump -v uwind,vwind -p 3 foo.nc
```
#### nccopy
Copy a netCDF file, optionally changing format, compression, or chunking in the output. 
```bash
# Make a copy of foo1.nc, a netCDF file of any type, to foo2.nc, a netCDF file of the same type:
nccopy foo1.nc foo2.nc
# Convert a netCDF-4 classic model file, compressed.nc, that uses compression, to a netCDF-3 file classic.nc:
nccopy -k classic compressed.nc classic.nc
```

#### ncgen
The ncgen tool generates a netCDF file or a C or FORTRAN program that creates a netCDF dataset. 
```bash
# From the CDL file foo.cdl, generate an equivalent binary netCDF file named bar.nc:
ncgen -o bar.nc foo.cdl
```

#### ncgen3
New name of `ncgen` utility. The ncgen3 utility can only generate classic-model netCDF-4 files or programs.

_Reference: [https://www.unidata.ucar.edu/software/netcdf/docs/netcdf_utilities_guide.html](https://www.unidata.ucar.edu/software/netcdf/docs/netcdf_utilities_guide.html)_

---

### NCO
The netCDF Operators (NCO) comprise about a dozen standalone, command-line programs that take netCDF/HDF files as input, then operate (e.g., derive new fields, compute statistics, print, hyperslab, manipulate metadata, regrid) and output the results to screen or files in text, binary, or netCDF formats.

NCO aids analysis of gridded and unstructured scientific data. The shell-command style of NCO allows users to manipulate and analyze files interactively, or with expressive scripts that avoid some overhead of higher-level programming environments.

* `ncap2`   : netCDF Arithmetic Processor
* `ncatted` : netCDF ATTribute EDitor
* `ncbo`    : netCDF Binary Operator (addition, multiplication...)
* `ncclimo` : netCDF CLIMatOlogy Generator
* `nces`    : netCDF Ensemble Statistics
* `ncecat`  : netCDF Ensemble conCATenator
* `ncflint` : netCDF FiLe INTerpolator
* `ncks`    : netCDF Kitchen Sink
* `ncpdq`   : netCDF Permute Dimensions Quickly, Pack Data Quietly
* `ncra`    : netCDF Record Averager
* `ncrcat`  : netCDF Record conCATenator
* `ncremap` : netCDF REMAPer
* `ncrename`: netCDF RENAMEer
* `ncwa`    : netCDF Weighted Averager

**An example to make global averaged $var weighted by grid cell volume**
```bash
ncks --quiet -A -v parea -o datafile.nc gridfile.nc
ncap2 -O -s 'dmass=dp*parea' datafile.nc  -o datafile.nc
ncwa --no_tmp_fl -O -v $var -w dmass -a sigma,y,x datafile.nc average.nc
```

_Reference: [http://nco.sourceforge.net](http://nco.sourceforge.net)_

---

### CDO
CDO is a collection of command line Operators to manipulate and analyse Climate and NWP model Data. 
<img src="{{ site.baseurl }}/images/cdorefcard.png" width="600px" alt="Archive structure of model output">

An example to remap sst from ocean model tripolar grid to 1x1 grid with CDO
```bash
# append grid information
ncks -A -v plon,plat,parea -o datafile.nc gridfile.nc
# remap
cdo remapbil,global_1 -selname,sst datafile.nc datafile1x1d.nc
# create a 2D plot
cdo shaded,device="pdf",interval=1,colour_min=violet,colour_max=red,colour_triad=cw -selname,sst datafile1x1d.nc figure
```

>## 2. Visualisation
* ncview
* Panoply
* Ocean Data View
* NCL
{: .callout}

### ncview
Ncview is a visual browser for netCDF format files, which allows one to quickly view the variables inside a netCDF file.

<img src="http://meteora.ucsd.edu/~pierce/docs/ncview.gif" width="600px" alt="ncview" >

### Panoply
Panoply plots geo-referenced and other arrays from netCDF, HDF, GRIB, and other datasets.

<img src="https://www.giss.nasa.gov/tools/panoply/panoply_400.jpg" width="600px" alt="Panoply" >

### NCL
<img src="http://www.ncl.ucar.edu/Images/NCLMainImage.png" width="600px" alt="Panoply" >

_Reference:[http://www.ncl.ucar.edu](http://www.ncl.ucar.edu)

**NOTE:** NCL developement is phasing out. New developments are shifting to python-based language `pyNIO` and graphcis `pyNGL`.

### Ocean Data View
Ocean Data View (ODV) is a software package for the interactive exploration, analysis and visualization of oceanographic and other geo-referenced profile, time-series, trajectory or sequence data. 

Use ODV to produce: 

* property/property plots of selected stations,
* scatter plots for sets of stations,
* color sections along arbitrary cruise tracks,
* color distributions on general isosurfaces,
* temporal evolution plots of tracer fields,
* differences of tracer fields between repeats,
* geostrophic velocity sections,
* animations,
* interrupted maps.

<img src="https://odv.awi.de/fileadmin/user_upload/odv.awi.de/user_upload/odv/pics/odv_section.jpg" width="600px" alt="Panoply" >

>## 3. Image editor
* ImageMagick
* Latex PDF utility
* Ghostscript
* ffmpeg
{: .callout}

### ImageMagick
ImageMagick® is used to create, edit, compose, or convert bitmap images.

<img src="https://imagemagick.org/image/wizard.png" width="300px" alt="ImageMagick" >

```bash
## display
# display image at local or remote compute
display -resize 800x600 file.jpg
# display multiple images with delays
display -delay 50 *.jpg

## convert
# convert from eps to jpg
convert -density 300x300 -resize 1024x768 -quality 90 xxx.eps xxx.jpg
# convert pdf to png
convert -quality 100 -antialias -density 96 -transparent white -trim test.pdf test.png
# transpart image with -alpha option
convert -alpha on/off in.pdf out.png
# create a black frame fro all found images
find ./ -name "*.JPG" -exec convert -border 60x60 -bordercolor "#000000" -resize 1024x800 {} {}.view.jpg \;
# transpart image with 5% fuzz
convert -fuzz 5% -transparent white in.png out.png
# animation
convert -resize 800x600 -delay 100 file*.png file.gif

## composite
composite foreground.png background.png output.png
```
_Reference: [https://imagemagick.org](https://imagemagick.org)
### Latex PDF utitlity
#### pdfcrop
Margins are calculated and removed for each page in the file
```
pdfcrop foo.pdf bar.pdf
```
_Reference: [http://pdfcrop.sourceforge.net](http://pdfcrop.sourceforge.net)_

### Ghostscript
#### ps2pdf
Convert `.ps` to `pdf`

#### Ghostview
Ghostview is an X11 user interface for Ghostscript, allowing you to view and navigate PostScript files.

### ffmpeg
A complete, cross-platform solution to record, convert and stream audio and video.
```
ffmpeg -loop 0 -start_number 1948 -framerate 4 -i Figure_%04d_720p.png  -s:v 1280x720 -c:v libx264 -pix_fmt yuv420p Animation.mp4
```
_Reference: [https://ffmpeg.org](https://ffmpeg.org)_
