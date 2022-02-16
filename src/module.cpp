/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "module.h"

#include <KPluginFactory>
#include <QQmlContext>
#include <QQuickItem>

KQuickAddons::ConfigModule *Module::kcm() const
{
    return m_kcm;
}

QString Module::path() const
{
    return m_path;
}

void Module::setPath(const QString &path)
{
    if (m_path == path) {
        return;
    }

    // In case the user clicks from the UI we pass in the absolute path
    KPluginMetaData kcmMetaData(path);
    if (!kcmMetaData.isValid()) {
        // From the command line or DBus we usually get only the plugin id
        if (KPluginMetaData data(QStringLiteral("plasma/kcms/systemsettings/") + path); data.isValid()) {
            kcmMetaData = data;
        } else if (KPluginMetaData data(QStringLiteral("kcms/") + path); data.isValid()) {
            // Also check the old "kcms" namespace
            // TODO KF6 remove this branch of the if statement
            kcmMetaData = data;
        }
    }

    if (kcmMetaData.isValid()) {
        m_path = kcmMetaData.fileName();
        Q_EMIT pathChanged();

        m_kcm = KPluginFactory::instantiatePlugin<KQuickAddons::ConfigModule>(kcmMetaData, this).plugin;
        QQmlEngine::setContextForObject(m_kcm, new QQmlContext(QQmlEngine::contextForObject(this)->parentContext(), m_kcm));
        Q_EMIT kcmChanged();
    } else {
        qWarning() << "Unknown module" << path << "requested";
    }
}
