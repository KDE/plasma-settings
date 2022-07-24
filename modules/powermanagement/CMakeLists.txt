# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mobile_power\")

add_library(kcm_mobile_power MODULE mobilepower.cpp)

target_link_libraries(kcm_mobile_power
    Qt::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    KF5::ConfigCore
)

install(TARGETS kcm_mobile_power DESTINATION ${PLUGIN_INSTALL_DIR}/kcms)

kpackage_install_package(package kcm_mobile_power kcms)
