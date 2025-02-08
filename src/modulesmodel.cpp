/*
    SPDX-FileCopyrightText: 2009 Ben Cooksley <bcooksley@kde.org>
    SPDX-FileCopyrightText: 2007 Will Stephenson <wstephenson@kde.org>
    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "modulesmodel.h"

#include <QDebug>
#include <QQuickItem>
#include <QSet>
#include <QStandardPaths>

#include <KCategorizedSortFilterProxyModel>
#include <KConfigGroup>
#include <KDesktopFile>
#include <KFileUtils>
#include <KJsonUtils>
#include <KPluginFactory>
#include <KRuntimePlatform>

using namespace Qt::Literals::StringLiterals;

ModulesModel::ModulesModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_rootModule{new MenuItem{true, nullptr}}
{
    qDebug() << "Current platform is " << KRuntimePlatform::runtimePlatform();
    auto kcms = KPluginMetaData::findPlugins(u"kcms"_s)
        << KPluginMetaData::findPlugins(u"plasma/kcms"_s) << KPluginMetaData::findPlugins(u"plasma/kcms/systemsettings"_s);

    QList<KPluginMetaData> filteredKcms;
    // Filter to if kcm belongs to the current platform
    for (const KPluginMetaData &pluginMetaData : kcms) {
        bool isCurrentPlatform = false;

        if (KRuntimePlatform::runtimePlatform().isEmpty()) {
            isCurrentPlatform = true;
        } else {
            const auto platforms = KRuntimePlatform::runtimePlatform();
            for (const QString &platform : platforms) {
                if (pluginMetaData.formFactors().contains(platform)) {
                    qDebug() << "Platform for " << pluginMetaData.name() << " is " << pluginMetaData.formFactors();
                    isCurrentPlatform = true;
                }
            }
        }

        if (isCurrentPlatform) {
            filteredKcms.append(pluginMetaData);
        }
    }

    const QStringList dirs = QStandardPaths::locateAll(QStandardPaths::AppDataLocation, QStringLiteral("categories"), QStandardPaths::LocateDirectory);
    QStringList categories = KFileUtils::findAllUniqueFiles(dirs, QStringList(QStringLiteral("*.desktop")));

    initMenuList(m_rootModule, filteredKcms, categories);
}

void ModulesModel::initMenuList(MenuItem *parent, const QList<KPluginMetaData> &kcms, const QStringList &categories)
{
    // look for any categories inside this level, and recurse into them
    for (const QString &category : std::as_const(categories)) {
        const KDesktopFile file(category);
        const KConfigGroup entry = file.desktopGroup();
        QString parentCategory = entry.readEntry("X-KDE-System-Settings-Parent-Category");
        QString parentCategory2 = entry.readEntry("X-KDE-System-Settings-Parent-Category-V2");

        if (parentCategory == parent->category() ||
            // V2 entries must not be empty if they want to become a proper category.
            (!parentCategory2.isEmpty() && parentCategory2 == parent->category())) {
            auto menuItem = new MenuItem(true, parent);
            menuItem->setCategoryConfig(file);
            if (entry.readEntry("X-KDE-System-Settings-Category") == QLatin1String("lost-and-found")) {
                // Skip lost and found for now
                continue;
            }
            initMenuList(menuItem, kcms, categories);
        }
    }

    // scan for any modules at this level and add them
    for (const auto &metaData : std::as_const(kcms)) {
        QString category = metaData.value(QStringLiteral("X-KDE-System-Settings-Parent-Category"));
        QString categoryv2 = metaData.value(QStringLiteral("X-KDE-System-Settings-Parent-Category-V2"));
        const QString parentCategoryKcm = parent->systemsettingsCategoryModule();
        bool isCategoryOwner = false;

        if (!parentCategoryKcm.isEmpty() && parentCategoryKcm == metaData.pluginId()) {
            parent->setMetaData(metaData);
            isCategoryOwner = true;
        }

        if (!parent->category().isEmpty() && (category == parent->category() || categoryv2 == parent->category())) {
            if (!metaData.isHidden()) {
                // Add the module info to the menu
                auto infoItem = new MenuItem(false, parent);
                infoItem->setMetaData(metaData);
                infoItem->setCategoryOwner(isCategoryOwner);
            }
        }
    }

    parent->sortChildrenByWeight();
}

QVariant ModulesModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount()) {
        return {};
    }

    auto mi = static_cast<MenuItem *>(index.internalPointer());

    switch (role) {
    case MenuItemRole:
        return QVariant::fromValue(mi);
    case NameRole:
        return mi->name();
    case DescriptionRole:
        return mi->description();
    case IconNameRole:
        return mi->iconName();
    case IdRole:
        return mi->id();
    case UserFilterRole:
        // We join by ZERO WIDTH SPACE to avoid awkward word merging in search terms
        // e.g. ['keys', 'slow'] should match 'keys' and 'slow' but not 'ssl'.
        // https://bugs.kde.org/show_bug.cgi?id=487855
        return mi->keywords().join(u"\u200B"_s);
        break;
    case UserSortRole:
        // Category owners are always before everything else, regardless of weight
        if (mi->isCategoryOwner()) {
            return QStringLiteral("%1").arg(QString::number(mi->weight()), 5, QLatin1Char('0'));
        } else {
            return QStringLiteral("1%1").arg(QString::number(mi->weight()), 5, QLatin1Char('0'));
        }
        break;
    case KCategorizedSortFilterProxyModel::CategorySortRole:
        if (mi->parent()) {
            return QStringLiteral("%1%2").arg(QString::number(mi->parent()->weight()), 5, QLatin1Char('0')).arg(mi->parent()->name());
        }
        break;
    case KCategorizedSortFilterProxyModel::CategoryDisplayRole: {
        MenuItem *candidate = mi->parent();
        // The model has an invisible single root item.
        // So to get the "root category" we don't go up all the way
        // To the actual root, but to the list of the first childs.
        // That's why we check for candidate->parent()->parent()
        while (candidate && candidate->parent() && candidate->parent()->parent()) {
            candidate = candidate->parent();
        }
        if (candidate) {
            // Children of this special root category don't have an user visible category
            if (!candidate->isSystemsettingsRootCategory()) {
                return candidate->name();
            }
        }
        break;
    }
    case IsCategoryRole:
        return mi->menu();
    case IsKCMRole:
        return mi->isLibrary();
    }

    return {};
}

int ModulesModel::columnCount(const QModelIndex & /*parent*/) const
{
    return 1;
}

