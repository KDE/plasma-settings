<!--
- SPDX-FileCopyrightText: None
- SPDX-License-Identifier: CC0-1.0
-->

# Plasma Settings

Settings application for Plasma Mobile.

It only supports QML based KCMs (settings modules).

## Running

The application filters KCMs by the current platform environment variable:

```bash
PLASMA_PLATFORM=handset plasma-settings # For KCMs relevant to Plasma Mobile
```

By default, the platform is `desktop`.

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
