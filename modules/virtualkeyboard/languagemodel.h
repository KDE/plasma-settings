/*
 * Copyright 2020  Bhushan Shah <bshah@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef LANGUAGEMODEL_H
#define LANGUAGEMODEL_H

#include "gsettingsitem.h"
#include <QAbstractListModel>

struct Data {
    QString langCode;
    QString langName;
    bool enabled;
};

class LanguageModel : public QAbstractListModel
{
    enum ModelRoles { NameRole = Qt::DisplayRole, EnabledRole = Qt::UserRole + 1, LanguageIdRole };

    Q_OBJECT
public:
    LanguageModel(QObject *parent, GSettingsItem *gsettingsItem);

    QVariant data(const QModelIndex &index, int role) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    QHash<int, QByteArray> roleNames() const override;

private:
    QVector<Data> m_languages;
    void loadPlugins();
    GSettingsItem *m_gsettings;
};

#endif
