# Plasma Settings

Settings application for Plasma Mobile.

It only supports QML based KCMs.

## Build and run from source

This project uses `cmake` to find the dependencies and build the project.

```sh
cmake -S . -B build -DCMAKE_INSTALL_PREFIX=${PWD}/install
cmake --build build --target install -j4
```

Defining the installation prefix (with `CMAKE_INSTALL_PREFIX`)
generates a file in the build folder (`build/prefix.sh`) with
environment variables for `plasma-settings` to find the freshly built modules.

To run `plasma-settings` first source the environment variables and then start the binary.

```sh
source build/prefix.sh
./install/bin/plasma-settings
```
