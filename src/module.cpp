/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>                   *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 ***************************************************************************/

#include "module.h"

#include <KPluginFactory>
#include <KPluginLoader>

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

    const QString pluginPath = KPluginLoader::findPlugin(QLatin1String("kcms/") + name);

    KPluginLoader loader(pluginPath);
    KPluginFactory *factory = loader.factory();

    if (!factory) {
        qWarning() << "Error loading KCM plugin:" << loader.errorString();
    } else {
        m_kcm = factory->create<KQuickAddons::ConfigModule>(this);
        if (!m_kcm) {
            qWarning() << "Error creating object from plugin" << loader.fileName();
        }
    }

    Q_EMIT kcmChanged();
}
