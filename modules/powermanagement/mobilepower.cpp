// SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
// SPDX-FileCopyrightText: 2020 Tomaz Canabrava <tcanabrava@kde.org>

#include "mobilepower.h"

#include <KAboutData>
#include <KConfigGroup>
#include <KLocalizedString>
#include <KPluginFactory>
#include <KSharedConfig>

K_PLUGIN_CLASS_WITH_JSON(MobilePower, "powermanagement.json")

struct MobilePower::Private {
    qreal suspendSessionTime;
    qreal sleepScreenTime;
    bool lockScreen;
    bool sleepScreen;

    QStringList timeValues = {
        i18n("30 sec"),
        i18n("1 min"),
        i18n("2 min"),
        i18n("5 min"),
        i18n("10 min"),
        i18n("15 min"),
        i18n("Never"),
    };

    enum {
        THIRTY_SECONDS,
        ONE_MINUTE,
        TWO_MINUTES,
        FIVE_MINUTES,
        TEN_MINUTES,
        FIFTEEN_MINUTES,
        NEVER,
    };

    // Maps the indices of the timeValues indexes
    // to minutes.
    QMap<int, qreal> idxToMinutes = {
        {THIRTY_SECONDS, 0.5},
        {ONE_MINUTE, 1},
        {TWO_MINUTES, 2},
        {FIVE_MINUTES, 5},
        {TEN_MINUTES, 10},
        {FIFTEEN_MINUTES, 15},
        {NEVER, 0},
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

qreal MobilePower::suspendSessionTime() const
{
    return d->suspendSessionTime;
}

void MobilePower::setLockScreenTime(qreal value)
{
    if (qFuzzyCompare(d->suspendSessionTime, value)) {
        return;
    }
    d->suspendSessionTime = value;

    Q_EMIT suspendSessionTimeChanged(value);
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

qreal MobilePower::sleepScreenTime() const
{
    return d->sleepScreenTime;
}

void MobilePower::setSleepScreenTime(qreal value)
{
    if (qFuzzyCompare(d->sleepScreenTime, value)) {
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

void MobilePower::load()
{
    KConfigGroup batteryGroup = d->profilesConfig->group("Battery");

    if (batteryGroup.hasGroup("DimDisplay")) {
        qDebug() << "Group is valid";
        KConfigGroup dimSettings = batteryGroup.group("DimDisplay");
        d->sleepScreen = true;

        // powerdevil/dimdisplayconfig.cpp - here we load time / 60 / 1000
        // We should really, really, stop doing that.
        d->sleepScreenTime = (dimSettings.readEntry("idleTime").toDouble() / 60) / 1000;
    } else {
        qDebug() << "Group is invalid, setting sleep screen to false";
        d->sleepScreen = false;
    }

    KConfigGroup suspendSessionGroup = batteryGroup.group("SuspendSession");
    d->lockScreen = true;
    d->suspendSessionTime = suspendSessionGroup.readEntry("idleTime").toDouble() / 60 / 1000;

    Q_EMIT lockScreenChanged(d->lockScreen);
    Q_EMIT suspendSessionTimeChanged(d->suspendSessionTime);
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

    KConfigGroup suspendSessionGroup = batteryGroup.group("SuspendSession");
    suspendSessionGroup.writeEntry("idleTime", d->suspendSessionTime * 60 * 1000);

    d->profilesConfig->sync();
    // Do not mess with Suspend Type
    // suspendSessionGroup.writeEntry("suspendType", 32); // always lock screen.
}

QStringList MobilePower::timeOptions() const
{
    return d->timeValues;
}

void MobilePower::setLockScreenIdx(int idx)
{
    qreal value = d->idxToMinutes.value(idx);
    qDebug() << "Got the value" << value;

    if (value == 0) {
        if (!d->lockScreen) {
            return;
        }
        qDebug() << "Setting to never lock";

        d->lockScreen = false;
    } else {
        d->lockScreen = true;
        if (d->suspendSessionTime == value) {
            return;
        }
        d->suspendSessionTime = value;
        qDebug() << "SEtting to lock in " << value << "Minutes";
    }
    Q_EMIT suspendSessionIdxChanged();
    save();
}

void MobilePower::setSleepScreenIdx(int idx)
{
    qreal value = d->idxToMinutes.value(idx);
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

int MobilePower::suspendSessionIdx()
{
    qDebug() << "lock screen is" << d->lockScreen;

    if (!d->lockScreen) {
        return MobilePower::Private::NEVER;
    }

    if (qFuzzyIsNull(d->suspendSessionTime)) {
        return MobilePower::Private::NEVER;
    } else if (qFuzzyCompare(d->suspendSessionTime, 0.5)) {
        return MobilePower::Private::THIRTY_SECONDS;
    }

    return d->idxToMinutes.key(std::round(d->suspendSessionTime));
}

int MobilePower::sleepScreenIdx()
{
    qDebug() << "sleep screen is" << d->sleepScreen << d->sleepScreenTime;
    if (!d->sleepScreen) {
        return MobilePower::Private::NEVER;
    }

    if (qFuzzyIsNull(d->sleepScreenTime)) {
        return MobilePower::Private::NEVER;
    } else if (qFuzzyCompare(d->sleepScreenTime, 0.5)) {
        return MobilePower::Private::THIRTY_SECONDS;
    }

    return d->idxToMinutes.key(std::round(d->sleepScreenTime));
}

#include "mobilepower.moc"
