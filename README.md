# rn-prefab-scrollview-headers-repro

![Build](https://github.com/YevheniiKotyrlo/rn-prefab-scrollview-headers-repro/workflows/Pre%20Merge%20Checks/badge.svg)

ReproducerApp on React Native `0.90.0-nightly-20261111-1273ca128` (`main` at 1273ca128), with one C++ file in the app's native library that includes ScrollView's component descriptor from the react-android AAR's prefab:

- `ReproducerApp/android/app/build.gradle` points `externalNativeBuild` at `src/main/jni/CMakeLists.txt`.
- `ReproducerApp/android/app/src/main/jni/CMakeLists.txt` is React Native's default app setup plus `scrollview/ScrollViewDescriptorProvider.cpp`.
- `ScrollViewDescriptorProvider.cpp` includes `react/renderer/components/view/ViewComponentDescriptor.h`, which resolves, and `react/renderer/components/scrollview/ScrollViewComponentDescriptor.h`, which does not.

## Reproduce

```bash
./reproduce.sh
```

It runs `yarn install` and `./gradlew :app:externalNativeBuildDebug -PreactNativeArchitectures=arm64-v8a` in `ReproducerApp`, prints the compiler's error and the folders under `react/renderer/components` in the prefab include directory the build used, and exits 1 while the scrollview header is missing, 0 once the build succeeds, 2 when another step fails. CI's `test-android` job (`yarn react-native build-android`) fails the same way.

Expected: the include resolves, as the view, image, text and textinput headers do. Seen: `fatal error: 'react/renderer/components/scrollview/ScrollViewComponentDescriptor.h' file not found`.
