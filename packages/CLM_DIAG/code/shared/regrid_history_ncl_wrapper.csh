#!/bin/csh 

# written by Sheri Mickelson

setenv procDir $1
setenv InFile $2
setenv method $3
setenv wgt_dir $4
setenv wgt_file $5
setenv area_dir $6
setenv area_file $7
setenv script_dir $8
setenv old_res $9
setenv new_res $10
setenv OutFile ${new_res}_${InFile}
set output_dir = $11
set outfile_name = $12

touch temp.out

echo "Regridding " $InFile

$NCL < $script_dir/se2fv_esmf.regrid2file.ncl >> temp.out
if ($status != 0)  exit

mv ${procDir}/${OutFile} $output_dir

#echo ncks -A -v area ${area_dir}/${area_file} $output_dir/$OutFile
$ncksbin/ncks -A -v area ${area_dir}/${area_file} $output_dir/$OutFile

ln -s $output_dir/$OutFile $output_dir/$InFile

cp temp.out $outfile_name

