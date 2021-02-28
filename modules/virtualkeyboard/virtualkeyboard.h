/*
 * SPDX-FileCopyrightText: 2020 Bhushan Shah <bshah@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "languagemodel.h"
#include <KQuickAddons/ConfigModule>

#include <QList>
#include <QString>

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
    
    Q_PROPERTY(QString theme MEMBER m_theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QStringList availableThemes MEMBER m_availableThemes NOTIFY availableThemesChanged)

public:
    VirtualKeyboard(QObject *parent, const QVariantList &args);

    void setSpellCheck(bool enabled);
    void setAutoCapitalize(bool enabled);
    void setAutoCompleteOnSpace(bool enabled);
    void setShowSuggestions(bool enabled);
    void setFullStopOnDoubleSpace(bool enabled);

    void setSoundFeedback(bool enabled);
    void setVibrateFeedback(bool enabled);

    void setTheme(QString theme);
    QStringList availableThemes();
    
Q_SIGNALS:
    void spellCheckChanged();
    void autoCapitalizeChanged();
    void autoCompleteOnSpaceChanged();
    void showSuggestionsChanged();
    void fullStopOnDoubleSpaceChanged();
    void soundFeedbackChanged();
    void vibrateFeedbackChanged();
    void themeChanged();
    void availableThemesChanged();

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
    
    // theme
    QString m_theme;
    QStringList m_availableThemes;
};

#endif
