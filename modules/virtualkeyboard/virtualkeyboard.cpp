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

// clang-format off

#define SETTER(setter, member, gsetting, signal) \
    void VirtualKeyboard::setter(bool enabled) \
    { \
        if (member != enabled) {\
            member = enabled; \
            m_gsettings->set(gsetting, enabled); \
            Q_EMIT signal();\
        }\
    }

// clang-format on

K_PLUGIN_CLASS_WITH_JSON(VirtualKeyboard, "metadata.json")

VirtualKeyboard::VirtualKeyboard(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
    , m_gsettings(new GSettingsItem("/org/maliit/keyboard/maliit/", parent))
    , m_langModel(new LanguageModel(this, m_gsettings))
{
    KAboutData *about = new KAboutData("kcm_mobile_virtualkeyboard", i18n("Virtual Keyboard"), "1.0", QString(), KAboutLicense::GPL);
    about->addAuthor(i18n("Bhushan Shah"), QString(), "bshah@kde.org");
    setAboutData(about);

    qmlRegisterType<LanguageModel>();

    m_autoCapitalize = m_gsettings->value("auto-capitalization").toBool();
    m_autoCompleteOnSpace = m_gsettings->value("auto-completion").toBool();
    m_showSuggestions = m_gsettings->value("predictive-text").toBool();
    m_fullStopOnDoubleSpace = m_gsettings->value("double-space-full-stop").toBool();
    m_spellCheck = m_gsettings->value("spell-checking").toBool();

    m_soundFeedback = m_gsettings->value("key-press-feedback").toBool();
    m_vibrateFeedback = m_gsettings->value("key-press-haptic-feedback").toBool();
}

SETTER(setAutoCapitalize, m_autoCapitalize, "auto-capitalization", autoCapitalizeChanged)
SETTER(setAutoCompleteOnSpace, m_autoCompleteOnSpace, "auto-completion", autoCompleteOnSpaceChanged);
SETTER(setShowSuggestions, m_showSuggestions, "predictive-text", showSuggestionsChanged)
SETTER(setFullStopOnDoubleSpace, m_fullStopOnDoubleSpace, "double-space-full-stop", fullStopOnDoubleSpaceChanged)
SETTER(setSpellCheck, m_spellCheck, "spell-checking", spellCheckChanged)

SETTER(setSoundFeedback, m_soundFeedback, "key-press-feedback", soundFeedbackChanged)
SETTER(setVibrateFeedback, m_vibrateFeedback, "key-press-haptic-feedback", vibrateFeedbackChanged)

#include "virtualkeyboard.moc"
