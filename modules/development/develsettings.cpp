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
 : KQuickAddons::ConfigModule(parent, args) {
    // TODO: should probably not rely on systemctl, but be put into a platform specific backend?
    const int rv = QProcess::execute("systemctl is-enabled sshd.service");
    m_sshEnabled = rv == 0;

    KAboutData* about = new KAboutData("kcm_settings_devel", i18n("Developer Settings"),
                                       "1.0", QString(), KAboutLicense::LGPL);
    about->addAuthor(i18n("Sebastian Kügler"), QString(), "sebas@kde.org");
    setAboutData(about);
    setButtons(Apply | Default);
}

DevelSettings::~DevelSettings()
{
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
        reply->exec();
        if (reply->error()) {
            m_sshEnabled = !m_sshEnabled;
            qWarning()<< "KAuth returned an error code:" << reply->errorString() << m_sshEnabled;
        }

        if (was != m_sshEnabled) {
            emit enableSshChanged(m_sshEnabled);
        }
    }
}

#include "develsettings.moc"
