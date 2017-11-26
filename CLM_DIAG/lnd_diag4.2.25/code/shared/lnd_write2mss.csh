#!/bin/csh -fxv
#
date
set machine = `hostname | cut -c1-1`

if ($RUNTYPE == "model1-model2") then
	set case    = ( $caseid_1 $caseid_2 )
	set prefix  = ( $prefix_1 $prefix_2 )
	set direc   = ( $prefix_1_dir $prefix_2_dir )
	set mss     = ( $MSS_path_out1 $MSS_path_out2 )
        set tarfile = ${prefix_1_dir}/${prefix_1}-${prefix_2}.tar
        set tarname = ${prefix_1}-${prefix_2}.tar 
else 
	set case    = ( $caseid_1 )
	set prefix  = ( $prefix_1 )
	set direc   = ( $prefix_1_dir )
	set mss     = ( $MSS_path_out1 )
        set tarfile = ${prefix_1_dir}/${prefix_1}-obs.tar
        set tarname = ${prefix_1}-obs.tar
endif

set fileList  = ( _ANN_ALL _ANN_climo _ANN_means _DJF_climo _DJF_means\
		_MAM_climo _MAM_means _JJA_climo _JJA_means\
		_SON_climo _SON_means _MONS_climo)

@ indx = 1
foreach c ( ${case} )

# NCAR tempest
  if ($machine == "t") then
    # set mso = /${mss}/${case[$indx]}/climo
# ORNL
  else if ($machine == "e") then
    set atmd = /tmp/gpfs600a/${USER}/${direc[$indx]}
    # set mso = "/dfs/home/oleson/pcm/${c}/climo"
  endif

  if ($status == 0) then

    if (`which msrcp | wc -w` == 1 ) then
       # write climo and means files to MSS
       foreach i ($fileList)
          set file  = ${direc[$indx]}/${prefix[$indx]}${i}.nc
          set fname = ${prefix[$indx]}${i}.nc
	  echo Writing $file to ${mss[$indx]}
          if (-e $file) then
       	      msrcp -proj $MSS_proj -pe $MSS_pe $file mss:${mss[$indx]}/${fname}
          endif
	  # write atm files to MSS if they exist
          set file  = ${direc[$indx]}/atm/${prefix[$indx]}${i}_atm.nc
          set fname = ${prefix[$indx]}${i}_atm.nc
          if (-e $file) then
	      echo Writing $file to ${mss[$indx]}
       	      msrcp -proj $MSS_proj -pe $MSS_pe $file mss:${mss[$indx]}/atm/${fname}
          endif
       end 

       # write tarfile to MSS
       set file = $tarfile
       set fname = $tarname
       if (-e $file) then
       	     msrcp -proj $MSS_proj -pe $MSS_pe $file mss:${mss[$indx]}/${fname}
       endif
    endif

    # If NERSC/ORNL hsi command exists, use it.
    # if ( `which hsi | wc -w` == 1  ) then
      # foreach f ( ${file} )
        # hsi -q "mkdir -p ${mss[$indx]} ; chmod -R 775 ${mss[$indx]}"
        # hsi -q "cd ${mss[$indx]} ; put ${f} ; chmod 664 ${f}"
    #   if ($status == 0) rm -f ${f}
    #  end
    # endif
    
  endif
  @ indx ++
end
#
exit
