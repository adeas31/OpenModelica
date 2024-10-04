/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-CurrentYear, Open Source Modelica Consortium (OSMC),
 * c/o Linköpings universitet, Department of Computer and Information Science,
 * SE-58183 Linköping, Sweden.
 *
 * All rights reserved.
 *
 * THIS PROGRAM IS PROVIDED UNDER THE TERMS OF GPL VERSION 3 LICENSE OR
 * THIS OSMC PUBLIC LICENSE (OSMC-PL) VERSION 1.2.
 * ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS PROGRAM CONSTITUTES
 * RECIPIENT'S ACCEPTANCE OF THE OSMC PUBLIC LICENSE OR THE GPL VERSION 3,
 * ACCORDING TO RECIPIENTS CHOICE.
 *
 * The OpenModelica software and the Open Source Modelica
 * Consortium (OSMC) Public License (OSMC-PL) are obtained
 * from OSMC, either from the above address,
 * from the URLs: http://www.ida.liu.se/projects/OpenModelica or
 * http://www.openmodelica.org, and in the OpenModelica distribution.
 * GNU version 3 is obtained from: http://www.gnu.org/copyleft/gpl.html.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without
 * even the implied warranty of  MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
 * IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS OF OSMC-PL.
 *
 * See the full OSMC Public License conditions for more details.
 *
 */
/*
 * @author Adeel Asghar <adeel.asghar@liu.se>
 */

#ifndef ELEMENTTREEWIDGET_H
#define ELEMENTTREEWIDGET_H

#include "Util/Utilities.h"
#include "Model.h"

#include <QTreeView>
#include <QSortFilterProxyModel>

class ElementTreeItem : public QObject
{
  Q_OBJECT
public:
  ElementTreeItem();
  ElementTreeItem(ModelInstance::Model *pModel, ElementTreeItem *pParentElementTreeItem = 0);
  ElementTreeItem(ModelInstance::Element *pElement, ElementTreeItem *pParentElementTreeItem = 0);
  ~ElementTreeItem();
  int childrenSize() const {return mChildren.size();}
  ElementTreeItem* child(int row) const {return row >= 0 && row < childrenSize() ? mChildren.at(row) : 0;}
  void insertChild(int position, ElementTreeItem *pElementTreeItem) {mChildren.insert(position, pElementTreeItem);}
  void removeChildren();
  QVariant data(int column, int role = Qt::DisplayRole) const;
  int row() const;
  ElementTreeItem* parent() const {return mpParentElementTreeItem;}
  QString getName() const {return mName;}
private:
  ElementTreeItem *mpParentElementTreeItem = 0;
  bool mIsRootItem = false;
  QList<ElementTreeItem*> mChildren;
  QString mName;
  QString mDisplayName;
  QString mTooltip;
};

class ElementWidget;
class ElementTreeProxyModel : public QSortFilterProxyModel
{
  Q_OBJECT
public:
  ElementTreeProxyModel(ElementWidget *pElementWidget);
private:
  ElementWidget *mpElementWidget;
protected:
  virtual bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const override;
};

class ElementTreeModel : public QAbstractItemModel
{
  Q_OBJECT
public:
  Q_DISABLE_COPY_MOVE(ElementTreeModel)
  ElementTreeModel(ElementWidget *pElementWidget);
  ~ElementTreeModel();
  int columnCount(const QModelIndex &parent = QModelIndex()) const override;
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
  QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
  QModelIndex parent(const QModelIndex & index) const override;
  QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const override;
  Qt::ItemFlags flags(const QModelIndex &index) const override;
  QModelIndex elementsTreeItemIndex(const ElementTreeItem *pElementTreeItem) const;
  void addElements(ModelInstance::Model *pModel, ElementTreeItem *pParentElementTreeItem = 0);
private:
  ElementWidget *mpElementWidget;
  ElementTreeItem* mpRootElementTreeItem;
  void addElementsHelper(ModelInstance::Model *pModel, ElementTreeItem *pParentElementTreeItem);
  QModelIndex elementsTreeItemIndexHelper(const ElementTreeItem *pElementTreeItem, const ElementTreeItem *pParentElementTreeItem, const QModelIndex &parentIndex) const;
};

class ElementTreeView : public QTreeView
{
  Q_OBJECT
public:
  ElementTreeView(ElementWidget *pElementWidget);
private:
  ElementWidget *mpElementWidget;
};

class ElementWidget : public QWidget
{
  Q_OBJECT
public:
  ElementWidget(QWidget *pParent = 0);
  ElementTreeModel* getElementTreeModel() {return mpElementTreeModel;}
  ElementTreeProxyModel* getElementTreeProxyModel() {return mpElementTreeProxyModel;}
  ElementTreeView* getElementTreeView() {return mpElementTreeView;}
private:
  TreeSearchFilters *mpTreeSearchFilters;
  ElementTreeModel *mpElementTreeModel;
  ElementTreeProxyModel *mpElementTreeProxyModel;
  ElementTreeView *mpElementTreeView;
private slots:
  void filterElements();
};

#endif // ELEMENTTREEWIDGET_H
