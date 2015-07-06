/**************************************************************************
*                                                                         *
*   Copyright 2005 S.R.Haque <srhaque@iee.org>.                           *
*   Copyright 2009 David Faure <faure@kde.org>                            *
*   Copyright 2011-2015 Sebastian Kügler <sebas@kde.org>                  *
*   Copyright 2015 David Edmundson <davidedmundson@kde.org>               *
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
*   This program is distributed in the hope that it will be useful,       *
*   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
*   GNU General Public License for more details.                          *
*                                                                         *
*   You should have received a copy of the GNU General Public License     *
*   along with this program; if not, write to the                         *
*   Free Software Foundation, Inc.,                                       *
*   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
***************************************************************************/

#include "timesettings.h"
#include "timezone.h"
#include "timezonesmodel.h"

#include <QDebug>
#include <QtCore/QDate>


#include <QStandardItemModel>
#include <QDBusConnection>
#include <QDBusMessage>
#include <QTimer>
#include <QVariant>


#include <KAboutData>
#include <KPluginFactory>
#include <KSharedConfig>
#include <KConfigGroup>
#include <KSystemTimeZone>
#include <KTimeZone>
#include <KLocalizedString>

#include "timedated_interface.h"


#define FORMAT24H "HH:mm:ss"
#define FORMAT12H "h:mm:ss ap"

K_PLUGIN_FACTORY_WITH_JSON(TimeSettingsFactory, "timesettings.json", registerPlugin<TimeSettings>();)


class TimeSettingsPrivate {
public:
    TimeSettings *q;
    QString timeFormat;
    QString timezone;
    QObject *timeZonesModel;
    QString timeZoneFilter;
    QString currentTimeText;
    QTime currentTime;
    QDate currentDate;
    QTimer *timer;
    bool useNtp;
    QString errorString;


    void initSettings();
    void initTimeZones();
    QString displayName(const KTimeZone &zone);


    KSharedConfigPtr localeConfig;
    KConfigGroup localeSettings;
    KTimeZones *timeZones;
    QList<QObject*> timezones;
};

TimeSettings::TimeSettings(QObject* parent, const QVariantList& args)
    : KQuickAddons::ConfigModule(parent, args)
{
    qDebug() << "time settings init";
    d = new TimeSettingsPrivate;
    d->q = this;
    d->timeZones = 0;
    d->timeZonesModel = 0;
    setTimeZone(KSystemTimeZones::local().name());

    KAboutData* about = new KAboutData("kcm_mobile_time", i18n("Configure Date and Time"),
                                       "0.1", QString(), KAboutLicense::LGPL);
    about->addAuthor(i18n("Sebastian Kügler"), QString(), "sebas@kde.org");
    setAboutData(about);
    setButtons(Apply | Default);

    d->initSettings();

    // Just for testing that data gets through
    d->timer = new QTimer(this);
    d->timer->setInterval(1000);
    connect(d->timer, &QTimer::timeout, this, &TimeSettings::timeout);
    d->timer->start();

    qDebug() << "TimeSettings module loaded.";
}

TimeSettings::~TimeSettings()
{
    delete d;
}

void TimeSettingsPrivate::initTimeZones()
{
    // Collect zones by localized city names, so that they can be sorted properly.
    QStringList cities;
    QStringList tz;
    QHash<QString, KTimeZone> zonesByCity;

    if (!timeZones) {
        timeZones = KSystemTimeZones::timeZones();

        // add UTC to the defaults default
        KTimeZone utc = KTimeZone::utc();
        cities.append(utc.name());
        zonesByCity.insert(utc.name(), utc);
    }
    //qDebug() << " TZ: cities: " << cities;

    const KTimeZones::ZoneMap zones = timeZones->zones();

    QList<QObject*> _zones;
    QStandardItemModel *_zonesModel = new TimeZonesModel(q);

    for ( KTimeZones::ZoneMap::ConstIterator it = zones.begin(); it != zones.end(); ++it ) {
        const KTimeZone zone = it.value();
        if (timeZoneFilter.isEmpty() || zone.name().contains(timeZoneFilter, Qt::CaseInsensitive)) {
            TimeZone *_zone = new TimeZone(zone);
            _zones.append(_zone);
            QStandardItem *item = new QStandardItem(_zone->name());
            item->setData(_zone->name().split('/').first(), Qt::UserRole+1);
            _zonesModel->appendRow(item);
        }
    }
    qDebug() << "Found: " << _zones.count() << " timezones.";
    //qSort( cities.begin(), cities.end(), localeLessThan );
    q->setTimeZones(_zones);
    q->setTimeZonesModel(_zonesModel);
}

