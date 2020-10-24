# Prebuilt V8 Libraries

See the [project releases](https://github.com/RemeEngine/prebuilt-v8/releases) for downloads, releases are tagged with their V8 version.

## Important, Windows specific

- V8 require linking with `DbgHelp.dll` and `Winmm.dll`

- The binary is built with `V8_COMPRESS_POINTERS` so you also need to define it

## Adding New V8 Version

The `v8-versions` file lists all versions of V8 that GitHub will build. To build a new V8 version, please submit a pull request adding the version to the `v8-versions` list.

## How it work

- When we `push` commits, an action will run and check v8-versions file for a version that did not has a corresponding `tag`

- If such version exists its will tag the latest commit as the new version

- When we create a new tag with the `v*` prefix, a new release with placeholder data will be created

- When a new release is created, we will run a the build script to build `v8` for all supported platform
