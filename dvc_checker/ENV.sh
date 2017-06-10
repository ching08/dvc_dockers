##! /bin/bash
export DVC_TEST_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

virtual_folder="${DVC_TEST_HOME}/.dvc_checker"

#--------------------------
# function
#--------------------------

function add_path() {
    if [[ $PATH  =~ .*"${1}".* ]] ; then
        set x 1
    else
	if [[ -d "$1" || -L "$1" ]] ; then
	                export PATH=${1}:$PATH
			    else
	                echo "-warning: $1 does not exists. can not add it to PATH"
			        
			    fi
    fi
    
} 


function add_python_path() {
    if [[ $PYTHONPATH  =~ .*"${1}".* ]] ; then
	set x 1 
    else
	export PYTHONPATH=${1}:$PYTHONPATH
    fi
    
} 

#-------------------------------------------
# end of function
#-------------------------------------------



#-------------------------------------------
# for git
#-------------------------------------------
export GIT_SSL_NO_VERIFY=1 


#-------------------------------------------
# create virtual env
#-------------------------------------------
if [ ! -z $VIRTUAL_ENV ]; then
    echo "deactivate ENV $(basename $VIRTUAL_ENV)"
    deactivate
fi
echo "virtual folder: $virtual_folder"
if [  ! -d $virtual_folder ]; then
    echo "Warning: virtual env not setup."
    echo "creating virtual env folder $virtual_folder"
    virtualenv $virtual_folder
    . $virtual_folder/bin/activate
    pip install -r ${DVC_TEST_HOME}/requirements.txt 
else
    . $virtual_folder/bin/activate

fi


# disable file permission checking for git
git config core.fileMode false



#-------------------------------------------
# set python and path 
#-------------------------------------------

#unset PYTHONPATH
add_python_path ${DVC_TEST_HOME}
add_python_path ${DVC_TEST_HOME}/Lib

# ## source the env 
set -x
export $(cat ${DVC_TEST_HOME}/../env | grep -v ^# | xargs)
set +x

if [ ! -d /tmp/dvc_reports ]; then
    mkdir /tmp/dvc_reports
fi


echo ""
echo "+OK. in virtual environment $virtual_folder"
echo "Please enter 'deactivated' to get out of virtual envirnoment"