int ModulesModel::rowCount(const QModelIndex &parent) const
{
    MenuItem *mi;
    if (parent.isValid()) {
        mi = static_cast<MenuItem *>(parent.internalPointer());
    } else {
        mi = m_rootModule;
    }
    return childrenList(mi).count();
}

QHash<int, QByteArray> ModulesModel::roleNames() const
{
    QHash<int, QByteArray> names = QAbstractItemModel::roleNames();
    names[NameRole] = "name";
    names[DescriptionRole] = "description";
    names[IconNameRole] = "iconName";
    names[IdRole] = "pluginId";
    names[IsCategoryRole] = "isCategory";
    names[IsKCMRole] = "isKCM";
    return names;
}

Qt::ItemFlags ModulesModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }

    return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QModelIndex ModulesModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent)) {
        return {};
    }

    MenuItem *parentItem;
    if (!parent.isValid()) {
        parentItem = m_rootModule;
    } else {
        parentItem = static_cast<MenuItem *>(parent.internalPointer());
    }

    MenuItem *childItem = childrenList(parentItem).value(row);
    if (childItem) {
        return createIndex(row, column, childItem);
    } else {
        return {};
    }
}

QModelIndex ModulesModel::parent(const QModelIndex &index) const
{
    auto childItem = static_cast<MenuItem *>(index.internalPointer());
    if (!childItem) {
        return {};
    }

    MenuItem *parent = parentItem(childItem);
    MenuItem *grandParent = parentItem(parent);

    int childRow = 0;
    if (grandParent) {
        childRow = childrenList(grandParent).indexOf(parent);
    }

    if (parent == m_rootModule) {
        return {};
    }
    return createIndex(childRow, 0, parent);
}

QList<MenuItem *> ModulesModel::childrenList(MenuItem *parent) const
{
    QList<MenuItem *> children = parent->children();
    for (MenuItem *child : children) {
        if (m_exceptions.contains(child)) {
            children.removeOne(child);
            children.append(child->children());
        }
    }
    return children;
}

MenuItem *ModulesModel::parentItem(MenuItem *child) const
{
    MenuItem *parent = child->parent();
    if (m_exceptions.contains(parent)) {
        parent = parentItem(parent);
    }
    return parent;
}

void ModulesModel::addException(MenuItem *exception)
{
    if (exception == m_rootModule) {
        return;
    }
    m_exceptions.append(exception);
}

void ModulesModel::removeException(MenuItem *exception)
{
    m_exceptions.removeAll(exception);
}

MenuItem *ModulesModel::rootItem() const
{
    return m_rootModule;
}
