/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QAbstractListModel>
#include <QVector>

#include <KPluginMetaData>
#include <KQuickConfigModule>

#include "menuitem.h"

class ModulesModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ModelRoles {
        NameRole = Qt::DisplayRole,
        IconNameRole = Qt::DecorationRole,
        MenuItemRole = Qt::UserRole,
        DescriptionRole = Qt::UserRole + 1,
        IdRole = Qt::UserRole + 2,
        IsCategoryRole,
        IsKCMRole,

        /**
         * Role used to request the keywords to filter the items when searching.
         */
        UserFilterRole,

        /**
         * Role used to request the weight of a module, used to sort the items.
         */
        UserSortRole,
    };

public:
    ModulesModel(QObject *parent = nullptr);

    QVariant data(const QModelIndex &index, int role) const override;

    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;

    QHash<int, QByteArray> roleNames() const override;

    void addException(MenuItem *exception);
    void removeException(MenuItem *exception);

    MenuItem *rootItem() const;
    QList<MenuItem *> childrenList(MenuItem *parent) const;

private:
    void initMenuList(MenuItem *parent, const QList<KPluginMetaData> &kcms, const QStringList &categories);

    MenuItem *parentItem(MenuItem *child) const;

    MenuItem *m_rootModule{nullptr};
    QList<MenuItem *> m_exceptions;
    // QVector<MenuItem> m_plugins;
};
