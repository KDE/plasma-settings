/***************************************************************************
 *                                                                         *
 *   Copyright 2011 Sebastian Kügler <sebas@kde.org>                       *
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

#include "settingsmodulesmodel.h"

#include <QQmlContext>
#include <QQmlEngine>
#include <QTimer>

#include <KPackage/PackageLoader>
#include <KPluginInfo>
#include <KService>
#include <KServiceTypeTrader>
#include <KSharedConfig>
#include <KPluginMetaData>

#include <QDebug>

class SettingsModulesModelPrivate {

public:
    SettingsModulesModelPrivate(SettingsModulesModel *parent)
        : populateTimer(new QTimer(parent))
    {}

    QList<SettingsModule*> settingsModules;
    QTimer *populateTimer;
    QString appName;
    QString formFactor;
};


SettingsModulesModel::SettingsModulesModel(QQmlComponent *parent)
    : QQmlComponent(parent),
      d(new SettingsModulesModelPrivate(this))
{
    qDebug() << "Creating SettingsModel";
    d->populateTimer->setInterval(0);
    d->populateTimer->setSingleShot(true);
    connect(d->populateTimer, &QTimer::timeout, this, &SettingsModulesModel::populate);
    d->populateTimer->start();
    connect(this, &SettingsModulesModel::formFactorChanged, this, &SettingsModulesModel::populate);
}

SettingsModulesModel::~SettingsModulesModel()
{
    delete d;
}

QQmlListProperty<SettingsModule> SettingsModulesModel::settingsModules()
{
    return QQmlListProperty<SettingsModule>(this, d->settingsModules);
}

QString SettingsModulesModel::application() const
{
    return d->appName;
}

void SettingsModulesModel::setApplication(const QString &appName)
{
    qDebug() << "setting application to" << appName;
    if (d->appName != appName) {
        d->appName = appName;
        for (auto m: d->settingsModules) {
            m->deleteLater();
        }
        d->settingsModules.clear();
        emit applicationChanged();
        emit settingsModulesChanged();
        d->populateTimer->start();
    }
}

bool compareModules(const SettingsModule *l, const SettingsModule *r)
{
    if (l == r) {
        return false;
    }

    if (!l) {
        return false;
    } else if (!r) {
        return true;
    }

    // base it on the category weighting; if neither has a category weight the compare
    // strings
    KConfigGroup orderConfig(KSharedConfig::openConfig(), "SettingsCategoryWeights");
    const int lG = orderConfig.readEntry(l->category(), -1);
    const int rG = orderConfig.readEntry(r->category(), -1);
    //qDebug() << l->name() << l->category() << lG << " vs " << r->name() << r->category() << rG;

    if (lG < 0) {
        if (rG > 0) {
            return false;
        }

        int rv = l->category().compare(r->category(), Qt::CaseInsensitive);
        if (rv == 0) {
            rv = l->name().compare(r->name(), Qt::CaseInsensitive);
        }
        return rv < 0;
    } else if (rG < 0) {
        return true;
    }

    if (lG == rG) {
        return l->name().compare(r->name(), Qt::CaseInsensitive) < 0;
    }

    return lG > rG;
}

void SettingsModulesModel::populate()
{
    for (auto m: d->settingsModules) {
        m->deleteLater();
    }
    d->settingsModules.clear();

    QString constraint;
    if (d->appName.isEmpty()) {
        constraint.append("not exist [X-KDE-ParentApp]");
    } else {
        constraint.append("[X-KDE-ParentApp] == '").append(d->appName).append("'");
    }

    KService::List services = KServiceTypeTrader::self()->query("Active/SettingsModule", constraint);
    QSet<QString> seen;
    //qDebug() << "Found " << services.count() << " modules";
    foreach (const KService::Ptr &service, services) {
        if (service->noDisplay()) {
            continue;
        }

        KPluginInfo info(service);
        if (seen.contains(info.pluginName())) {
            continue;
        }

        seen.insert(info.pluginName());
        QString description;
        if (!service->genericName().isEmpty() && service->genericName() != service->name()) {
            description = service->genericName();
        } else if (!service->comment().isEmpty()) {
            description = service->comment();
        }

        // Filter out modules that are not explicitely suitable for the "handset" formfactor

        auto kp = info.toMetaData().rawData()["KPlugin"].toObject();
        QStringList formFactors = KPluginMetaData::readStringList(kp, QStringLiteral("FormFactors"));
        if (!formFactor().isEmpty() && !formFactors.contains(formFactor())) {
            continue;
        }

        SettingsModule* item = new SettingsModule(this);

        item->setName(service->name());
        item->setDescription(description);
        item->setIconName(service->icon());
        item->setModule(info.pluginName());
        item->setCategory(info.category());
        d->settingsModules.append(item);
    }

    auto plugins = KPluginLoader::findPlugins("kcms");

    for (auto plugin : KPackage::PackageLoader::self()->listPackages(QStringLiteral("Active/SettingsModule"), "kpackage/kcms/")) {
        plugins << plugin;
    }

    for (auto plugin : plugins) {
        if (seen.contains(plugin.pluginId())) {
            continue;
        }


        // Filter out modules that are not explicitely suitable for the "handset" formfactor
        auto kp = plugin.rawData()["KPlugin"].toObject();
        QStringList formFactors = KPluginMetaData::readStringList(kp, QStringLiteral("FormFactors"));
        if (!formFactor().isEmpty() && !formFactors.contains(formFactor())) {
            continue;
        }

        qDebug() << "Formafactors;" << plugin.pluginId() << formFactors;
        SettingsModule* item = new SettingsModule(this);

        item->setName(plugin.name());
        item->setDescription(plugin.description());
        item->setIconName(plugin.iconName());
        item->setModule(plugin.pluginId());
        item->setCategory(plugin.category());
        d->settingsModules.append(item);
        seen.insert(plugin.pluginId());
    }

    qStableSort(d->settingsModules.begin(), d->settingsModules.end(), compareModules);
    //emit dataChanged();
    emit settingsModulesChanged();
}

QString SettingsModulesModel::formFactor() const
{
    return d->formFactor;
}

void SettingsModulesModel::setFormFactor(const QString& f)
{
    if (d->formFactor != f) {
        d->formFactor = f;
        emit formFactorChanged();
    }
}

#include "settingsmodulesmodel.moc"
