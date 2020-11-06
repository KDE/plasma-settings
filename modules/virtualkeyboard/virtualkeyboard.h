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

#include "languagemodel.h"
#include <KQuickAddons/ConfigModule>

#ifndef VIRTUALKEYBOARD_H
#define VIRTUALKEYBOARD_H

class VirtualKeyboard : public KQuickAddons::ConfigModule
{
    Q_OBJECT
    Q_PROPERTY(LanguageModel *languageModel MEMBER m_langModel CONSTANT)

    Q_PROPERTY(bool spellCheck MEMBER m_spellCheck WRITE setSpellCheck NOTIFY spellCheckChanged)
    Q_PROPERTY(bool autoCapitalize MEMBER m_autoCapitalize WRITE setAutoCapitalize NOTIFY autoCapitalizeChanged)
    Q_PROPERTY(bool autoCompleteOnSpace MEMBER m_autoCompleteOnSpace WRITE setAutoCompleteOnSpace NOTIFY autoCompleteOnSpaceChanged)
    Q_PROPERTY(bool showSuggestions MEMBER m_showSuggestions WRITE setShowSuggestions NOTIFY showSuggestionsChanged)
    Q_PROPERTY(bool fullStopOnDoubleSpace MEMBER m_fullStopOnDoubleSpace WRITE setFullStopOnDoubleSpace NOTIFY fullStopOnDoubleSpaceChanged)

    Q_PROPERTY(bool soundFeedback MEMBER m_soundFeedback WRITE setSoundFeedback NOTIFY soundFeedbackChanged)
    Q_PROPERTY(bool vibrateFeedback MEMBER m_vibrateFeedback WRITE setVibrateFeedback NOTIFY vibrateFeedbackChanged)

public:
    VirtualKeyboard(QObject *parent, const QVariantList &args);

    void setSpellCheck(bool enabled);
    void setAutoCapitalize(bool enabled);
    void setAutoCompleteOnSpace(bool enabled);
    void setShowSuggestions(bool enabled);
    void setFullStopOnDoubleSpace(bool enabled);

    void setSoundFeedback(bool enabled);
    void setVibrateFeedback(bool enabled);

Q_SIGNALS:
    void spellCheckChanged();
    void autoCapitalizeChanged();
    void autoCompleteOnSpaceChanged();
    void showSuggestionsChanged();
    void fullStopOnDoubleSpaceChanged();
    void soundFeedbackChanged();
    void vibrateFeedbackChanged();

private:
    GSettingsItem *m_gsettings;
    LanguageModel *m_langModel;

    // spell check
    bool m_spellCheck;
    bool m_autoCapitalize;
    bool m_autoCompleteOnSpace;
    bool m_showSuggestions;
    bool m_fullStopOnDoubleSpace;

    // feedback
    bool m_soundFeedback;
    bool m_vibrateFeedback;
};

#endif
