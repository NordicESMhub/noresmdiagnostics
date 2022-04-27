#!/bin/csh -f

# written by Sheri Mickelson
# March 2013

setenv mycwd $PWD

if ($regrid_1 == 1) then

  setenv method $method_1
  setenv wgt_dir $wgt_dir_1
  setenv wgt_file $wgt_file_1
  setenv area_dir $area_dir_1
  setenv area_file $area_file_1
  setenv procDir $prefix_1_dir

  cd  ${prefix_1_dir}

  ls *.nc > files_to_regrid_1.out
  set files = `cat files_to_regrid_1.out`

  foreach file ($files)

    setenv InFile  $file
    setenv OutFile $new_res_1"_"$file
    setenv newfn $old_res_1"_"$file

    echo "REGRIDDING" $file

    $NCL < $DIAG_SHARED/se2fv_esmf.regrid2file.ncl
    if ($status != 0)  exit

    $ncksbin/ncks -A -v area ${area_dir}/${area_file} {$prefix_1_dir}/$OutFile
    mv ${prefix_1_dir}/$file ${prefix_1_dir}/$newfn
    mv ${prefix_1_dir}/$OutFile ${prefix_1_dir}/$file
    ln -s ${prefix_1_dir}/$file ${prefix_1_dir}/$OutFile
  end

endif

if ($regrid_2 == 1) then

  setenv method $method_2
  setenv wgt_dir $wgt_dir_2
  setenv wgt_file $wgt_file_2
  setenv area_dir $area_dir_2
  setenv area_file $area_file_2
  setenv procDir $prefix_2_dir

  cd  ${prefix_2_dir}

  ls *.nc > files_to_regrid_2.out
  set files = `cat files_to_regrid_2.out`

  foreach file ($files)

    setenv InFile  $file
    setenv OutFile $new_res_2"_"$file
    setenv newfn $old_res_2"_"$file

    echo "REGRIDDING" $file

    $NCL < $DIAG_SHARED/se2fv_esmf.regrid2file.ncl
    if ($status != 0)  exit

    $ncksbin/ncks -A -v area ${area_dir}/${area_file} {$prefix_2_dir}/$OutFile
    mv ${prefix_2_dir}/$file ${prefix_2_dir}/$newfn
    mv ${prefix_2_dir}/$OutFile ${prefix_2_dir}/$file
    ln -s ${prefix_2_dir}/$file ${prefix_2_dir}/$OutFile
  end

endif

cd $mycwd

