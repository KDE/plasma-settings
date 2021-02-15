/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "cellularnetwork.h"
#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>

K_PLUGIN_CLASS_WITH_JSON(CellularNetwork, "cellularnetwork.json")

CellularNetwork::CellularNetwork(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
{
    KAboutData *about = new KAboutData("kcm_mobile_cellularnetwork", i18n("Cellular Networks"), "1.0", QString(), KAboutLicense::GPL);
    about->addAuthor(i18n("Dimitris Kardarakos"), QString(), "dimkard@posteo.net");
    setAboutData(about);

    qDebug() << "Cellular Networks module loaded";
}
#include "cellularnetwork.moc"
