#pragma once

#include <QAbstractListModel>
#include <QVector>

#include <KPluginMetaData>
#include <KPackage/Package>
#include <KQuickAddons/ConfigModule>

struct Data {
    KPluginMetaData plugin;
    QPointer<KQuickAddons::ConfigModule> kcm;
};

class ModulesModel : public QAbstractListModel
{
    Q_OBJECT

public:

    enum ModelRoles {
        NameRole = Qt::DisplayRole,
        IconNameRole = Qt::DecorationRole,
        DescriptionRole = Qt::UserRole + 1,
        KcmRole
    };

public:
    ModulesModel(QObject *parent=nullptr);

    QVariant data(const QModelIndex& index, int role) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    QHash<int, QByteArray> roleNames() const override;

private:
    KQuickAddons::ConfigModule* instantiateKcm(const QString name) const;

    QVector<Data> m_plugins;
};
