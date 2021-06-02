// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#ifndef MOBILEPOWER_H
#define MOBILEPOWER_H

#include <KQuickAddons/ConfigModule>
#include <memory>

class MobilePower : public KQuickAddons::ConfigModule
{
    Q_OBJECT
    Q_PROPERTY(bool lockScreen READ lockScreen WRITE setLockScreen NOTIFY lockScreenChanged)
    Q_PROPERTY(qreal suspendSessionTime READ suspendSessionTime WRITE setLockScreenTime NOTIFY suspendSessionTimeChanged)
    Q_PROPERTY(bool sleepScreen READ sleepScreen WRITE setSleepScreen NOTIFY sleepScreenChanged)
    Q_PROPERTY(qreal sleepScreenTime READ sleepScreenTime WRITE setSleepScreenTime NOTIFY sleepScreenTimeChanged)
    Q_PROPERTY(int sleepScreenIdx READ sleepScreenIdx WRITE setSleepScreenIdx NOTIFY sleepScreenIdxChanged)
    Q_PROPERTY(int suspendSessionIdx READ suspendSessionIdx WRITE setLockScreenIdx NOTIFY suspendSessionIdxChanged)

public:
    MobilePower(QObject *parent, const QVariantList &args);
    ~MobilePower();

    Q_INVOKABLE QStringList timeOptions() const;
    Q_INVOKABLE void setLockScreenIdx(int idx);
    Q_INVOKABLE void setSleepScreenIdx(int idx);
    int sleepScreenIdx();
    int suspendSessionIdx();
    Q_SIGNAL void sleepScreenIdxChanged();
    Q_SIGNAL void suspendSessionIdxChanged();

    QString stringForValue(int value);

    bool lockScreen() const;
    Q_SLOT void setLockScreen(bool value);
    Q_SIGNAL void lockScreenChanged(bool value);

    qreal suspendSessionTime() const;
    Q_SLOT void setLockScreenTime(double value);
    Q_SIGNAL void suspendSessionTimeChanged(double value);

    bool sleepScreen() const;
    Q_SLOT void setSleepScreen(bool value);
    Q_SIGNAL void sleepScreenChanged(bool value);

    qreal sleepScreenTime() const;
    Q_SLOT void setSleepScreenTime(double value);
    Q_SIGNAL void sleepScreenTimeChanged(double value);

    void load() override;
    void save() override;

private:
    struct Private;
    std::unique_ptr<Private> d;
};

#endif
