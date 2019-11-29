#include "modulesmodel.h"

#include <QSet>
#include <QQuickItem>

#include <KPackage/PackageLoader>
#include <KPluginLoader>
#include <KPluginFactory>

#include <KDeclarative/KDeclarative>

#include <QDebug>

ModulesModel::ModulesModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_plugins()
{
    qDebug() << "Current platform is " << KDeclarative::KDeclarative::runtimePlatform();
    for (KPluginMetaData pluginMetaData : KPackage::PackageLoader::self()->listPackages(QString(), "kpackage/kcms/")) {
        KPackage::Package package = KPackage::PackageLoader::self()->loadPackage(QStringLiteral("KPackage/GenericQML"));
        package.setDefaultPackageRoot("kpackage/kcms");
        package.setPath(pluginMetaData.pluginId());
        bool isCurrentPlatform = false;
        if (KDeclarative::KDeclarative::runtimePlatform().isEmpty()) {
            isCurrentPlatform = true;
        } else {
            for (QString platform : KDeclarative::KDeclarative::runtimePlatform()) {
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
}

QVariant ModulesModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()
        || index.row() < 0
        || index.row() >= rowCount())
    {
        return QVariant();
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
        case KcmRole: {

            if(!d.kcm) {
                d.kcm = instantiateKcm(d.plugin.pluginId());
            }

            return QVariant::fromValue(d.kcm.data());
        }
        default:
             return QVariant();
    }
}

int ModulesModel::rowCount(const QModelIndex& parent) const
{
    return parent.isValid() ? 0 : m_plugins.size();
}

QHash<int, QByteArray> ModulesModel::roleNames() const
{
    QHash<int, QByteArray> names = QAbstractItemModel::roleNames();
    names.insert(NameRole, "name");
    names.insert(DescriptionRole, "description");
    names.insert(IconNameRole, "iconName");
    names.insert(KcmRole, "kcm");
    return names;
}

KQuickAddons::ConfigModule * ModulesModel::instantiateKcm(const QString name) const
{
    const QString pluginPath = KPluginLoader::findPlugin(QLatin1String("kcms/") + name);

    KPluginLoader loader(pluginPath);
    KPluginFactory* factory = loader.factory();

    KQuickAddons::ConfigModule *kcm = nullptr;

    if (!factory) {
        qWarning() << "Error loading KCM plugin:" << loader.errorString();
    } else {
        kcm = factory->create<KQuickAddons::ConfigModule >();
        if (!kcm) {
            qWarning() << "Error creating object from plugin" << loader.fileName();
        }
    }
    return kcm;
}

