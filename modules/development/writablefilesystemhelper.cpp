/*
 *  Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *  Copyright 2015 Marco Martin <mart@kde.org>
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

#include "writablefilesystemhelper.h"

#include <QProcess>
#include <QFile>
#include <QDebug>


WritableFilesystemHelper::WritableFilesystemHelper(QObject *parent)
    : QObject(parent)
{
}

ActionReply WritableFilesystemHelper::detect(const QVariantMap &args)
{
    Q_UNUSED(args)

    ActionReply reply = ActionReply::SuccessReply();
    reply.addData("writable", QFile::exists("/userdata/.writable_image"));

    return reply;
}

ActionReply WritableFilesystemHelper::enable(const QVariantMap &args)
{
    Q_UNUSED(args)

    QFile file("/userdata/.writable_image");
    const bool created = file.open(QIODevice::WriteOnly);
    file.close();

    if (created) {
        return ActionReply::SuccessReply();
    } else {
        return ActionReply::HelperErrorReply();
    }
}

ActionReply WritableFilesystemHelper::disable(const QVariantMap &args)
{
    Q_UNUSED(args)

    bool deleted = true;
    if (QFile::exists("/userdata/.writable_image")) {
        deleted = QFile::remove("/userdata/.writable_image");
    }

    if (deleted) {
        return ActionReply::SuccessReply();
    } else {
        return ActionReply::HelperErrorReply();
    }
}

KAUTH_HELPER_MAIN("org.kde.active.integration", WritableFilesystemHelper)
