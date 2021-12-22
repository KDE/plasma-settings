/*
 * SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#pragma once

#include <QSortFilterProxyModel>

#include "modulesmodel.h"

class ModulesProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)

public:
    ModulesProxyModel(QObject *parent = nullptr);

    QString filterString() const;
    void setFilterString(QString filterString);

    bool filterAcceptsRow(int sourceRow, const QModelIndex &parent) const override;

Q_SIGNALS:
    void filterStringChanged();

private:
    QString m_filterString;

    ModulesModel *m_model;
};
