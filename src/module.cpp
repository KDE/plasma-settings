/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "module.h"

#include <KPluginFactory>
#include <KPluginMetaData>

KQuickAddons::ConfigModule *Module::kcm() const
{
    return m_kcm;
}

QString Module::name() const
{
    return m_name;
}

void Module::setName(const QString &name)
{
    if (m_name == name) {
        return;
    }

    KPluginMetaData metaData(QLatin1String("kcms/") + name);
    if (!metaData.isValid()) {
        qWarning() << "failed to find plugin:" << name;
        return;
    }

    m_name = name;
    Q_EMIT nameChanged();

    auto result = KPluginFactory::instantiatePlugin<KQuickAddons::ConfigModule>(metaData);
    if (!result) {
        qWarning() << "Error loading KCM plugin:" << result.errorString;
    } else {
        m_kcm = result.plugin;
    }

    Q_EMIT kcmChanged();
}
