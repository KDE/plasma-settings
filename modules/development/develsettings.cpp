/*
 *  Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *  Copyright 2015 Sebastian Kügler <sebas@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "develsettings.h"

#include <QDebug>
#include <QDBusInterface>
#include <QFile>
#include <QTimer>
#include <QtQml>

#include <KAuthAction>
#include <KAuthExecuteJob>

#include <KAboutData>
#include <KConfig>
#include <KConfigGroup>
#include <KDesktopFile>

#include <KLocalizedString>


#include <KPluginFactory>
#include <KSharedConfig>
#include <KService>
#include <KSycoca>

K_PLUGIN_FACTORY_WITH_JSON(DevelSettingsFactory, "develsettings.json", registerPlugin<DevelSettings>();)

DevelSettings::DevelSettings(QObject* parent, const QVariantList& args)
    : KQuickAddons::ConfigModule(parent, args),
      m_developerModeEnabled(false)
{
    // TODO: should probably not rely on systemctl, but be put into a platform specific backend?
    const int rv = QProcess::execute("systemctl is-enabled sshd.service");
    m_sshEnabled = rv == 0;

    KAboutData* about = new KAboutData("kcm_settings_devel", i18n("Developer Settings"),
                                       "1.0", QString(), KAboutLicense::LGPL);
    about->addAuthor(i18n("Sebastian Kügler"), QString(), "sebas@kde.org");
    setAboutData(about);
    setButtons(Apply | Default);


    KConfigGroup confGroup(KSharedConfig::openConfig(), "General");
    m_writableFilesystemEnabled = QFile::exists("/userdata/.writable_image");

    QStringList getPropArgs;
    getPropArgs << "persist.sys.usb.config";

    m_getpropProcess.start("getprop", getPropArgs);
    connect(&m_getpropProcess, &QProcess::readyReadStandardOutput, this, [this]() {
        QString output = m_getpropProcess.readAllStandardOutput();
        m_developerModeEnabled = output.contains("adb");
        emit enableDeveloperModeChanged(m_developerModeEnabled);
    });
}

DevelSettings::~DevelSettings()
{
}

void DevelSettings::setDeveloperModeEnabled(bool enable)
{
    if (m_developerModeEnabled != enable) {
        const bool was = m_developerModeEnabled;
        m_developerModeEnabled = enable;

        //TODO: this really should be non-blocking ...
        KAuth::Action action(m_developerModeEnabled ? "org.kde.active.developermode.enable"
        : "org.kde.active.developermode.disable");
        action.setHelperId("org.kde.active.developermode");

        qDebug() << "Action" << action.name() << action.details() << "valid:" << action.isValid();
        auto job = action.execute();
        if (job->error()) {
            m_developerModeEnabled = !m_developerModeEnabled;
            qWarning()<< "KAuth returned an error code:" << job->errorString() << "enabled" << m_developerModeEnabled;
        }

        if (was != m_developerModeEnabled) {
            KConfigGroup confGroup(KSharedConfig::openConfig(), "General");
            confGroup.writeEntry("DeveloperModeEnabled", m_developerModeEnabled);
            emit enableDeveloperModeChanged(m_developerModeEnabled);
        }
    }
}

bool DevelSettings::isDeveloperModeEnabled()
{
    return m_developerModeEnabled;
}

bool DevelSettings::sshEnabled() const
{
    return m_sshEnabled;
}

void DevelSettings::enableSsh(bool enable)
{
    if (m_sshEnabled != enable) {
        const bool was = m_sshEnabled;
        m_sshEnabled = enable;

        //TODO: this really should be non-blocking ...
        KAuth::Action action(m_sshEnabled ? "org.kde.active.sshdcontrol.start"
        : "org.kde.active.sshdcontrol.stop");
        action.setHelperId("org.kde.active.sshdcontrol");

        qDebug() << "Action" << action.name() << action.details() << "valid:" << action.isValid();

        auto reply = action.execute();
        if (reply->error()) {
            m_sshEnabled = !m_sshEnabled;
            qWarning()<< "KAuth returned an error code:" << reply->errorString() << m_sshEnabled;
        }

        if (was != m_sshEnabled) {
            emit enableSshChanged(m_sshEnabled);
        }
    }
}

void DevelSettings::setWritableFilesystemEnabled(bool enable)
{
    if (m_writableFilesystemEnabled != enable) {
        const bool was = m_writableFilesystemEnabled;
        m_writableFilesystemEnabled = enable;

        //TODO: this really should be non-blocking ...
        KAuth::Action action(m_writableFilesystemEnabled ? "org.kde.active.writablefilesystem.enable"
        : "org.kde.active.writablefilesystem.disable");
        action.setHelperId("org.kde.active.writablefilesystem");

        qDebug() << "Action" << action.name() << action.details() << "valid:" << action.isValid();
        auto job = action.execute();
        if (job->error()) {
            m_writableFilesystemEnabled = !m_writableFilesystemEnabled;
            qWarning()<< "KAuth returned an error code:" << job->errorString() << "enabled" << m_writableFilesystemEnabled;
        }

        if (was != m_writableFilesystemEnabled) {
            KConfigGroup confGroup(KSharedConfig::openConfig(), "General");
            confGroup.writeEntry("WritableFilesystemEnabled", m_writableFilesystemEnabled);
            emit enableWritableFilesystemChanged(m_writableFilesystemEnabled);
        }
    }
}

bool DevelSettings::isWritableFilesystemEnabled()
{
    return m_writableFilesystemEnabled;
}

#include "develsettings.moc"