/*
 * SPDX-FileCopyrightText: 2009 Ben Cooksley <bcooksley@kde.org>
 * SPDX-FileCopyrightText: 2007 Will Stephenson <wstephenson@kde.org>
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <KCategorizedSortFilterProxyModel>

#include "modulesmodel.h"

class ModulesProxyModel : public KCategorizedSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)

public:
    ModulesProxyModel(QObject *parent = nullptr);

    QHash<int, QByteArray> roleNames() const override;

    QString filterString() const;
    void setFilterString(QString filterString);

    bool filterAcceptsRow(int sourceRow, const QModelIndex &parent) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    bool lessThan(const QModelIndex &left, const QModelIndex &right) const override;
    bool subSortLessThan(const QModelIndex &left, const QModelIndex &right) const override;

    void setFilterHighlightsEntries(bool highlight);
    bool filterHighlightsEntries() const;

Q_SIGNALS:
    void filterStringChanged();

private:
    QString m_filterString;
    bool m_filterHighlightsEntries{true};

    ModulesModel *m_model;
};
