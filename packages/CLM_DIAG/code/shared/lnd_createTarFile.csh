#!/bin/csh -f

echo 'Working in lnd_createTarFile.csh : making tar file and deleting ps files'

# make tarfile of web pages
  set tarfile = ${WEBFOLD}.tar
  set tardir = $tarfile:r
  echo MAKING TAR FILE OF DIRECTORY $tardir
  cd $PTMPDIR/$prefix_1
  tar -cf {$PTMPDIR}/{$prefix_1}/$tarfile $tardir

# copy the tarfile to remote machine
  if ($remote == 1) then
    	echo `date` > email_msg
    	echo MESSAGE FROM THE LMWG DIAGNOSTIC PACKAGE. >> email_msg
    	echo THE PLOTS FOR $tardir ARE NOW READY! >> email_msg
    	mail -s 'LMWG diagnostics are complete' $email_address < email_msg
    	echo E_MAIL SENT
    	'rm' email_msg
	if ($scpFile == 1) then
    		scp {$prefix_1_dir}$tarfile {$remote_system}:{$remote_dir}
    		echo COPY TARFILE DONE
	endif
  endif
