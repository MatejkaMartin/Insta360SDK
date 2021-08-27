#!/usr/bin/env bash

ROOT=`dirname $0`

cd $ROOT

 rm -rf  ./archives

xcodebuild archive \
  -scheme Insta360SDK \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "archives/Insta360SDK-Simulator" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "Archived for simulator"

xcodebuild archive \
  -scheme Insta360SDK \
  -destination generic/platform=iOS \
  -archivePath "archives/Insta360SDK" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "Archived for device"

cp -r ./archives/Insta360SDK-Simulator.xcarchive/Products/Library/Frameworks/. ./archives/simulator
cp -r ./archives/Insta360SDK-Simulator.xcarchive/dSYMs/Insta360SDK.framework.dSYm ./archives/simulator

cp -r ./archives/Insta360SDK.xcarchive/Products/Library/Frameworks/. ./archives/ios
cp -r ./archives/Insta360SDK.xcarchive/dSYMs/Insta360SDK.framework.dSYM ./archives/ios

echo "Copied frameworks"

xcodebuild -create-xcframework -framework archives/simulator/Insta360SDK.framework -framework archives/ios/Insta360SDK.framework -output archives/Insta360SDK.xcframework

echo "Created XCFramework"
echo "Done"
