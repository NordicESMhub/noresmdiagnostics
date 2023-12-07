#!/bin/bash
# code snipt for submit job for rsync
## status:
## rsync does not work under sbatch environment, can not login to remote?

## SBATCH job for rsync

#/tmp may not visible under sbatch?
#exit

RUNDIR=/cluster/work/users/$USER/diagnostics/run
[ ! -d $RUNDIR ] && mkdir $RUNDIR

cat <<EOF >$RUNDIR/sbatch4rsync$$.sh
#!/bin/bash
# Script template to submit rsync job on Betzy #

#SBATCH --account=$ACCOUNT
#SBATCH --job-name=sbatch4rsync
#SBATCH --partition=preproc
#SBATCH --ntasks=1 --cpus-per-task=1
#SBATCH --mem-per-cpu=2G
#SBATCH --time=0-00:59:00
#SBATCH --output=${LOG_PATH}/slurm4rsync-${YMD}-${HMS}.log
#SBATCH --parsable 
#SBATCH --dependency=afterok:$jobid

## safety settings:
set -o errexit
set -o nounset

## Prepare input files
[ ! -d ${LOG_PATH} ] && mkdir -p ${LOG_PATH}
cd /cluster/shared/noresm/diagnostics/noresm/bin

## Run job
srun --output=${LOG_PATH}/rsync-${YMD}-${HMS}.log $RUNDIR/rsync$$.sh

exit 0

EOF

if [ $(echo $WEB_PATH0 |grep -P '\/trd-project\d\/') ]; then
    echo "The created webpage will be moved to NIRD: "
    echo "$WEB_PATH0/$CASE1"
    echo REMOVE SOURCE Flag: $REMOVE_SOURCE_FILES_FLAG
    if [ "$REMOVE_SOURCE_FILES_FLAG" == "true" ]; then
        echo "And synchronized source files will be removed!"
        echo "( ** BE CAUTIOUS WITH THE RISK ** )"
        cat <<EOF >$RUNDIR/srun4rsync$$.sh
#!/bin/bash
rsync -vazu --remove-source-files $WEB_PATH/$CASE1/ $USER@login.nird.sigma2.no:$WEB_PATH0/$CASE1/ 
wait
tmpdir=$(mktemp -d)
rsync -av --delete $tmpdir/ $WEB_PATH/$CASE1/ 
wait && rmdir $tmpdir
EOF
    else
        cat <<EOF >$RUNDIR/srun4rsync$$.sh
#!/bin/bash
rsync -vazu $WEB_PATH/$CASE1/ $WEB_PATH0/$CASE1/
EOF
    fi

    ## Submit job
    chmod 755 $RUNDIR/sbatch4rsync$$.sh
    jobid=$(sbatch $RUNDIR/sbatch4rsync$$.sh)
    rm -f $RUNDIR/srun4rsync$$.sh $RUNDIR/sbatch4rsync$$.sh

    echo "Check the log: ${LOG_PATH}/rsync-$$.log "
    echo "  "

fi
