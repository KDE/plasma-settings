// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#ifndef MOBILEPOWER_H
#define MOBILEPOWER_H

#include <KQuickAddons/ConfigModule>
#include <memory>

class MobilePower : public KQuickAddons::ConfigModule
{
    Q_OBJECT
    Q_PROPERTY(qreal brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged)
    Q_PROPERTY(bool lockScreen READ lockScreen WRITE setLockScreen NOTIFY lockScreenChanged)
    Q_PROPERTY(int lockScreenTime READ lockScreenTime WRITE setLockScreenTime NOTIFY lockScreenTimeChanged)
    Q_PROPERTY(bool sleepScreen READ sleepScreen WRITE setSleepScreen NOTIFY sleepScreenChanged)
    Q_PROPERTY(int sleepScreenTime READ sleepScreenTime WRITE setSleepScreenTime NOTIFY sleepScreenTimeChanged)
    Q_PROPERTY(int sleepScreenIdx READ sleepScreenIdx WRITE setSleepScreenIdx NOTIFY sleepScreenIdxChanged)
    Q_PROPERTY(int lockScreenIdx READ lockScreenIdx WRITE setLockScreenIdx NOTIFY lockScreenIdxChanged)

public:
    MobilePower(QObject *parent,  const QVariantList &args);
    ~MobilePower();

    Q_INVOKABLE QStringList timeOptions() const;
    Q_INVOKABLE void setLockScreenIdx(int idx);
    Q_INVOKABLE void setSleepScreenIdx(int idx);
    int sleepScreenIdx();
    int lockScreenIdx();
    Q_SIGNAL void sleepScreenIdxChanged();
    Q_SIGNAL void lockScreenIdxChanged();

    QString stringForValue(int value);

    qreal brightness() const;
    Q_SLOT void setBrightness(qreal value);
    Q_SIGNAL void brightnessChanged(qreal value);

    bool lockScreen() const;
    Q_SLOT void setLockScreen(bool value);
    Q_SIGNAL void lockScreenChanged(bool value);

    int lockScreenTime() const;
    Q_SLOT void setLockScreenTime(int value);
    Q_SIGNAL void lockScreenTimeChanged(int value);

    bool sleepScreen() const;
    Q_SLOT void setSleepScreen(bool value);
    Q_SIGNAL void sleepScreenChanged(bool value);

    int sleepScreenTime() const;
    Q_SLOT void setSleepScreenTime(int value);
    Q_SIGNAL void sleepScreenTimeChanged(int value);

    void load() override;
    void save() override;

private:
    struct Private;
    std::unique_ptr<Private> d;
};

#endif
