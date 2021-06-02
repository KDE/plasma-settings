/**
 * SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "password.h"

#include <QDBusConnection>
#include <QDBusMessage>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>

#include <KAboutData>
#include <KLocalizedString>
#include <KPluginFactory>

#include <unistd.h>

#include "accounts_interface.h"
#include "user_interface.h"

K_PLUGIN_CLASS_WITH_JSON(Password, "metadata.json")

Password::Password(QObject *parent, const QVariantList &args)
    : KQuickAddons::ConfigModule(parent, args)
{
    KAboutData *about = new KAboutData("kcm_password", i18n("Lockscreen PIN"), "1.0", QString(), KAboutLicense::GPL);
    about->addAuthor(i18n("Tobias Fella"), QString(), "fella@posteo.de");
    setAboutData(about);
    setButtons(KQuickAddons::ConfigModule::NoAdditionalButton);
}

static char saltCharacter()
{
    static constexpr const quint32 letterCount = 64;
    static const char saltCharacters[] =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "./0123456789"; // and trailing NUL
    static_assert(sizeof(saltCharacters) == (letterCount + 1), // 64 letters and trailing NUL
                  "Salt-chars array is not exactly 64 letters long");

    const quint32 index = QRandomGenerator::system()->bounded(0u, letterCount);

    return saltCharacters[index];
}

static QString saltPassword(const QString &plain)
{
    QString salt;

    salt.append("$6$");

    for (auto i = 0; i < 16; i++) {
        salt.append(saltCharacter());
    }

    salt.append("$");

    auto stdStrPlain = plain.toStdString();
    auto cStrPlain = stdStrPlain.c_str();
    auto stdStrSalt = salt.toStdString();
    auto cStrSalt = stdStrSalt.c_str();

    auto salted = crypt(cStrPlain, cStrSalt);

    return QString::fromUtf8(salted);
}

void Password::setPassword(const QString &password)
{
    auto accountsInterface = new OrgFreedesktopAccountsInterface(QStringLiteral("org.freedesktop.Accounts"),
                                                                 QStringLiteral("/org/freedesktop/Accounts"),
                                                                 QDBusConnection::systemBus(),
                                                                 this);
    auto reply = accountsInterface->FindUserByName(qgetenv("USER"));
    reply.waitForFinished();

    if (reply.isError()) {
        qDebug() << "Error";
        return;
    }

    auto user = reply.value();

    auto userInterface = new OrgFreedesktopAccountsUserInterface(QStringLiteral("org.freedesktop.Accounts"), user.path(), QDBusConnection::systemBus(), this);

    userInterface->SetPassword(saltPassword(password), QString());
}

#include "password.moc"
