/*

    SPDX-FileCopyrightText: 2019 Nicolas Fella <nicolas.fella@gmx.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <KQuickAddons/ConfigModule>
#include <QObject>

class Module : public QObject
{
    Q_OBJECT
    Q_PROPERTY(KQuickAddons::ConfigModule *kcm READ kcm NOTIFY kcmChanged)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)

public:
    KQuickAddons::ConfigModule *kcm() const;
    QString name() const;
    void setName(const QString &name);

Q_SIGNALS:
    void kcmChanged();
    void nameChanged();

private:
    KQuickAddons::ConfigModule *m_kcm = nullptr;
    QString m_name;
};
