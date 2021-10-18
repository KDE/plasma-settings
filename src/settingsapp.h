/*

    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef SETTINGSAPP_H
#define SETTINGSAPP_H

#include <QCommandLineParser>
#include <QObject>

class SettingsApp : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString startModule MEMBER m_startModule WRITE setStartModule NOTIFY startModuleChanged)
    Q_PROPERTY(bool singleModule MEMBER m_singleModule WRITE setSingleModule NOTIFY singleModuleChanged)

public:
    explicit SettingsApp(QCommandLineParser &parser, QObject *parent = nullptr);
    ~SettingsApp() override;

    void setSingleModule(const bool singleModule);
    void setStartModule(const QString &startModule);

Q_SIGNALS:
    void moduleRequested(const QString &moduleName);
    void activateRequested();

    void startModuleChanged();
    void singleModuleChanged();

private:
    void setupKDBus();
    QCommandLineParser *m_parser;

    QString m_startModule;
    bool m_singleModule;
};

#endif // SettingsApp_H
