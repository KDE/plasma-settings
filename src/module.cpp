/***************************************************************************
 *                                                                         *
 *   Copyright 2019 Nicolas Fella <nicolas.fella@gmx.de>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
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
