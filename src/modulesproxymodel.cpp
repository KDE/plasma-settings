/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "modulesproxymodel.h"

ModulesProxyModel::ModulesProxyModel(QObject *parent)
    : QSortFilterProxyModel{parent}
    , m_model{new ModulesModel}
{
    setSourceModel(m_model);
    setSortRole(ModulesModel::NameRole);
    setFilterString(m_filterString);
    setRecursiveFilteringEnabled(true);
}

QString ModulesProxyModel::filterString() const
{
    return m_filterString;
}

void ModulesProxyModel::setFilterString(QString filterString)
{
    if (filterString != m_filterString) {
        m_filterString = filterString;
        setFilterRegExp({m_filterString});
        Q_EMIT filterStringChanged();
    }
}

bool ModulesProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &parent) const
{
    QString name = m_model->data(m_model->index(sourceRow, 0), ModulesModel::NameRole).toString();
    QString description = m_model->data(m_model->index(sourceRow, 0), ModulesModel::DescriptionRole).toString();
    QStringList keywords = m_model->data(m_model->index(sourceRow, 0), ModulesModel::KeywordsRole).toStringList();

    for (const QString &keyword : keywords) {
        if (keyword.contains(m_filterString, Qt::CaseInsensitive))
            return true;
    }
    return name.contains(m_filterString, Qt::CaseInsensitive) || description.contains(m_filterString, Qt::CaseInsensitive);
}
