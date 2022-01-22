// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#ifndef MOBILEPOWER_H
#define MOBILEPOWER_H

#include <KQuickAddons/ConfigModule>
#include <memory>

class MobilePower : public KQuickAddons::ConfigModule
{
    Q_OBJECT
    Q_PROPERTY(int dimScreenIdx READ dimScreenIdx WRITE setDimScreenIdx NOTIFY dimScreenIdxChanged)
    Q_PROPERTY(int screenOffIdx READ screenOffIdx WRITE setScreenOffIdx NOTIFY screenOffIdxChanged)
    Q_PROPERTY(int suspendSessionIdx READ suspendSessionIdx WRITE setSuspendSessionIdx NOTIFY suspendSessionIdxChanged)

public:
    MobilePower(QObject *parent, const QVariantList &args);
    ~MobilePower();

    Q_INVOKABLE QStringList timeOptions() const;

    void setDimScreenIdx(int idx);
    void setScreenOffIdx(int idx);
    void setSuspendSessionIdx(int idx);
    int dimScreenIdx();
    int screenOffIdx();
    int suspendSessionIdx();

    Q_SIGNAL void dimScreenIdxChanged();
    Q_SIGNAL void screenOffIdxChanged();
    Q_SIGNAL void suspendSessionIdxChanged();

    QString stringForValue(int value);

    void load() override;
    void save() override;

private:
    struct Private;
    std::unique_ptr<Private> d;
};

#endif
