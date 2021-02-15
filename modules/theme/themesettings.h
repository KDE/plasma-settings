/***************************************************************************
 *                                                                         *
 *   SPDX-FileCopyrightText: 2015 Sebastian Kügler <sebas@kde.org>                       *
 *                                                                         *
 *   SPDX-License-Identifier: GPL-2.0-or-later
 ***************************************************************************/

#ifndef THEMESETTINGS_H
#define THEMESETTINGS_H

#include <KQuickAddons/ConfigModule>
#include <QFont>
#include <QObject>
#include <QVariant>

namespace Plasma
{
class Theme;
}

class ThemeListModel;

class ThemeSettings : public KQuickAddons::ConfigModule
{
    Q_OBJECT

    Q_PROPERTY(QString themeName READ themeName WRITE setThemeName NOTIFY themeNameChanged)
    Q_PROPERTY(ThemeListModel *themeListModel READ themeListModel CONSTANT)
    Q_PROPERTY(int fontSize READ fontSize WRITE setFontSize NOTIFY fontSizeChanged)

public:
    ThemeSettings(QObject *parent, const QVariantList &args);
    ~ThemeSettings() override;

    QString themeName() const;
    void setThemeName(const QString &theme);

    int fontSize() const;
    void setFontSize(int pointSize);

    ThemeListModel *themeListModel();

Q_SIGNALS:
    void themeNameChanged();
    void fontSizeChanged();

private:
    Plasma::Theme *m_theme;
    QString m_themeName;
    ThemeListModel *m_themeListModel;

    QFont m_font;
};

#endif // THEMESETTINGS_H
