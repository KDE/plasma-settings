/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "modulesmodel.h"

#include <QQuickItem>
#include <QSet>

#include <KPackage/PackageLoader>
#include <KPluginFactory>
#include <KPluginMetaData>

#include <KDeclarative/KDeclarative>

#include <QDebug>

ModulesModel::ModulesModel(QObject *parent)
    : QAbstractListModel(parent)
{
    qDebug() << "Current platform is " << KDeclarative::KDeclarative::runtimePlatform();
    const auto packages = KPackage::PackageLoader::self()->listPackages(QString(), "kpackage/kcms/");
    for (const KPluginMetaData &pluginMetaData : packages) {
        bool isCurrentPlatform = false;
        if (KDeclarative::KDeclarative::runtimePlatform().isEmpty()) {
            isCurrentPlatform = true;
        } else {
            const auto platforms = KDeclarative::KDeclarative::runtimePlatform();
            for (const QString &platform : platforms) {
                if (pluginMetaData.formFactors().contains(platform)) {
                    qDebug() << "Platform for " << pluginMetaData.name() << " is " << pluginMetaData.formFactors();
                    isCurrentPlatform = true;
                }
            }
        }
        if (isCurrentPlatform) {
            Data d;
            d.plugin = pluginMetaData;
            m_plugins.append(d);
        }
    }
    std::sort(m_plugins.begin(), m_plugins.end(), std::less<Data>());
}

QVariant ModulesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount()) {
        return {};
    }

    // NOTE: as the kcm is lazy loading, this needs to not be const
    // a cleaner alternative, would be a ConfigModule *loadKcm(pluginId) method, which also wouldn't risk erroneous kcm instantiation when it shouldn't
    Data &d = const_cast<ModulesModel *>(this)->m_plugins[index.row()];

    switch (role) {
    case NameRole:
        return d.plugin.name();
    case DescriptionRole:
        return d.plugin.description();
    case IconNameRole:
        return d.plugin.iconName();
    case IdRole:
        return d.plugin.pluginId();
    case KcmRole: {
        if (!d.kcm) {
            d.kcm = instantiateKcm(d.plugin.pluginId());
        }

        return QVariant::fromValue(d.kcm.data());
    }
    }

    return {};
}

int ModulesModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_plugins.size();
}

QHash<int, QByteArray> ModulesModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {DescriptionRole, "description"},
        {IconNameRole, "iconName"},
        {IdRole, "id"},
        {KcmRole, "kcm"},
    };
}

KQuickAddons::ConfigModule *ModulesModel::instantiateKcm(const QString &name) const
{
    KPluginMetaData metaData(QLatin1String("kcms/") + name);

    KQuickAddons::ConfigModule *kcm = nullptr;

    /* connect(qApp, &QCoreApplication::aboutToQuit, this, [this, kcm](){
         QQuickItem *ui = kcm->mainUi();
         if (ui) {
             ui->setParentItem(nullptr);
         }
     });*/
    auto result = KPluginFactory::instantiatePlugin<KQuickAddons::ConfigModule>(metaData, const_cast<ModulesModel *>(this));
    if (!result) {
        qWarning() << "Error loading KCM plugin:" << result.errorString;
    } else {
        kcm = result.plugin;
    }
    return kcm;
}
