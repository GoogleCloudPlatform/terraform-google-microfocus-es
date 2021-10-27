license_filename=$1
echo "Installing license file"
# Currently interactive, so need this workaround
/var/microfocuslicensing/bin/cesadmintool.sh -install `pwd`/$license_filename << block
block
