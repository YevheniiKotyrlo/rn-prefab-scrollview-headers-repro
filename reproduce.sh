#!/usr/bin/env bash
# Exit 1 while ReproducerApp's C++ cannot include ScrollView's headers from the react-android prefab, 0 once it builds, 2 when another step fails.
set -u

here="$(cd "$(dirname "$0")" && pwd)"
app="${here}/ReproducerApp"
missing_header="react/renderer/components/scrollview/ScrollViewComponentDescriptor.h' file not found"

system="$(uname -sm)"
if ! node_version="$(node --version 2>&1)"; then
    echo "step failed: node --version: ${node_version}"
    exit 2
fi
if ! java_version="$(java -version 2>&1)"; then
    echo "step failed: java -version: ${java_version}"
    exit 2
fi
echo "${system}, node ${node_version}, ${java_version%%$'\n'*}"

if ! install_output="$(cd "${app}" && yarn install --frozen-lockfile --non-interactive 2>&1)"; then
    printf '%s\n' "${install_output}"
    echo "step failed: yarn install"
    exit 2
fi
if ! react_native_version="$(cd "${app}" && node -p 'require("react-native/package.json").version' 2>&1)"; then
    echo "step failed: reading react-native's version: ${react_native_version}"
    exit 2
fi
echo "react-native ${react_native_version}"

echo "== ./gradlew :app:externalNativeBuildDebug -PreactNativeArchitectures=arm64-v8a"
build_output="$(cd "${app}/android" && ./gradlew --no-daemon --console=plain :app:externalNativeBuildDebug -PreactNativeArchitectures=arm64-v8a 2>&1)"
build_status=$?
compiler_lines="$(grep -E "^C/C\+\+: .*ScrollViewDescriptorProvider\.cpp:[0-9]+:[0-9]+: |^BUILD (SUCCESSFUL|FAILED)" <<<"${build_output}")"
sed -E 's#^C/C\+\+: .*/(ReproducerApp/)#C/C++: \1#' <<<"${compiler_lines}"
prefab_include="$(grep -oE -m 1 "[^ ]*/react-android-[^ /]*/prefab/modules/reactnative/include" <<<"${build_output}")"
if [[ -n "${prefab_include}" ]]; then
    echo "== react/renderer/components in ${prefab_include#*/transformed/}"
    ls "${prefab_include}/react/renderer/components"
fi

if [[ "${build_status}" -eq 0 ]]; then
    echo "SUMMARY: ScrollView's headers resolve from the react-android prefab"
    exit 0
fi
if grep -qF "${missing_header}" <<<"${build_output}"; then
    echo "SUMMARY: the react-android prefab has no react/renderer/components/scrollview headers"
    exit 1
fi
printf '%s\n' "${build_output}" | tail -n 40
echo "SUMMARY: the build failed for another reason (exit ${build_status})"
exit 2
