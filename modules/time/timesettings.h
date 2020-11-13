/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2011-2015 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 ***************************************************************************/

#ifndef TIMESETTINGS_H
#define TIMESETTINGS_H

#include <QDate>
#include <QIcon>
#include <QObject>
#include <QStringListModel>
#include <QTime>
#include <QVariant>

#include <KConfigGroup>
#include <KSharedConfig>

#include <KQuickAddons/ConfigModule>

/**
 * @class TimeSettings A class to manage time and date related settings. This class serves two functions:
 * - Provide a plugin implementation
 * - Provide a settings module
 * This is done from one class in order to simplify the code. You can export any QObject-based
 * class through qmlRegisterType(), however.
 */
class TimeSettings : public KQuickAddons::ConfigModule
{
    Q_OBJECT

    Q_PROPERTY(QString timeFormat READ timeFormat WRITE setTimeFormat NOTIFY timeFormatChanged)
    Q_PROPERTY(bool twentyFour READ twentyFour WRITE setTwentyFour NOTIFY twentyFourChanged)
    Q_PROPERTY(QString timeZone READ timeZone WRITE setTimeZone NOTIFY timeZoneChanged)
    Q_PROPERTY(QTime currentTime READ currentTime WRITE setCurrentTime NOTIFY currentTimeChanged)
    Q_PROPERTY(QDate currentDate READ currentDate WRITE setCurrentDate NOTIFY currentDateChanged)
    Q_PROPERTY(bool useNtp READ useNtp WRITE setUseNtp NOTIFY useNtpChanged)
    Q_PROPERTY(QString currentTimeText READ currentTimeText NOTIFY currentTimeTextChanged)
    Q_PROPERTY(QString errorString READ errorString NOTIFY errorStringChanged)

public:
    /**
     * @name Settings Module Constructor
     *
     * @arg parent The parent object
     * @arg list Arguments, currently unused
     */
    TimeSettings(QObject *parent, const QVariantList &args);
    ~TimeSettings() override;

    QString currentTimeText();
    QTime currentTime() const;
    void setCurrentTime(const QTime &time);

    QDate currentDate() const;
    void setCurrentDate(const QDate &date);

    bool useNtp() const;
    void setUseNtp(bool ntp);

    QString timeFormat();
    QString timeZone();
    bool twentyFour();

    QString errorString();

public Q_SLOTS:
    void setTimeZone(const QString &timezone);
    void setTimeFormat(const QString &timeFormat);
    void setTwentyFour(bool t);
    void timeout();
    bool saveTime();
    void notify();
    Q_INVOKABLE void saveTimeZone(const QString &newtimezone);

Q_SIGNALS:
    void currentTimeTextChanged();
    void currentTimeChanged();
    void currentDateChanged();
    void twentyFourChanged();
    void timeFormatChanged();
    void timeZoneChanged();
    void timeZonesChanged();
    void timeZonesModelChanged();
    void useNtpChanged();
    void errorStringChanged();

protected:
    QString findNtpUtility();

private:
    QString m_timeFormat;
    QString m_timezone;
    QString m_timeZoneFilter;
    QString m_currentTimeText;
    QTime m_currentTime;
    QDate m_currentDate;
    bool m_useNtp;
    QString m_errorString;

    void initSettings();

    KSharedConfig::Ptr m_localeConfig;
    KConfigGroup m_localeSettings;
};

#endif // TIMESETTINGS_H
