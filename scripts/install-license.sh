license_file_remote=$1
echo "Downloading license file"
gsutil cp "$license_file_remote" lf
echo "Installing license file"
# Currently interactive, so need this workaround
/var/microfocuslicensing/bin/cesadmintool.sh -install `pwd`/lf << block
block
