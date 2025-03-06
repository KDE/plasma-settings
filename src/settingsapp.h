/*

    SPDX-FileCopyrightText: 2009 Ben Cooksley <bcooksley@kde.org>
    SPDX-FileCopyrightText: 2011-2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2025 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QAbstractItemModel>
#include <QCommandLineParser>
#include <QIcon>
#include <QObject>
#include <QPersistentModelIndex>

#include <KDescendantsProxyModel>
#include <KSelectionProxyModel>
#include <qqmlintegration.h>

#include "module.h"
#include "modulesmodel.h"
#include "modulesproxymodel.h"

class SubcategoryModel;

class SettingsApp : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString startModule MEMBER m_startModule CONSTANT)
    Q_PROPERTY(bool singleModule MEMBER m_singleModule CONSTANT)

    Q_PROPERTY(QString filterString READ filterString WRITE setFilterString NOTIFY filterStringChanged)
    Q_PROPERTY(bool showAllModules READ showAllModules WRITE setShowAllModules NOTIFY showAllModulesChanged)

    Q_PROPERTY(ModulesProxyModel *categoryModel READ categoryModel CONSTANT)
    Q_PROPERTY(SubcategoryModel *subCategoryModel READ subCategoryModel CONSTANT)
    Q_PROPERTY(ModulesProxyModel *searchModel READ searchModel CONSTANT)

    Q_PROPERTY(int activeCategoryRow READ activeCategoryRow NOTIFY activeCategoryRowChanged)
    Q_PROPERTY(int activeSearchRow READ activeSearchRow NOTIFY activeSearchRowChanged)
    Q_PROPERTY(int activeSubCategoryRow READ activeSubCategoryRow NOTIFY activeSubCategoryRowChanged)
    Q_PROPERTY(Module *activeModule READ activeModule NOTIFY activeModuleChanged)

public:
    explicit SettingsApp(QObject *parent = nullptr);
    ~SettingsApp() override;

    void init(QCommandLineParser &parser, QString startModule, bool singleModule);

    void loadModuleById(QString id);
    Q_INVOKABLE void loadModule(const QModelIndex &activeModule, const QStringList &args = QStringList());

    QString filterString() const;
    void setFilterString(QString filterString);

    bool showAllModules() const;
    void setShowAllModules(bool showAllModules);

    ModulesProxyModel *categoryModel();
    SubcategoryModel *subCategoryModel();
    ModulesProxyModel *searchModel();

    int activeCategoryRow() const;
    int activeSearchRow() const;
    int activeSubCategoryRow() const;
    Module *activeModule();

Q_SIGNALS:
    void moduleChangeRequested();
    void activateRequested();

    void filterStringChanged();
    void showAllModulesChanged();
    void startModuleChanged();
    void singleModuleChanged();

    void activeCategoryRowChanged();
    void activeSearchRowChanged();
    void activeSubCategoryRowChanged();
    void activeModuleChanged();

    void subCategoryRequested();

private:
    void setupKDBus();
    QCommandLineParser *m_parser;

    QString m_startModule;
    bool m_singleModule;

    Module *m_activeModule{nullptr};

    QString m_filterString;
    bool m_showAllModules{false};

    int m_activeCategoryRow{0};
    int m_activeSearchRow{0};
    int m_activeSubCategoryRow{0};

    ModulesModel *m_model{nullptr};
    ModulesProxyModel *m_categoryModel{nullptr};
    SubcategoryModel *m_subCategoryModel{nullptr};
    ModulesProxyModel *m_searchModel{nullptr};
    KDescendantsProxyModel *m_flatModel{nullptr};
};

class SubcategoryModel : public KSelectionProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QIcon icon READ icon NOTIFY iconChanged)
    Q_PROPERTY(bool categoryOwnedByKCM READ categoryOwnedByKCM NOTIFY categoryOwnedByKCMChanged)

public:
    explicit SubcategoryModel(QAbstractItemModel *parentModel, SettingsApp *parent = nullptr);

    QString title() const;
    QIcon icon() const;
    bool categoryOwnedByKCM() const;

    void setParentIndex(const QModelIndex &activeModule);

Q_SIGNALS:
    void titleChanged();
    void iconChanged();
    void categoryOwnedByKCMChanged();

private:
    QAbstractItemModel *m_parentModel;
    QPersistentModelIndex m_activeModuleIndex;
    SettingsApp *m_settingsApp;
};
