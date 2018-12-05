/*
    Copyright 2011 Marco Martin <notmart@gmail.com>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

#include "settingscomponent.h"
#include "settingsmodule.h"

#include <QQmlEngine>
#include <QQmlComponent>

#include <QDebug>
#include <KPluginMetaData>
#include <KPluginLoader>
#include <KPluginFactory>
#include <kquickaddons/configmodule.h>

#include <KPackage/Package>
#include <KPackage/PackageLoader>

class SettingsComponentPrivate {

public:
    QString module;
    QString icon;
    SettingsModule *settingsModule;
    KQuickAddons::ConfigModule *kcm;
    bool valid : 1;
    KPackage::Package package;
};


SettingsComponent::SettingsComponent(QQuickItem *parent)
    : QQuickItem(parent)
{
    d = new SettingsComponentPrivate;
    d->package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("KPackage/GenericQML"));
    d->settingsModule = nullptr;
    d->kcm = nullptr;
    d->valid = false;
}

SettingsComponent::~SettingsComponent()
{
}

void SettingsComponent::loadModule(const QString &name)
{
    d->settingsModule->deleteLater();
    d->settingsModule = nullptr;
    d->kcm->deleteLater();
    d->kcm = nullptr;

    d->package.setPath(name);
    //KGlobal::locale()->insertCatalog("plasma_package_" + name);
#warning "Re-enable translation catalog, port insertCatalog"
    QString pluginName = name;
    QString query;
    if (pluginName.isEmpty()) {
        qDebug() << "Not loading plugin ..." << pluginName;
        return;
    }

    const QString plugin = KPluginLoader::findPlugin(QLatin1String("kcms/") + name);

    KPackage::Package package = KPackage::PackageLoader::self()->loadPackage("KPackage/GenericQML");
    package.setDefaultPackageRoot("kpackage/kcms");
    package.setPath(name);
    KPluginMetaData info(package.metadata());

    //try pure QML mode
    if (plugin.isEmpty()) {
        d->kcm = new KQuickAddons::ConfigModule(info, this, QVariantList());
    } else {
        //qml-kcm mode
        KPluginLoader loader(plugin);

        KPluginFactory* factory = loader.factory();
        if (!factory) {
            qWarning() << "Error loading KCM plugin:" << loader.errorString();
            d->valid = false;
            emit validChanged();
            return;
        } else {
            d->kcm = factory->create<KQuickAddons::ConfigModule >();
            if (!d->kcm) {
                qWarning() << "Error creating object from plugin" << loader.fileName();
                d->valid = false;
                emit validChanged();
                return;
            }
        }
    }

    d->settingsModule = new SettingsModule(this);
    connect(d->settingsModule, &SettingsModule::nameChanged, this, &SettingsComponent::nameChanged);
    connect(d->settingsModule, &SettingsModule::descriptionChanged,
            this, &SettingsComponent::descriptionChanged);

    if (!d->kcm->mainUi()) {
        d->valid = false;
        emit validChanged();
        return;
    }

    d->kcm->mainUi()->setParentItem(this);

    {
        //set anchors
        QQmlExpression expr(QtQml::qmlContext(d->kcm->mainUi()), d->kcm->mainUi(), "parent");
        QQmlProperty prop(d->kcm->mainUi(), "anchors.fill");
        prop.write(expr.evaluate());
    }

    d->kcm->load();
    //instant apply
    connect(d->kcm, &KQuickAddons::ConfigModule::needsSaveChanged, [=]() {
        if (d->kcm->needsSave()) {
            d->kcm->save();
        }
    });

    d->settingsModule->setName(info.name());
    setIcon(info.iconName());
    d->settingsModule->setDescription(info.description());
    d->settingsModule->setModule(info.pluginId());
    d->valid = true;

    emit mainUiChanged();
    emit kcmChanged();
    emit validChanged();
}

QQuickItem *SettingsComponent::mainUi() const
{
    if (d->kcm) {
        return d->kcm->mainUi();
    }

    return nullptr;
}

KQuickAddons::ConfigModule *SettingsComponent::kcm() const
{
    return d->kcm;
}

bool SettingsComponent::isValid() const
{
    return d->valid;
}

QString SettingsComponent::description() const
{
    if (d->settingsModule) {    
        return d->settingsModule->description();
    }
    return QString();
}

void SettingsComponent::setDescription(const QString &description)
{
    if (d->settingsModule && d->settingsModule->description() != description) {
        d->settingsModule->setDescription(description);
        emit descriptionChanged();
    }
}

QString SettingsComponent::icon() const
{
    return d->icon;
}

void SettingsComponent::setIcon(const QString& name)
{
    if (name != d->icon) {
        d->icon = name;
        emit iconChanged();
    }
}


QString SettingsComponent::module() const
{
    return d->module;
}

void SettingsComponent::setModule(const QString &module)
{
    if (d->module != module) {
        d->module = module;
        loadModule(module);
        emit moduleChanged();
    }
}

QString SettingsComponent::name() const
{
    if (d->settingsModule) {
        return d->settingsModule->name();
    }
    return QString();
}

void SettingsComponent::setName(const QString &name)
{
    if (d->settingsModule && d->settingsModule->name() != name) {
        d->settingsModule->setName(name);
        emit nameChanged();
    }
}


#include "settingscomponent.moc"

