# mXMRig - XMRig for iOS
mXMRig is a high performance RandomX, KawPow, CryptoNight and AstroBWT unified CPU miner for iOS platform

You can find more info here: [https://www.mxmrig.com](https://www.mxmrig.com)

## How to
Unfortunately I'm not proficient at CMake, so building requires a lot of steps.
You have to use cmake to create *.xcodeproj (original cmake creates projects with absolute paths 😞). The generated project will be a macos command line app.
After manually converting it to iOS and fixing all build issues you'll be able to actually create a binary and run it on the device.
I would really appreciate if someone could fix the cmake file to generate iOS-compatible project out of the box!
