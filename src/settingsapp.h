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

#ifndef SETTINGSAPP_H
#define SETTINGSAPP_H

#include <QObject>
#include <QCommandLineParser>

class SettingsApp : public QObject
{
    Q_OBJECT

public:
    explicit SettingsApp(QCommandLineParser &parser, QObject *parent = nullptr );
    ~SettingsApp() override;

Q_SIGNALS:
    void moduleRequested(const QString &module);
    void activateRequested();


private:
    void setupKDBus();
    QCommandLineParser *m_parser;
};

#endif // SettingsApp_H
