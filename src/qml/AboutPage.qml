/*
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import org.kde.kirigamiaddons.formcard as FormCard
import org.kde.coreaddons as KCA

FormCard.AboutPage {
    id: aboutPage
    aboutData: KCA.AboutData
}
