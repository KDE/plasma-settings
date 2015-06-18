/*
 *  Copyright 2012 Aaron Seigo <aseigo@kde.org>
 *  Copyright 2012 Marco Martin <mart@kde.org>
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

#include "integrationhelper.h"

#include <QProcess>
#include <QFile>
#include <QDebug>


IntegrationHelper::IntegrationHelper(QObject *parent)
    : QObject(parent)
{
}

ActionReply IntegrationHelper::enable(const QVariantMap &args)
{
    Q_UNUSED(args)
    QStringList enableArgs;
    // add-apt-repository ppa:kubuntu-ci/unstable
    enableArgs << "ppa:kubuntu-ci/unstable";

    int rv = QProcess::execute("add-apt-repository", enableArgs);

    if (rv == 0) {
        return ActionReply::SuccessReply();
    } else {
        return ActionReply::HelperErrorReply();
    }
}

ActionReply IntegrationHelper::disable(const QVariantMap &args)
{
    Q_UNUSED(args)
    QStringList disableArgs;
    disableArgs << "-r" << "ppa:kubuntu-ci/unstable";

    int rv = QProcess::execute("add-apt-repository", disableArgs);

    if (rv == 0) {
        return ActionReply::SuccessReply();
    } else {
        return ActionReply::HelperErrorReply();
    }
}

KAUTH_HELPER_MAIN("org.kde.active.integration", IntegrationHelper)
