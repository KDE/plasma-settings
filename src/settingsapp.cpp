/*

    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "settingsapp.h"

#include <QDebug>
#include <QQmlContext>
#include <QQmlEngine>

#include <KDBusService>

#include <KLocalizedString>

using namespace Qt::Literals::StringLiterals;

SettingsApp::SettingsApp(QObject *parent)
    : QObject(parent)
    , m_activeModule{new Module{}}
{
}

void SettingsApp::init(QCommandLineParser &parser, QString startModule, bool singleModule)
{
    m_parser = &parser;
    m_startModule = startModule;
    m_singleModule = singleModule;

    setupKDBus();

    m_model = new ModulesModel(this);
    // Have top level KCMs be shown, not just categories (which are their parent)
    for (MenuItem *child : m_model->rootItem()->children()) {
        m_model->addException(child);
    }

    m_categoryModel = new ModulesProxyModel(this);
    m_categoryModel->setCategorizedModel(true);
    m_categoryModel->setSourceModel(m_model);
    m_categoryModel->sort(0);
    m_categoryModel->setFilterHighlightsEntries(false);

    m_flatModel = new KDescendantsProxyModel(this);
    m_flatModel->setSourceModel(m_model);

    m_searchModel = new ModulesProxyModel(this);
    m_searchModel->setCategorizedModel(true);
    m_searchModel->setFilterHighlightsEntries(false);
    m_searchModel->setSourceModel(m_flatModel);

    m_subCategoryModel = new SubcategoryModel(m_categoryModel, this);

    if (!startModule.isEmpty()) {
        loadModuleById(startModule);
    }
}

SettingsApp::~SettingsApp() = default;

void SettingsApp::setupKDBus()
{
    QCoreApplication::setOrganizationDomain(u"kde.org"_s);
    KDBusService *service = new KDBusService(KDBusService::Unique, this);

    QObject::connect(service, &KDBusService::activateRequested, this, [this](const QStringList &arguments, const QString & /*workingDirectory*/) {
        qDebug() << "activateRequested" << arguments;
        m_parser->parse(arguments);

        if (m_parser->isSet(u"module"_s)) {
            const QString module = m_parser->value(u"module"_s);
            qDebug() << "Loading module:" << module;

            loadModuleById(module);
            Q_EMIT moduleChangeRequested();
        }

        Q_EMIT activateRequested();
    });
}

QString SettingsApp::filterString() const
{
    return m_filterString;
}

void SettingsApp::setFilterString(QString filterString)
{
    m_filterString = filterString;
    m_searchModel->setFilterString(m_filterString);
    Q_EMIT filterStringChanged();
}

ModulesProxyModel *SettingsApp::categoryModel()
{
    return m_categoryModel;
}

SubcategoryModel *SettingsApp::subCategoryModel()
{
    return m_subCategoryModel;
}

ModulesProxyModel *SettingsApp::searchModel()
{
    return m_searchModel;
}

int SettingsApp::activeCategoryRow() const
{
    return m_activeCategoryRow;
}

int SettingsApp::activeSearchRow() const
{
    return m_activeSearchRow;
}

int SettingsApp::activeSubCategoryRow() const
{
    return m_activeSubCategoryRow;
}

Module *SettingsApp::activeModule()
{
    return m_activeModule;
}

void SettingsApp::loadModuleById(QString id)
{
    QModelIndex index;
    int subCategoryIndex = -1;

    // Find start module in model
    for (int i = 0; i < m_categoryModel->rowCount(); ++i) {
        QModelIndex tempIndex = m_categoryModel->index(i, 0);
        auto mi = tempIndex.data(ModulesModel::MenuItemRole).value<MenuItem *>();
        if (!mi) {
            continue;
        }

        // Check if kcm id matches
        if (mi->id() == id) {
            index = tempIndex;
            break;
        } else if (mi->menu()) {
            // If it's a category, loop over subcategory kcms
            auto children = m_model->childrenList(mi);

            for (int j = 0; j < children.size(); ++j) {
                if (children[j]->id() == id) {
                    index = tempIndex;
                    subCategoryIndex = j;
                    break;
                }
            }

            if (index == tempIndex) {
                break;
            }
        }
    }

    // Load module
    if (index.isValid()) {
        qDebug() << "found module";
        loadModule(index);

        // If it's a subcategory, load the kcm
        if (subCategoryIndex != -1) {
            loadModule(m_subCategoryModel->index(subCategoryIndex, 0));
            Q_EMIT subCategoryRequested();
        }
    } else {
        qDebug() << "unable to find module" << id;
    }
}

