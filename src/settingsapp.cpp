/***************************************************************************
 *                                                                         *
 *   Copyright 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
 *   Copyright 2017 Marco Martin <mart@kde.org>                            *
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

#include "settingsapp.h"

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>

#include <KDBusService>

#include <KLocalizedString>


SettingsApp::SettingsApp(QCommandLineParser &parser, QObject *parent)
    : QObject(parent),
      m_parser(&parser)
{
    setupKDBus();
}

SettingsApp::~SettingsApp()
= default;

void SettingsApp::setupKDBus()
{
    QCoreApplication::setOrganizationDomain("kde.org");
    KDBusService* service = new KDBusService(KDBusService::Unique, this);

    QObject::connect(service, &KDBusService::activateRequested, this, [this](const QStringList &arguments, const QString &/*workingDirectory*/) {
        qDebug() << "activateRequested" << arguments;
        m_parser->parse(arguments);
        if (m_parser->isSet("module")) {
            const QString module = m_parser->value("module");
            qDebug() << "Loading module:" << module;
            emit moduleRequested(module);
        }
        emit activateRequested();
    } );
}

void SettingsApp::setStartModule(const QString &startModule)
{
    m_startModule = startModule;
}

void SettingsApp::setSingleModule(const bool singleModule)
{
    m_singleModule = singleModule;
}
