// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#include "mobilepower.h"

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>
#include <KConfigGroup>

K_PLUGIN_CLASS_WITH_JSON(MobilePower, "powermanagement.json")

struct MobilePower::Private {
    qreal brightness;
    int lockScreenTime;
    int sleepScreenTime;
    bool lockScreen;
    bool sleepScreen;

    QStringList timeValues = {
        i18n("1 min"),
        i18n("2 min"),
        i18n("5 min"),
        i18n("10 min"),
        i18n("15 min"),
        i18n("Never"),
    };

    // Maps the indices of the timeValues indexes
    // to minutes.
    QMap<int, int> idxToMinutes= {
        {0, 1},
        {1, 2},
        {2, 5},
        {3, 10},
        {4, 15},
        {5, 0}
    };

    KSharedConfig::Ptr profilesConfig = KSharedConfig::openConfig("powermanagementprofilesrc", KConfig::SimpleConfig | KConfig::CascadeConfig);
};

MobilePower::MobilePower(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
    , d(std::make_unique<MobilePower::Private>())
{
    KAboutData *about = new KAboutData("kcm_mobile_power", i18n("Energy Settings"), "1.0", QString(), KAboutLicense::GPL);
    about->addAuthor(i18n("Tomaz Canabrava"), QString(), "tcanabrava@kde.org");
    setAboutData(about);
    setButtons(KQuickAddons::ConfigModule::NoAdditionalButton);
    load();
}

MobilePower::~MobilePower() = default;

qreal MobilePower::brightness() const
{
    return d->brightness;
}

void MobilePower::setBrightness(qreal value)
{
    if (d->brightness == value) {
        return;
    }
    d->brightness = value;
    Q_EMIT brightnessChanged(value);
    save();
}

bool MobilePower::lockScreen() const
{
    return d->lockScreen;
}

void MobilePower::setLockScreen(bool value)
{
    if (d->lockScreen == value) {
        return;
    }

    d->lockScreen = value;
    Q_EMIT lockScreenChanged(value);
    save();
}

int MobilePower::lockScreenTime() const
{
    return d->lockScreenTime;
}

void MobilePower::setLockScreenTime(int value)
{
    if (d->lockScreenTime == value) {
        return;
    }
    d->lockScreenTime = value;

    Q_EMIT lockScreenTimeChanged(value);
    save();
}

bool MobilePower::sleepScreen() const
{
    return d->sleepScreen;
}

void MobilePower::setSleepScreen(bool value)
{
    if (d->sleepScreen == value) {
        return;
    }
    d->sleepScreen = value;
    Q_EMIT sleepScreenChanged(value);
    save();
}

int MobilePower::sleepScreenTime() const
{
    return d->sleepScreenTime;
}

void MobilePower::setSleepScreenTime(int value)
{
    if (d->sleepScreenTime == value) {
        return;
    }
    d->sleepScreenTime = value;
    Q_EMIT sleepScreenTimeChanged(value);
    save();
}

// contents of powermanagementprofilesrc
//
// [Battery][SuspendSession] // our LockScreen
// idleTime=600000
// suspendThenHibernate = enabled / disabled.
// suspendType=1
// type 1 = sleep
// type 8 = shutdown
// type 32 = lock screen
//
// [Battery][DimDisplay] // our "Sleep Screen"
// idleTime=300000
// Aparently KDE removes this group when it's false.
//
// [Battery][BrigthnessControl]
// value = 30

void MobilePower::load()
{
    KConfigGroup batteryGroup = d->profilesConfig->group("Battery");

    if (batteryGroup.hasGroup("DimDisplay")) {
        qDebug() << "Group is valid";
        KConfigGroup dimSettings = batteryGroup.group("DimDisplay");
        d->sleepScreen = true;

        // powerdevil/dimdisplayconfig.cpp - here we load time / 60 / 1000
        // We should really, really, stop doing that.
        d->sleepScreenTime = (dimSettings.readEntry("idleTime").toInt() / 60) / 1000;
    } else {
        qDebug() << "Group is invalid, setting sleep screen to false";
        d->sleepScreen = false;
    }

    KConfigGroup lockScreenGroup = batteryGroup.group("SuspendSession");
    d->lockScreen = lockScreenGroup.readEntry<bool>("suspendThenHibernate", false);
    d->lockScreenTime = lockScreenGroup.readEntry<int>("idleTime", 300) / 60;

    KConfigGroup brigthnessGroup = batteryGroup.group("BrightnessControl");
    d->brightness = brigthnessGroup.readEntry<qreal>("value", 0.5) * 100;

    Q_EMIT brightnessChanged(d->brightness);
    Q_EMIT lockScreenChanged(d->lockScreen);
    Q_EMIT lockScreenTimeChanged(d->sleepScreenTime);
    Q_EMIT sleepScreenChanged(d->sleepScreen);
    Q_EMIT sleepScreenTimeChanged(d->sleepScreenTime);
    qDebug() << "Loaded the values" << d->lockScreen << d->sleepScreen;
}

void MobilePower::save()
{
    KConfigGroup batteryGroup = d->profilesConfig->group("Battery");
    if (!d->sleepScreen) {
        qDebug() << "Deleting the group DimDisplay";
        batteryGroup.deleteGroup("DimDisplay");
    } else {
        KConfigGroup dimDisplayGroup = batteryGroup.group("DimDisplay");

        // powerdevil/dimdisplayconfig.cpp - here we store time * 60 * 1000
        // We should really, really, stop doing that.
        dimDisplayGroup.writeEntry("idleTime", d->sleepScreenTime * 60 * 1000);
    }

    KConfigGroup lockScreenGroup = batteryGroup.group("SuspendSession");
    lockScreenGroup.writeEntry<bool>("suspendThenHibernate", d->lockScreen);
    lockScreenGroup.writeEntry("idleTime", d->lockScreenTime * 60);
    lockScreenGroup.writeEntry("suspendType", 32); // always lock screen.

    KConfigGroup brigthnessGroup = batteryGroup.group("BrightnessControl");
    brigthnessGroup.writeEntry("value", d->brightness / 100);

    qDebug() << "Loaded the values" << d->lockScreen << d->sleepScreen;
}

QStringList MobilePower::timeOptions() const
{
    return d->timeValues;
}

void MobilePower::setLockScreenIdx(int idx)
{
    int value = d->idxToMinutes.value(idx);
    qDebug() << "Got the value" << value;

    if (value == 0) {
        if (!d->lockScreen) {
            return;
        }
        qDebug() << "Setting to never lock";

        d->lockScreen = false;
    } else {
        d->lockScreen = true;
        if (d->lockScreenTime == value) {
            return;
        }
        d->lockScreenTime = value;
        qDebug() << "SEtting to lock in " << value << "Minutes";

    }
    Q_EMIT lockScreenIdxChanged();
    save();
}

void MobilePower::setSleepScreenIdx(int idx)
{
    int value = d->idxToMinutes.value(idx);
    qDebug() << "Got the value" << value;
    if (value == 0) {
        if (!d->sleepScreen) {
            return;
        }
        qDebug() << "Setting to never sleep";
        d->sleepScreen = false;
    } else {
        d->sleepScreen = true;
        if (d->sleepScreenTime == value) {
            return;
        }
        d->sleepScreenTime = value;
        qDebug() << "SEtting to sleep in " << value << "Minutes";
    }
    Q_EMIT sleepScreenIdxChanged();
    save();
}

int MobilePower::lockScreenIdx()
{
    qDebug() << "lock screen is" << d->sleepScreen;

    if (!d->lockScreen) {
        return d->idxToMinutes.key(0);
    }

    return d->idxToMinutes.key(d->lockScreenTime);
}

int MobilePower::sleepScreenIdx()
{
    qDebug() << "sleep screen is" << d->sleepScreen;
    if (!d->sleepScreen) {
        return d->idxToMinutes.key(0);
    }

    return d->idxToMinutes.key(d->sleepScreenTime);
}

#include "mobilepower.moc"