QString TimeSettingsPrivate::displayName( const KTimeZone &zone )
{
    return zone.name().toUtf8().replace( '_', ' ' );
}

void TimeSettingsPrivate::initSettings()
{
    localeConfig = KSharedConfig::openConfig("kdeglobals", KConfig::SimpleConfig);
    localeSettings = KConfigGroup(localeConfig, "Locale");

    q->setTimeFormat( localeSettings.readEntry( "TimeFormat", QString(FORMAT24H) ) ); // FIXME?!

    OrgFreedesktopTimedate1Interface timeDatedIface("org.freedesktop.timedate1", "/org/freedesktop/timedate1", QDBusConnection::systemBus());
    //the server list is not relevant for timesyncd, it fetches it from the network
    useNtp = timeDatedIface.nTP();
}


void TimeSettings::timeout()
{
    setCurrentTime(QTime::currentTime());
    setCurrentDate(QDate::currentDate());
    notify();
}


QString TimeSettings::currentTimeText()
{
    return d->currentTimeText;
}

QTime TimeSettings::currentTime() const
{
    return d->currentTime;
}

void TimeSettings::setCurrentTime(const QTime &currentTime)
{
    if (d->currentTime != currentTime) {
        d->currentTime = currentTime;
        d->currentTimeText = QLocale().toString(QTime::currentTime(), d->timeFormat);
        emit currentTimeChanged();
    }
}

QDate TimeSettings::currentDate() const
{
    return d->currentDate;
}

void TimeSettings::setCurrentDate(const QDate &currentDate)
{
    if (d->currentDate != currentDate) {
        d->currentDate = currentDate;
        emit currentDateChanged();
    }
}

bool TimeSettings::useNtp() const
{
    return d->useNtp;
}

void TimeSettings::setUseNtp(bool ntp)
{
    if (d->useNtp != ntp) {
        d->useNtp = ntp;
        saveTime();
        emit useNtpChanged();
    }
}

bool TimeSettings::saveTime()
{

    OrgFreedesktopTimedate1Interface timedateIface("org.freedesktop.timedate1", "/org/freedesktop/timedate1", QDBusConnection::systemBus());

    bool rc = true;
    //final arg in each method is "user-interaction" i.e whether it's OK for polkit to ask for auth

    //we cannot send requests up front then block for all replies as we need NTP to be disabled before we can make a call to SetTime
    //timedated processes these in parallel and will return an error otherwise

    auto reply = timedateIface.SetNTP(useNtp(), true);
    reply.waitForFinished();
    if (reply.isError()) {
        d->errorString = i18n("Unable to change NTP settings");
        emit errorStringChanged();
        qWarning() << "Failed to enable NTP" << reply.error().name() << reply.error().message();
        rc = false;
    }

    if (!useNtp()) {
        QDateTime userTime;
        userTime.setTime(currentTime());
        userTime.setDate(currentDate());
        qDebug() << "Setting userTime: " << userTime;
        qint64 timeDiff = userTime.toMSecsSinceEpoch() - QDateTime::currentMSecsSinceEpoch();
        //*1000 for milliseconds -> microseconds
        auto reply = timedateIface.SetTime(timeDiff * 1000, true, true);
        reply.waitForFinished();
        if (reply.isError()) {
            d->errorString = i18n("Unable to set current time");
            emit errorStringChanged();
            qWarning() << "Failed to set current time" << reply.error().name() << reply.error().message();
            rc = false;
        }
    }
    saveTimeZone(timeZone());

    return rc;
}

