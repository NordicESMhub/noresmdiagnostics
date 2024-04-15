#/bin/env bash

echo "                                                                                                    "
echo "--------------------------------------------------------------------------------------=-------------"
echo "Make links of necessary observational datasets and grid files to the original NoresmDiagnostic tool."
echo "By default, the original diagnostic tool is set as /projects/NS2345K/diagnostics/noresm.            "
echo "Usage: ./linkdata.sh"
echo "    or ./linkdata.sh /absolute/path/to/inputdata"
echo "    (where the last folder contains the *_DIAG/ folders"
echo "--------------------------------------------------------------------------------------------------- "

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
cd $ROOT_DIR

if [ -d /projects/NS2345K/www/diagnostics/inputdata ]; then
    DATA_ROOT=/projects/NS2345K/www/diagnostics/inputdata
elif [ -d /cluster/work/users/$USER/diagnostics/inputdata ]; then
    DATA_ROOT=/cluster/work/users/$USER/diagnostics/inputdata/
elif [ -d /trd-project1/NS2345K/www/diagnostics/inputdata ]; then
    DATA_ROOT=/trd-project1/NS2345K/www/diagnostics/inputdata
elif [ -d /nird/projects/NS2345K/www/diagnostics/inputdata ]; then
    DATA_ROOT=/nird/projects/NS2345K/www/diagnostics/inputdata
elif [ -d /cluster/work/users/$USER/diagnostics/noresm/packages ]; then
    DATA_ROOT=/cluster/work/users/$USER/diagnostics/noresm/packages
else
    echo "                                                                             "
    echo "*** FAIL TO LINK TO DATA FILES OF THE FULL NORESM DIAGNOSTIC TOOL PACKAGE ***"
    echo " The following directories do not exist or you don't have access to: "
    echo "   * /projects/NS2345K/diagnostics/noresm *  "
    echo " NOTE, only NIRD (login.nird.sigma2.no), Betzy (betzy.sigma2.no) "
    echo "   and the IPCC node (ipcc.nird.sigma2.no) are supported to install this tool"
    echo "  "
    echo "*** EXIT THE SCRIPT ***"
    exit 1
fi

[ ! -z $1 ] && DATA_ROOT=$1

echo "DATA_ROOT:"
echo $DATA_ROOT

dfolders=(CAM_DIAG/cam_data)
dfolders+=(CAM_DIAG/map_files)
dfolders+=(CAM_DIAG/obs_data)
dfolders+=(CICE_DIAG/data)
dfolders+=(CICE_DIAG/grids)
dfolders+=(CLM_DIAG/obs_data)
dfolders+=(CLM_DIAG/regriddingFiles)
dfolders+=(HAMOCC_DIAG/grid_files)
dfolders+=(HAMOCC_DIAG/obs_data)
dfolders+=(BLOM_DIAG/grid_files)
dfolders+=(BLOM_DIAG/obs_data)

echo "                               "
echo "The following files are linked:"
for dname in ${dfolders[*]}
do
    #rm -rf $ROOT_DIR/packages/$dname
    if [ -h $ROOT_DIR/packages/$dname ];then
        rm -f $ROOT_DIR/packages/$dname
    elif [ -d $ROOT_DIR/packages/$dname ];then
        echo "** WARNING: data files/folders alreay exist **"
        echo "**                   EXIT                   **"
        exit 1
    fi
    if [ -d $DATA_ROOT/$dname ];then    # NOTE, this does not work for relative path
        ln -sf $DATA_ROOT/$dname $ROOT_DIR/packages/$dname >/dev/null 2>&1
        [ $? -ne 0 ] && echo " *** ERROR linking $DATA_ROOT/$dname ***" && exit 1
        echo "  * $dname"
    else
        echo " *** ERROR: $DATA_ROOT/$dname does not exist **" && exit
    fi
done
echo "                                   "
echo "Data files are successfully linked!"
echo "                                   "

echo "Output will be, by default, written to:"
echo "$ROOT_DIR/out!"

