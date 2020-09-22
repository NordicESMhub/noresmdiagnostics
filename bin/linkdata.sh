#/bin/env bash

echo "                                                                                                    "
echo "--------------------------------------------------------------------------------------=-------------"
echo "Make links of necessary observational datasets and grid files to the original NoresmDiagnostic tool."
echo "By default, the original diagnostic tool is set as /projects/NS2345K/noresm_diagnostics.            "
echo "Usage: ./linkdata.sh"
echo "--------------------------------------------------------------------------------------------------- "

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
cd $ROOT_DIR

if [ -d /projects/NS2345K/www/diagnostics/inputdata ]; then
    DATA_ROOT=/projects/NS2345K/www/diagnostics/inputdata
elif [ -d /tos-project1/NS2345K/www/diagnostics/inputdata ]; then
    DATA_ROOT=/tos-project1/NS2345K/www/diagnostics/inputdata
elif [ -d /cluster/work/users/yanchun/noresmdiagnostics ]; then
    DATA_ROOT=/cluster/work/users/yanchun/noresmdiagnostics/packages
else
    echo "                                                                             "
    echo "*** FAIL TO LINK TO DATA FILES OF THE FULL NORESM DIAGNOSTIC TOOL PACKAGE ***"
    echo " The following directories do not exist or you don't have access to: "
    echo "   1. /projects/NS2345K/noresm_diagnostics"
    echo "   2. /tos-project1/NS2345K/noresm_diagnostics"
    echo " NOTE, only NIRD (login.nird.sigma2.no), FRAM (fram.sigma2.no) "
    echo "   and the IPCC node (ipcc.nird.sigma2.no) are supported to install this tool"
    echo "  "
    echo "*** EXIT THE SCRIPT ***"
    exit 1
fi

dfolders=(CAM_DIAG/cam35_data)
dfolders+=(CAM_DIAG/map_files)
dfolders+=(CAM_DIAG/obs_data)
dfolders+=(CAM_DIAG/rgb)
dfolders+=(CICE_DIAG/data)
dfolders+=(CICE_DIAG/grids)
dfolders+=(CICE_DIAG/rgb)
dfolders+=(CLM_DIAG/clamp)
dfolders+=(CLM_DIAG/obs_data)
dfolders+=(CLM_DIAG/regriddingFiles)
dfolders+=(HAMOCC_DIAG/grid_files)
dfolders+=(HAMOCC_DIAG/obs_data)
dfolders+=(HAMOCC_DIAG/rgb)
dfolders+=(BLOM_DIAG/grid_files)
dfolders+=(BLOM_DIAG/obs_data)

echo "                               "
echo "The following files are linked:"
for dname in ${dfolders[*]}
do
    #rm -rf $ROOT_DIR/packages/$dname
    ln -sf $DATA_ROOT/$dname $ROOT_DIR/packages/$dname >/dev/null 2>&1
    [ $? -ne 0 ] && echo " *** ERROR linking $DATA_ROOT/$dname ***" && exit 1
    echo "  * $dname"
done
echo "                                   "
echo "Data files are successfully linked!"
echo "                                   "

echo "Output will be by default written to:"
echo "$ROOT_DIR/out!"

