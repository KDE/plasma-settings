/*
    Copyright (C) 2015  Martin Klapetek <mklapetek@kde.org>

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

#include "carddav-plugin.h"
#include "carddav_p.h"
#include "syncer_p.h"

// #include <KSharedConfig>
// #include <KConfigGroup>

#include <KJob>

// #include <QTimer>

#include <Accounts/Service>
#include <Accounts/Manager>
#include <Accounts/Account>
#include <Accounts/AccountService>

#include <KAccounts/getcredentialsjob.h>
#include <KAccounts/core.h>

class KAccountsCardDavPlugin::Private {
public:
    Private(KAccountsCardDavPlugin *qq) { q = qq; };

    KAccountsCardDavPlugin *q;
};


//---------------------------------------------------------------------------------------

KAccountsCardDavPlugin::KAccountsCardDavPlugin(QObject *parent)
    : KAccountsDPlugin(parent),
      d(new Private(this))
{
}

KAccountsCardDavPlugin::~KAccountsCardDavPlugin()
{
}

void KAccountsCardDavPlugin::onAccountCreated(const Accounts::AccountId accountId, const Accounts::ServiceList &serviceList)
{
    Accounts::Account *account = KAccounts::accountsManager()->account(accountId);

    if (!account) {
        qWarning() << "Invalid account for id" << accountId;
        return;
    }

    Q_FOREACH (const Accounts::Service &service, serviceList) {
        account->selectService(service);
        if (service.serviceType() == QLatin1String("dav-contacts") && account->isEnabled()) {
            qDebug() << "Starting carddav contacts import for account" << accountId << "and service" << service.serviceType();
            getCredentials(accountId);
        }
    }
}

void KAccountsCardDavPlugin::onAccountRemoved(const Accounts::AccountId accountId)
{
}

void KAccountsCardDavPlugin::onServiceEnabled(const Accounts::AccountId accountId, const Accounts::Service &service)
{
}

void KAccountsCardDavPlugin::onServiceDisabled(const Accounts::AccountId accountId, const Accounts::Service &service)
{
}

void KAccountsCardDavPlugin::getCredentials(const Accounts::AccountId accountId)
{
    GetCredentialsJob *credentialsJob = new GetCredentialsJob(accountId, this);
    connect(credentialsJob, &GetCredentialsJob::finished, this, &KAccountsCardDavPlugin::importContacts);
    credentialsJob->start();
}

void KAccountsCardDavPlugin::importContacts(KJob *job)
{
    GetCredentialsJob *credentialsJob = qobject_cast<GetCredentialsJob*>(job);
    job->deleteLater();

    if (!credentialsJob) {
        return;
    }

    const QVariantMap &data = credentialsJob->credentialsData();
    Accounts::Account *account = KAccounts::accountsManager()->account(credentialsJob->accountId());

    if (!account) {
        return;
    }

    QUrl carddavUrl = account->value("carddavUrl").toUrl();

    qDebug() << "Using: host:" << carddavUrl.host() << "path:" << carddavUrl.path();

    Syncer *s = new Syncer(0);

    const QString &userName = data.value("AccountUsername").toString();

    CardDav *m_cardDav = new CardDav(s,
                                     carddavUrl.host(),
                                     carddavUrl.path(),
                                     userName,
                                     data.value("Secret").toString());

    QObject::connect(m_cardDav, SIGNAL(remoteChanges(QList<KContacts::Addressee>,QList<KContacts::Addressee>,QList<KContacts::Addressee>)),
                     s, SLOT(continueSync(QList<KContacts::Addressee>,QList<KContacts::Addressee>,QList<KContacts::Addressee>)));
    QObject::connect(m_cardDav, SIGNAL(upsyncCompleted()),
                     s, SLOT(syncFinished()));
    QObject::connect(m_cardDav, SIGNAL(error(int)),
                     s, SLOT(cardDavError(int)));

    m_cardDav->determineRemoteAMR();
}
