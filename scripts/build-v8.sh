#!/bin/bash
set -euo pipefail

PATH="$PWD/depot_tools:$PATH"

platform=$1
version=${2#"v"}

spec=`cat spec.cfg`
spec="${spec//$'\n'/}"

build_args=`cat ./build_args.cfg`
build_args="${build_args//$'\n'/ }"

# Resolve platform name
case $platform in
  Linux)
    platform=linux
    ;;
  macOS)
    platform=darwin
    ;;
  *)
    echo "Invalid platform $platform"
    exit 1
    ;;
esac

# Acquire V8 source
if [ ! -d v8 ]; then
  fetch v8
fi

# Prepare build directory
rm -rf build
mkdir build

# Prepare solution
gclient sync -R -D --revision $version --spec "$spec"

# Generate build config
cd v8
gn gen ../build --args="$build_args"
cd ..

# Build V8
cd v8
ninja -v -C ../build v8_monolith
cd ..

# Create package
rm -rf package
mkdir package
cp build/obj/libv8_monolith.a package/libv8.a
cp -r v8/include package/include
tar czf build/v8-v$version-$platform.tar.gz -C package .

# Output package metadata for GitHub actions
echo "::set-output name=package::v8-v$version-$platform"
echo "::set-output name=package_path::build/v8-v$version-$platform.tar.gz"