void SettingsApp::loadModule(const QModelIndex &activeModule, const QStringList &args)
{
    if (!activeModule.isValid()) {
        return;
    }

    auto mi = activeModule.data(ModulesModel::MenuItemRole).value<MenuItem *>();
    if (!mi) {
        return;
    }

    if (activeModule.model() == m_categoryModel) {
        // Update sub category model to reflect selected top level category
        m_subCategoryModel->setParentIndex(activeModule);

        m_activeCategoryRow = activeModule.row();
        m_activeSubCategoryRow = 0;

        Q_EMIT activeCategoryRowChanged();
        Q_EMIT activeSubCategoryRowChanged();

        bool isCategory = mi->menu();
        if (isCategory) {
            // Load first KCM in subcategory
            mi = m_subCategoryModel->index(0, 0).data(ModulesModel::MenuItemRole).value<MenuItem *>();
        }

        m_activeModule->setIsInSubCategory(isCategory);

    } else if (activeModule.model() == m_searchModel) {
        QModelIndex originalIndex = m_categoryModel->mapFromSource(m_flatModel->mapToSource(m_searchModel->mapToSource(activeModule)));

        if (originalIndex.isValid()) {
            // are we in a subcategory of the top categories?
            if (originalIndex.parent().isValid() && mi->parent()->menu()) {
                m_activeCategoryRow = originalIndex.parent().row();
                m_activeSubCategoryRow = originalIndex.row();
            } else {
                m_activeCategoryRow = originalIndex.row();
                m_activeSubCategoryRow = 0;
            }

            m_subCategoryModel->setParentIndex(originalIndex.parent().isValid() ? originalIndex.parent() : originalIndex);
            Q_EMIT activeCategoryRowChanged();
            Q_EMIT activeSubCategoryRowChanged();

            bool isCategory = mi->menu();
            if (isCategory) {
                // Load first KCM in subcategory
                mi = m_subCategoryModel->index(0, 0).data(ModulesModel::MenuItemRole).value<MenuItem *>();
            }
        }

        m_activeSearchRow = activeModule.row();
        Q_EMIT activeSearchRowChanged();

        // TODO?
        m_activeModule->setIsInSubCategory(false);

    } else if (activeModule.model() == m_subCategoryModel) {
        m_activeSubCategoryRow = activeModule.row();
        Q_EMIT activeSubCategoryRowChanged();

        m_activeModule->setIsInSubCategory(true);
    }

    if (!mi) {
        return;
    }

    // Load KCM
    m_activeModule->setPath(mi->id());
}

SubcategoryModel::SubcategoryModel(QAbstractItemModel *parentModel, SettingsApp *parent)
    : KSelectionProxyModel(nullptr, parent)
    , m_parentModel(parentModel)
    , m_settingsApp{parent}
{
    setSourceModel(parentModel);
    setSelectionModel(new QItemSelectionModel(parentModel, this));
    setFilterBehavior(SubTreesWithoutRoots);
}

QString SubcategoryModel::title() const
{
    auto const *mi = m_activeModuleIndex.data(ModulesModel::MenuItemRole).value<MenuItem *>();

    if (!mi) {
        return {};
    }

    return mi->name();
}

QIcon SubcategoryModel::icon() const
{
    return m_activeModuleIndex.data(Qt::DecorationRole).value<QIcon>();
}

bool SubcategoryModel::categoryOwnedByKCM() const
{
    return m_activeModuleIndex.data(ModulesModel::IsKCMRole).toBool();
}

void SubcategoryModel::setParentIndex(const QModelIndex &activeModule)
{
    selectionModel()->select(activeModule, QItemSelectionModel::ClearAndSelect);
    m_activeModuleIndex = QPersistentModelIndex(activeModule);
    Q_EMIT titleChanged();
    Q_EMIT iconChanged();
    Q_EMIT categoryOwnedByKCMChanged();

    auto mi = data(index(0, 0), Qt::DisplayRole);
}
