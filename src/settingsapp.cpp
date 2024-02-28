/*

    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "settingsapp.h"

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>

#include <KDBusService>

#include <KLocalizedString>

using namespace Qt::Literals::StringLiterals;

SettingsApp::SettingsApp(QCommandLineParser &parser, QObject *parent)
    : QObject(parent)
    , m_parser(&parser)
{
    setupKDBus();
}

SettingsApp::~SettingsApp() = default;

void SettingsApp::setupKDBus()
{
    QCoreApplication::setOrganizationDomain(u"kde.org"_s);
    KDBusService *service = new KDBusService(KDBusService::Unique, this);

    QObject::connect(service, &KDBusService::activateRequested, this, [this](const QStringList &arguments, const QString & /*workingDirectory*/) {
        qDebug() << "activateRequested" << arguments;
        m_parser->parse(arguments);

        if (m_parser->isSet(u"module"_s)) {
            const QString module = m_parser->value(u"module"_s);
            qDebug() << "Loading module:" << module;
            Q_EMIT moduleRequested(module);
        }

        Q_EMIT activateRequested();
    });
}

void SettingsApp::setStartModule(const QString &startModule)
{
    m_startModule = startModule;
    Q_EMIT startModuleChanged();
}

void SettingsApp::setSingleModule(const bool singleModule)
{
    m_singleModule = singleModule;
    Q_EMIT singleModuleChanged();
}
