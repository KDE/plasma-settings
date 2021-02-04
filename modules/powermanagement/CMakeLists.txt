# SPDX-License-Identifier: BSD-3-Clause
# SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_definitions(-DTRANSLATION_DOMAIN=\"kcm_mobile_power\")

set(kcm_SRCS
   mobilepower.cpp
)

add_library(kcm_mobile_power MODULE ${kcm_SRCS})

target_link_libraries(kcm_mobile_power
    Qt5::Core
    KF5::CoreAddons
    KF5::I18n
    KF5::QuickAddons
    KF5::ConfigCore
    KF5::Service
)

kcoreaddons_desktop_to_json(kcm_mobile_power powermanagement.desktop SERVICE_TYPES kcmodule.desktop)

#this desktop file is installed only for retrocompatibility with sycoca
install(FILES powermanagement.desktop DESTINATION ${SERVICES_INSTALL_DIR})
install(TARGETS kcm_mobile_power DESTINATION ${PLUGIN_INSTALL_DIR}/kcms)

kpackage_install_package(package kcm_mobile_power kcms)
