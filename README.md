# Insta360SDK


Frameworks: 
https://ios-releases.insta360.com/

INSCoreMedia: 1.25.11 (archs: armv7 x86_64 i386 arm64)
INSCameraSDK: 2.7.26 (2.7.21)  (archs: arm64)

Framework supported architecture:
lipo -info path-tofile-INSCoreMedia.framework/INSCoreMedia

Extract some architecture:
lipo <path> -extract arm64 -output  <output>

### Extract INCoreMedia

Extract the framework to arch64 to reduce his size. From 150 MBs to only 36 MBs.
