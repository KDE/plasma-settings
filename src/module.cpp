/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>                   *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 ***************************************************************************/

#include "module.h"

#include <KPluginFactory>

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

    m_name = name;
    Q_EMIT nameChanged();

    const auto plugin = KPluginMetaData::findPluginById(QLatin1String("kcms/"), name);
    auto module = KPluginFactory::instantiatePlugin<KQuickAddons::ConfigModule>(plugin, this);

    if (!module) {
        qWarning() << "Error loading KCM plugin:" << module.errorString;
    } else {
        m_kcm = module.plugin;
        if (!m_kcm) {
            qWarning() << "Error creating object from plugin" << plugin.fileName();
        }
    }

    Q_EMIT kcmChanged();
}
