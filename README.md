# Plasma Settings

Settings application for Plasma Mobile.

## Configuration modules

Our aim for configuration modules is to work on multiple form factors.
To archieve this, their user interface should be based on the new
[KQuickAddons::ConfigModule API](https://api.kde.org/frameworks/kdeclarative/html/classKQuickAddons_1_1ConfigModule.html)
and Kirigami.
You can find documentation on creating such configuration modules on
[docs.plasma-mobile.org/PlasmaSettings.html](https://docs.plasma-mobile.org/PlasmaSettings.html)

Modules only useful on mobile can be added to the `modules` directory of this
repository, but if they are useful for devices of multiple form factors,
they should go into the plasma-workspace repository.