void TimeSettings::saveTimeZone(const QString &newtimezone)
{
    qDebug() << "Saving timezone to config: " << newtimezone;
    OrgFreedesktopTimedate1Interface timedateIface("org.freedesktop.timedate1", "/org/freedesktop/timedate1", QDBusConnection::systemBus());

    if (!newtimezone.isEmpty()) {
        qDebug() << "Setting timezone: " << newtimezone;
        auto reply = timedateIface.SetTimezone(newtimezone, true);
        reply.waitForFinished();
        if (reply.isError()) {
            d->errorString = i18n("Unable to set timezone");
            emit errorStringChanged();
            qWarning() << "Failed to set timezone" << reply.error().name() << reply.error().message();
        }
    }

    setTimeZone(newtimezone);
    emit timeZoneChanged();
    notify();
}


QString TimeSettings::timeFormat()
{
    return d->timeFormat;
}

void TimeSettings::setTimeFormat(const QString &timeFormat)
{
    if (d->timeFormat != timeFormat) {
        d->timeFormat = timeFormat;

        d->localeSettings.writeEntry("TimeFormat", timeFormat);
        d->localeConfig->sync();

        QDBusMessage msg = QDBusMessage::createSignal("/org/kde/kcmshell_clock", "org.kde.kcmshell_clock", "clockUpdated");
        QDBusConnection::sessionBus().send(msg);

        qDebug() << "time format is now: " << QLocale().toString(QTime::currentTime(), d->timeFormat);
        emit timeFormatChanged();
        timeout();
    }
}

QString TimeSettings::timeZone()
{
    return d->timezone;
}

void TimeSettings::setTimeZone(const QString &timezone)
{
    if (d->timezone != timezone) {
        d->timezone = timezone;
        qDebug() << "timezone changed to: " << timezone;
        emit timeZoneChanged();
        timeout();
    }
}

QList<QObject*> TimeSettings::timeZones()
{
    if (!d->timeZones) {
        d->initTimeZones();
    }
    return d->timezones;
}

void TimeSettings::setTimeZones(QList<QObject*> timezones)
{
    d->timezones = timezones;
    emit timeZonesChanged();
}

QObject* TimeSettings::timeZonesModel()
{
    if (!d->timeZones) {
        d->initTimeZones();
    }
    return d->timeZonesModel;
}

void TimeSettings::setTimeZonesModel(QObject* timezones)
{
    d->timeZonesModel = timezones;
    emit timeZonesModelChanged();
}

void TimeSettings::timeZoneFilterChanged(const QString &filter)
{
    d->timeZoneFilter = filter;
    d->timeZoneFilter.replace(' ', '_');
    d->initTimeZones();
    emit timeZonesChanged();
}

bool TimeSettings::twentyFour()
{
    return timeFormat() == FORMAT24H;
}

void TimeSettings::setTwentyFour(bool t)
{
    if (twentyFour() != t) {
        if (t) {
            setTimeFormat(FORMAT24H);
        } else {
            setTimeFormat(FORMAT12H);
        }
        qDebug() << "T24 toggled: " << t << d->timeFormat;
        emit twentyFourChanged();
        emit currentTimeChanged();
        timeout();
    }
}

QString TimeSettings::errorString()
{
    return d->errorString;
}

void TimeSettings::notify()
{
    QDBusMessage msg = QDBusMessage::createSignal("/org/kde/kcmshell_clock", "org.kde.kcmshell_clock", "clockUpdated");
    QDBusConnection::sessionBus().send(msg);

}


#include "timesettings.moc"
