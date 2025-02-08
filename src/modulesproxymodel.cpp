/*
 * SPDX-FileCopyrightText: 2009 Ben Cooksley <bcooksley@kde.org>
 * SPDX-FileCopyrightText: 2007 Will Stephenson <wstephenson@kde.org>
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "modulesproxymodel.h"

ModulesProxyModel::ModulesProxyModel(QObject *parent)
    : KCategorizedSortFilterProxyModel{parent}
{
    setSortRole(ModulesModel::UserSortRole);
    setFilterRole(ModulesModel::UserFilterRole);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
}

QHash<int, QByteArray> ModulesProxyModel::roleNames() const
{
    QHash<int, QByteArray> names = KCategorizedSortFilterProxyModel::roleNames();
    names[KCategorizedSortFilterProxyModel::CategoryDisplayRole] = "categoryDisplayRole";
    return names;
}

QString ModulesProxyModel::filterString() const
{
    return m_filterString;
}

void ModulesProxyModel::setFilterString(QString filterString)
{
    if (filterString != m_filterString) {
        m_filterString = filterString;
        KCategorizedSortFilterProxyModel::setFilterRegularExpression(QStringLiteral(".*") + m_filterString + QStringLiteral(".*"));
        Q_EMIT filterStringChanged();
    }
}

bool ModulesProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &parent) const
{
    if (!m_filterHighlightsEntries) {
        // Don't show empty categories
        QModelIndex index = sourceModel()->index(sourceRow, 0, parent);
        auto mItem = index.data(Qt::UserRole).value<MenuItem *>();
        if (mItem && mItem->menu() && mItem->children().isEmpty()) {
            return false;
        }

        return KCategorizedSortFilterProxyModel::filterAcceptsRow(sourceRow, parent);
    }

    QModelIndex index = sourceModel()->index(sourceRow, 0, parent);
    auto mItem = index.data(Qt::UserRole).value<MenuItem *>();

    // accept only systemsettings categories that have children
    if (mItem->children().isEmpty() && mItem->isSystemsettingsCategory()) {
        return false;
    } else {
        return true; // Items matching the regexp are disabled, not hidden
    }
}

Qt::ItemFlags ModulesProxyModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }

    QString matchText = index.data(ModulesModel::UserFilterRole).toString();
    QRegularExpression pattern = KCategorizedSortFilterProxyModel::filterRegularExpression();

    if (!matchText.contains(pattern)) {
        return Qt::NoItemFlags;
    } else {
        return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
    }
}

bool ModulesProxyModel::lessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (isCategorizedModel()) {
        return KCategorizedSortFilterProxyModel::lessThan(left, right);
    }

    QVariant leftWeight = left.data(ModulesModel::UserSortRole);
    QVariant rightWeight = right.data(ModulesModel::UserSortRole);

    if (leftWeight.toInt() == rightWeight.toInt()) {
        return left.data().toString() < right.data().toString();
    }

    return leftWeight.toInt() < rightWeight.toInt();
}

bool ModulesProxyModel::subSortLessThan(const QModelIndex &left, const QModelIndex &right) const
{
    if (isCategorizedModel()) {
        QVariant leftWeight = left.data(ModulesModel::UserSortRole);
        QVariant rightWeight = right.data(ModulesModel::UserSortRole);

        if (!leftWeight.isValid() || !rightWeight.isValid()) {
            return KCategorizedSortFilterProxyModel::subSortLessThan(left, right);
        } else {
            if (leftWeight.toInt() == rightWeight.toInt()) {
                return left.data().toString() < right.data().toString();
            } else {
                return leftWeight.toInt() < rightWeight.toInt();
            }
        }
    }
    return KCategorizedSortFilterProxyModel::subSortLessThan(left, right);
}

void ModulesProxyModel::setFilterHighlightsEntries(bool highlight)
{
    m_filterHighlightsEntries = highlight;
}

bool ModulesProxyModel::filterHighlightsEntries() const
{
    return m_filterHighlightsEntries;
}
