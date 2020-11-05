/*
 * Copyright 2020  Bhushan Shah <bshah@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "virtualkeyboard.h"
#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>

#include "languagemodel.h"

K_PLUGIN_CLASS_WITH_JSON(VirtualKeyboard, "metadata.json")

VirtualKeyboard::VirtualKeyboard(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
    , m_langModel(new LanguageModel(this))
{
    KAboutData *about = new KAboutData("kcm_mobile_virtualkeyboard", i18n("Virtual Keyboard"), "1.0", QString(), KAboutLicense::GPL);
    about->addAuthor(i18n("Bhushan Shah"), QString(), "bshah@kde.org");
    setAboutData(about);

    qmlRegisterType<LanguageModel>();
}

#include "virtualkeyboard.moc"
