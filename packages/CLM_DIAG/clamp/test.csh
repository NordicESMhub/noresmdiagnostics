#!/bin/csh -f

# Version lnd_template4.2.02.csh
#
#BSUB -W 03:00               # wall-clock time (hrs:mins)
#BSUB -P P93300606           # project code
#BSUB -n 1                   # number of tasks in job         
#BSUB -R "span[ptile=1]"     # run 16 MPI tasks per node
#BSUB -J lmwgdiag                # job name
#BSUB -o lmwgdiag.%J.out         # output file name in which %J is replaced by the job ID
#BSUB -e lmwgdiag.%J.err         # error file name in which %J is replaced by the job ID
#BSUB -q geyser             # queue
#

setenv clim_first_yr_1 4 
setenv clim_num_yrs_1  2
setenv prefix_1 b.e11.B1850CN.f19_g16.007
setenv prefix_1_dir /glade/scratch/mickelso/lmwg-sandbox/sandbox1/b.e11.B1850CN.f19_g16.007
setenv nlat_1 96
setenv nlon_1 144
setenv case_1_dir /glade/scratch/mickelso/Data/b.e11.B1850CN.f19_g16.007/lnd/hist/
setenv GRID_1 1.9
setenv WKDIR /glade/scratch/mickelso/lmwg-sandbox/sandbox1/b.e11.B1850CN.f19_g16.007/model1-model2/
setenv use_swift 0

./run_1-model.csh

