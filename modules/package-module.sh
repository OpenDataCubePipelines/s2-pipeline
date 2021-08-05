#!/usr/bin/env bash

set -eu

umask 002
#unset PYTHONPATH

echo "##########################"
echo

# Switch between these two for prod and dev builds
#echo "module_dir = ${module_dir:=/g/data/v10/private/modules}"
echo "module_dir = ${module_dir:=/g/data/u46/users/dsg547/devmodules}"

# Modify these to change the eo-dataset module used
#echo "ard_pipeline_module_dir = ${ard_pipeline_module_dir:=/g/data/v10/private/modules}"
echo "ard_pipeline_module_dir = ${ard_pipeline_module_dir:=/g/data/u46/users/dsg547/devmodules}"
echo
#echo "ard_pipeline_module = ${ard_pipeline_module:=ard-pipeline/20210129}"
echo "ard_pipeline_module = ${ard_pipeline_module:=ard-pipeline/devv2.1}"

echo "dep_module = ${dep_module:=h5-compression-filters/20200612}"
ard_pipeline_module_name=${ard_pipeline_module%/*}
instance=${ard_pipeline_module_name##*-}
echo "instance = ${instance}"
echo
echo
echo "##########################"
export module_dir ard_pipeline_module dep_module

echoerr() { echo "$@" 1>&2; }

if [[ $# != 1 ]] || [[ "$1" == "--help" ]];
then
    echoerr
    echoerr "Usage: $0 <version>"
    exit 1
fi
export version="$1"

module use /g/data/v10/public/modules/modulefiles
module use /g/data/v10/private/modules/modulefiles
module use ${module_dir}/modulefiles
# module use -a ${ard_pipeline_module_dir}/modulefiles  # why the -a?
module use  ${ard_pipeline_module_dir}/modulefiles

echo 'module load ${ard_pipeline_module}'
module load ${ard_pipeline_module}
echo 'module loaded'

python_version=$(python -c 'from __future__ import print_function; import sys; print("%s.%s"%sys.version_info[:2])')
python_major=$(python -c 'from __future__ import print_function; import sys; print(sys.version_info[0])')
subvariant=py${python_major}


function installrepo() {
    destination_name=$1
    head=${2:=develop}
    repo=$3

    repo_cache="cache/${destination_name}.git"

    if [ -e "${repo_cache}" ]
    then
        pushd "${repo_cache}"
            git remote update
        popd
    else
        git clone --mirror "${repo}" "${repo_cache}"
    fi

    build_dest="build/${destination_name}"
    [ -e "${build_dest}" ] && rm -rf "${build_dest}"
    git clone -b "${head}" "${repo_cache}" "${build_dest}"

    pushd "${build_dest}"
        rm -r dist build > /dev/null 2>&1 || true
        python setup.py sdist
        pip install dist/*.tar.gz "--prefix=${package_dest}"
    popd
}



#package_name=ard-scene-select-${subvariant}-${instance}
#package_name=s2-pipeline-${subvariant}-${instance}
package_name=s2-pipeline-${subvariant}
package_description="GA ARD S2 pipeline"
package_dest=${module_dir}/${package_name}/${version}
python_dest=${package_dest}/lib/python${python_version}/site-packages
export package_name package_description package_dest python_dest
printf '# Remember to check-code.sh and run black first. #\n'
printf '# Packaging "%s %s" to "%s" #\n' "$package_name" "$version" "$package_dest"

read -p "Continue? [y/N]" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Creating directory"
    mkdir -v -p "${python_dest}"
    # The destination needs to be on the path so that latter dependencies can see earlier ones
    export PYTHONPATH=${PYTHONPATH:+${PYTHONPATH}:}${python_dest}

    echo
    echo "Installing S2-pipeline"
    installrepo s2-pipeline   main         https://github.com/OpenDataCubePipelines/s2-pipeline
    echo
    echo "Writing modulefile"
    modulefile_dir="${module_dir}/modulefiles/${package_name}"
    mkdir -v -p "${modulefile_dir}"
    modulefile_dest="${modulefile_dir}/${version}"
    envsubst < modulefile.template > "${modulefile_dest}"
    echo "Wrote modulefile to ${modulefile_dest}"
fi

rm -rf build > /dev/null 2>&1


echo
echo 'Done.'

    
