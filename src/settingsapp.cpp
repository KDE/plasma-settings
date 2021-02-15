/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>                  *
 *   SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>                            *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 ***************************************************************************/

#include "settingsapp.h"

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>

#include <KDBusService>

#include <KLocalizedString>

SettingsApp::SettingsApp(QCommandLineParser &parser, QObject *parent)
    : QObject(parent)
    , m_parser(&parser)
{
    setupKDBus();
}

SettingsApp::~SettingsApp() = default;

void SettingsApp::setupKDBus()
{
    QCoreApplication::setOrganizationDomain("kde.org");
    KDBusService *service = new KDBusService(KDBusService::Unique, this);

    QObject::connect(service, &KDBusService::activateRequested, this, [this](const QStringList &arguments, const QString & /*workingDirectory*/) {
        qDebug() << "activateRequested" << arguments;
        m_parser->parse(arguments);
        if (m_parser->isSet("module")) {
            const QString module = m_parser->value("module");
            qDebug() << "Loading module:" << module;
            emit moduleRequested(module);
        }
        emit activateRequested();
    });
}

void SettingsApp::setStartModule(const QString &startModule)
{
    m_startModule = startModule;
}

void SettingsApp::setSingleModule(const bool singleModule)
{
    m_singleModule = singleModule;
}
