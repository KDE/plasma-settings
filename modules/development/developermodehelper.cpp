/*
 *  Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *  Copyright 2016 Marco Martin <mart@kde.org>
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

#include "developermodehelper.h"

#include <QProcess>
#include <QFile>
#include <QDebug>


DeveloperModeHelper::DeveloperModeHelper(QObject *parent)
    : QObject(parent)
{
}

ActionReply DeveloperModeHelper::enable(const QVariantMap &args)
{
    Q_UNUSED(args)
    QStringList enableArgs;

    enableArgs << "persist.sys.usb.config" << "mtp,adb";

    int rv = QProcess::execute("setprop", enableArgs);

    QFile file("/userdata/.adb_onlock");
    bool created = file.open(QIODevice::WriteOnly);
    file.close();

    if (rv == 0 && created) {
        return ActionReply::SuccessReply();
    } else {
        return ActionReply::HelperErrorReply();
    }
}

ActionReply DeveloperModeHelper::disable(const QVariantMap &args)
{
    Q_UNUSED(args)
    QStringList disableArgs;
    disableArgs << "persist.sys.usb.config" << "mtp";

    int rv = QProcess::execute("setprop", disableArgs);

    bool deleted = true;
    if (QFile::exists("/userdata/.adb_onlock")) {
        deleted = QFile::remove("/userdata/.adb_onlock");
    }

    if (rv == 0 && deleted) {
        return ActionReply::SuccessReply();
    } else {
        return ActionReply::HelperErrorReply();
    }
}

KAUTH_HELPER_MAIN("org.kde.active.developermode", DeveloperModeHelper)
