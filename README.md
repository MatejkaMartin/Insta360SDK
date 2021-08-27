# Insta360SDK

Current zip checksum: "4d2fdfff03fe180656bed192a2ef64d25b4af275a74610f2873f1f5f0bbff85f"

## How compute checksume

1. Copy the .zip to the folder with package manifest 
2. Open terminal -> 'cd' to the folder with the .zip file
3. swift package compute-checksum sfslfjlf.zip

## Frameworks 

Frameworks: 
https://ios-releases.insta360.com/

INSCoreMedia: 1.25.11 (archs: armv7 x86_64 i386 arm64)
INSCameraSDK: 2.7.26 (2.7.21)  (archs: arm64)

### Check framework supported architectures:
lipo -info path-tofile-INSCoreMedia.framework/INSCoreMedia

### Extract some architecture:
lipo <path> -extract arm64 -output  <output>

### Current frameworks
- are specially provided by Insta360 and they have Bitcode enabled = true. 

