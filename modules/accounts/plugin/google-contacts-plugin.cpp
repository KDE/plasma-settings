/*
    Copyright (C) 2014  Martin Klapetek <mklapetek@kde.org>

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#include "google-contacts-plugin.h"


#include <KSharedConfig>
#include <KConfigGroup>

#include <QTimer>
#include <QStandardPaths>
#include <QDir>
#include <QDBusConnection>
#include <QStringBuilder>
#include <QDebug>
#include <QFile>
#include <QTextStream>

#include <Accounts/Service>
#include <Accounts/Manager>
#include <Accounts/Account>
#include <Accounts/AccountService>
#include <SignOn/IdentityInfo>
#include <SignOn/Identity>

#include <KAccounts/getcredentialsjob.h>
#include <KAccounts/core.h>

#include <kgapi/contacts/contact.h>
#include <kgapi/contacts/contactfetchjob.h>
#include <kgapi/authjob.h>
#include <kgapi/account.h>


#include <KAccounts/getcredentialsjob.h>
#include <KAccounts/core.h>
#include <Accounts/Account>
#include <Accounts/Manager>
#include <KContacts/VCardConverter>

class GoogleContactsPlugin::Private {
public:
    Private() {};

    KGAPI2::AccountPtr account;
    Accounts::AccountId accountId;
};


//---------------------------------------------------------------------------------------

Q_GLOBAL_STATIC_WITH_ARGS(QString, vcardsLocation, (QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + ("/kpeoplevcard")))

GoogleContactsPlugin::GoogleContactsPlugin(QObject *parent)
    : KAccountsDPlugin(parent),
      d(new Private())
{

}

GoogleContactsPlugin::~GoogleContactsPlugin()
{
}

void GoogleContactsPlugin::onAccountCreated(const Accounts::AccountId accountId, const Accounts::ServiceList &serviceList)
{
    Q_UNUSED(serviceList);
    qDebug() << "New account created";
    d->accountId = accountId;

    Accounts::Account *acc = Accounts::Account::fromId(KAccounts::accountsManager(), accountId);
    if (acc && acc->providerName() == QLatin1String("google")) {
        GetCredentialsJob *job = new GetCredentialsJob(accountId, QStringLiteral("oauth2"), QStringLiteral("web_server"), this);
        connect(job, SIGNAL(finished(KJob*)), SLOT(onCredentialsReceived(KJob*)));
        job->start();
    } else {
        qWarning() << "Account is either invalid or not a google account (account is" << (acc ? acc->providerName() : "");
    }
}

void GoogleContactsPlugin::onCredentialsReceived(KJob *kjob)
{
    qDebug() << "Credentials retrieved, setting up google auth";
    GetCredentialsJob *job = qobject_cast< GetCredentialsJob* >(kjob);
    QVariantMap credentialsData = job->credentialsData();

    d->account = KGAPI2::AccountPtr(new KGAPI2::Account(credentialsData["AccountUsername"].toString(), credentialsData["AccessToken"].toString()));
    d->account->setScopes(QList<QUrl>() << KGAPI2::Account::contactsScopeUrl());

    KGAPI2::ContactFetchJob *fetchJob = new KGAPI2::ContactFetchJob(d->account, this);
    connect(fetchJob, SIGNAL(finished(KGAPI2::Job*)),
            this, SLOT(slotFetchJobFinished(KGAPI2::Job*)));
}

void GoogleContactsPlugin::slotFetchJobFinished(KGAPI2::Job *job)
{
    KGAPI2::ContactFetchJob *fetchJob = qobject_cast<KGAPI2::ContactFetchJob*>(job);
    Q_ASSERT(fetchJob);
    fetchJob->deleteLater();

    if (fetchJob->error() != KGAPI2::NoError) {
        qDebug() << "Error while fetching contacts:" << fetchJob->errorString();
        return;
    }

    qDebug() << "All set, starting vcards import into" << (*vcardsLocation);

    /* Get all items the job has retrieved */
    const KGAPI2::ObjectsList objects = fetchJob->items();

    KContacts::VCardConverter exporter;

    QDir vcardsDir(*vcardsLocation + "/" + QString::number(d->accountId));
    vcardsDir.mkpath(*vcardsLocation);

    Q_FOREACH (const KGAPI2::ObjectPtr &object, objects) {
        const KGAPI2::ContactPtr contact = object.dynamicCast<KGAPI2::Contact>();
        QStringList splits = contact->uid().split("/");
        QFile file(*vcardsLocation + "/" + splits.last() + ".vcard");
        qDebug() << "Writing to location" << file.fileName();

        bool opened = file.open(QIODevice::WriteOnly | QIODevice::Append);
        Q_ASSERT(opened);

        QTextStream out(&file);
        out << exporter.createVCard(*(contact.data()));
        //qDebug() << ">>>>>>>>>>" << contact->name() << (contact->phoneNumbers().isEmpty() ? "" : contact->phoneNumbers().first().number()) << (contact->emails().isEmpty() ? "" : contact->emails().first()) << contact->uid();
        out.flush();
    }
}


void GoogleContactsPlugin::onAccountRemoved(const Accounts::AccountId accountId)
{
    Q_UNUSED(accountId);
}

void GoogleContactsPlugin::onServiceEnabled(const Accounts::AccountId accountId, const Accounts::Service &service)
{
    Q_UNUSED(accountId);
    Q_UNUSED(service);
}

void GoogleContactsPlugin::onServiceDisabled(const Accounts::AccountId accountId, const Accounts::Service &service)
{
    Q_UNUSED(accountId);
    Q_UNUSED(service);
}
