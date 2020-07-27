/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2015 Sebastian Kügler <sebas@kde.org>                  *
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

// std
#include <iostream>
#include <iomanip>

//own
#include "settingsapp.h"
#include "modulesmodel.h"
#include "module.h"

// Qt
#include <QApplication>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include <QDebug>
#include <QQmlApplicationEngine>
#include <QIcon>
#include <QQmlContext>

// Frameworks
#include <KAboutData>
#include <KLocalizedString>
#include <KPackage/PackageLoader>
#include <KPluginMetaData>
#include <KPluginLoader>

static const char description[] = I18N_NOOP("Plasma Mobile Settings");
static const char version[] = "2.0";
static const char HOME_URL[] = "http://plasma-mobile.org";

int main(int argc, char **argv)
{
    QApplication app(argc, argv);

    KLocalizedString::setApplicationDomain("plasma-settings");

    // About data
    KAboutData aboutData("mobile.plasmasettings", i18n("Settings"), version, i18n("Touch-friendly settings application."), KAboutLicense::GPL, i18n("Copyright 2011-2015, Sebastian Kügler"));
    aboutData.addAuthor(i18n("Sebastian Kügler"), i18n("Maintainer"), "sebas@kde.org");
    aboutData.addAuthor(i18n("Marco Martin"), i18n("Maintainer"), "mart@kde.org");
    aboutData.setDesktopFileName("org.kde.mobile.plasmasettings");
    KAboutData::setApplicationData(aboutData);

    QApplication::setWindowIcon(QIcon::fromTheme("preferences-system"));

    const static auto _l = QStringLiteral("list");
    const static auto _m = QStringLiteral("module");
    const static auto _f = QStringLiteral("fullscreen");
    const static auto _s = QStringLiteral("singleModule");
    const static auto _ff = QStringLiteral("formfactor");

    QCommandLineOption _list = QCommandLineOption(QStringList() << QStringLiteral("l") << _l,
                               i18n("List available settings modules"));
    QCommandLineOption _module = QCommandLineOption(QStringList() << QStringLiteral("m") << _m,
                                i18n("Settings module to open"), i18n("modulename"));
    QCommandLineOption _singleModule = QCommandLineOption(QStringList() << QStringLiteral("s") << _s,
                                i18n("Only show a single module, requires --module"));
    QCommandLineOption _fullscreen = QCommandLineOption(QStringList() << QStringLiteral("f") << _f,
                                i18n("Start window fullscreen"));
    QCommandLineOption _formfactor = QCommandLineOption(QStringList() << QStringLiteral("x") << _ff,
                                                  i18n("Limit to modules suitable for <formfactor>, e.g. handset, tablet, mediacenter, desktop, test, all (default handset)"), i18n("formfactor"));

    QCommandLineParser parser;
    parser.addOption(_list);
    parser.addOption(_formfactor);
    parser.addOption(_module);
    parser.addOption(_singleModule);
    parser.addOption(_fullscreen);
    aboutData.setupCommandLine(&parser);

    parser.process(app);
    aboutData.processCommandLine(&parser);

    if (parser.isSet(_list)) {
        int nameWidth = 24;
        QSet<QString> seen;
        std::cout << std::setfill('.');

        auto formfactor = parser.value("formfactor");

        for (const auto& plugin : KPackage::PackageLoader::self()->listPackages(QString(), "kpackage/kcms/")) {
            if (seen.contains(plugin.pluginId())) {
                continue;
            }
            // Filter out modules that are not explicitly suitable for the "handset" formfactor
            //const QStringList &formFactors = plugin.formFactors();
            if (!formfactor.isEmpty() && !plugin.formFactors().contains(formfactor) && formfactor != QStringLiteral("all")) {
                continue;
            }
            const int len = plugin.pluginId().length();
            if (len > nameWidth) {
                nameWidth = len;
            }

            seen << plugin.pluginId();
            std::cout << plugin.pluginId().toLocal8Bit().data()
            << ' '
            << std::setw(nameWidth - plugin.pluginId().length() + 2)
            << '.' << ' '
            << plugin.description().toLocal8Bit().data() << std::endl;

            //qDebug() << "Formafactors: " << formFactors;
        }

        for (const auto& plugin : KPluginLoader::findPlugins("kcms")) {
            if (seen.contains(plugin.pluginId())) {
                continue;
            }
            if (!formfactor.isEmpty() && !plugin.formFactors().contains(formfactor) && formfactor != QStringLiteral("all")) {
                continue;
            }
            const int len = plugin.pluginId().length();
            if (len > nameWidth) {
                nameWidth = len;
            }
            std::cout << plugin.pluginId().toLocal8Bit().data()
            << ' '
            << std::setw(nameWidth - plugin.pluginId().length() + 2)
            << '.' << ' '
            << plugin.description().toLocal8Bit().data() << std::endl;
        }

        return 0;
    }

    const QString module = parser.value(_m);
    const bool singleModule = parser.isSet(_s);

    if (singleModule && module.isEmpty()) {
        parser.showHelp();
        return 0;
    }

    auto *settingsApp = new SettingsApp(parser);

    qmlRegisterType<ModulesModel>("org.kde.plasma.settings", 0, 1, "ModulesModel");
    qmlRegisterType<Module>("org.kde.plasma.settings", 0, 1, "Module");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("settingsApp", settingsApp);
    engine.rootContext()->setContextProperty("startModule", module);
    engine.rootContext()->setContextProperty("singleModule", singleModule);
    engine.load("qrc:/qml/main.qml");

    return app.exec();
}
