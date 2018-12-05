/***************************************************************************
 *                                                                         *
 *   Copyright 2015 Sebastian Kügler <sebas@kde.org>                       *
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

#ifndef THEMESETTINGS_H
#define THEMESETTINGS_H

#include <QObject>
#include <QFont>
#include <QVariant>
#include <KQuickAddons/ConfigModule>

namespace Plasma {
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
        ThemeSettings(QObject* parent, const QVariantList& args);
        ~ThemeSettings() override;

        QString themeName() const;
        void setThemeName(const  QString &theme);

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
