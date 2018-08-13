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

#ifndef DEVELSETTINGS_H
#define DEVELSETTINGS_H

#include <QObject>
#include <QProcess>
#include <QVariantList>
#include <KQuickAddons/ConfigModule>


class DevelSettings : public KQuickAddons::ConfigModule
{
    Q_OBJECT
    Q_PROPERTY(bool sshEnabled READ sshEnabled WRITE enableSsh NOTIFY enableSshChanged)

public:
    DevelSettings(QObject* parent, const QVariantList& args);
    virtual ~DevelSettings();
    bool sshEnabled() const;
    void enableSsh(bool enable);

Q_SIGNALS:
    void enableSshChanged(bool enabled);
    void showTerminalChanged(bool shown);

private:
    bool m_sshEnabled;
    bool m_terminalShown;
    bool m_cursorVisible;
    QString m_terminalApp;
    QProcess m_getpropProcess;
};

#endif
