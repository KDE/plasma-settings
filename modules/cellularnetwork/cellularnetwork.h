/*
 * SPDX-FileCopyrightText: 2020 Dimitris Kardarakos <dimkard@posteo.net>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include <KQuickAddons/ConfigModule>

#ifndef CELLULALNETWORK_H
#define CELLULALNETWORK_H

class CellularNetwork : public KQuickAddons::ConfigModule
{
    Q_OBJECT

public:
    CellularNetwork(QObject *parent, const QVariantList &args);
};

#endif
