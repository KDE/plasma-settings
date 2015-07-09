/***************************************************************************
 *                                                                         *
 *   Copyright 2015 Sebastian Kügler <sebas@kde.org>                       *
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

#include "themesettings.h"
#include "themelistmodel.h"

#include <QDBusConnection>
#include <QDBusMessage>

#include <KPluginFactory>
#include <KLocalizedString>
#include <KAboutData>

#include <Plasma/Theme>

K_PLUGIN_FACTORY_WITH_JSON(ThemeSettingsFactory, "themesettings.json", registerPlugin<ThemeSettings>();)


ThemeSettings::ThemeSettings(QObject* parent, const QVariantList& args)
    : KQuickAddons::ConfigModule(parent, args)
{
    KAboutData* about = new KAboutData("kcm_mobile_theme", i18n("Configure Appearance"),
                                       "1.0", QString(), KAboutLicense::LGPL);
    about->addAuthor(i18n("Sebastian Kügler"), QString(), "sebas@kde.org");
    setAboutData(about);
    setButtons(Apply | Default);

    qDebug() << "ThemeSettings module loaded.";

    qmlRegisterType<ThemeListModel>();
    m_themeListModel = new ThemeListModel(this);
    m_theme = new Plasma::Theme(this);
    m_theme->setUseGlobalSettings(true);
    m_themeName = m_theme->themeName();

    qDebug() << "Current theme: " << m_themeName;

    auto kdeglobals = KSharedConfig::openConfig("kdeglobals");
    KConfigGroup cfg(kdeglobals, "General");
    m_font = cfg.readEntry("font", QFont());
    qDebug() << "Font: " << m_font << m_font.pointSize();
}

ThemeSettings::~ThemeSettings()
{
}

void ThemeSettings::setThemeName(const QString& theme)
{
    if (theme != m_themeName) {
        m_themeName = theme;

        /// ...
        m_theme->setThemeName(theme);
        emit themeNameChanged();
    }
}

QString ThemeSettings::themeName() const
{
    return m_themeName;
}

ThemeListModel *ThemeSettings::themeListModel()
{
    return m_themeListModel;
}

int ThemeSettings::fontSize() const
{
    return m_font.pointSize();
}

void ThemeSettings::setFontSize(int pointSize)
{
    m_font.setPointSize(pointSize);
    qDebug() << "Font size set to : " << m_font.pointSize();

    auto kdeglobals = KSharedConfig::openConfig("kdeglobals");
    KConfigGroup cfg(kdeglobals, "General");
    cfg.writeEntry("font", m_font);

    kdeglobals->sync();

    QDBusMessage message = QDBusMessage::createSignal("/KDEPlatformTheme", "org.kde.KDEPlatformTheme", "refreshFonts");
    QDBusConnection::sessionBus().send(message);

    //qApp->processEvents(); // Process font change ourselves

}




#include "themesettings.moc"
