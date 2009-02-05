/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-2008, Link�pings University,
 * Department of Computer and Information Science,
 * SE-58183 Link�ping, Sweden.
 *
 * All rights reserved.
 *
 * THIS PROGRAM IS PROVIDED UNDER THE TERMS OF THIS OSMC PUBLIC
 * LICENSE (OSMC-PL). ANY USE, REPRODUCTION OR DISTRIBUTION OF
 * THIS PROGRAM CONSTITUTES RECIPIENT'S ACCEPTANCE OF THE OSMC
 * PUBLIC LICENSE.
 *
 * The OpenModelica software and the Open Source Modelica
 * Consortium (OSMC) Public License (OSMC-PL) are obtained
 * from Link�pings University, either from the above address,
 * from the URL: http://www.ida.liu.se/projects/OpenModelica
 * and in the OpenModelica distribution.
 *
 * This program is distributed  WITHOUT ANY WARRANTY; without
 * even the implied warranty of  MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
 * IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS
 * OF OSMC-PL.
 *
 * See the full OSMC Public License conditions for more details.
 *
 * For more information about the Qt-library visit TrollTech's webpage 
 * regarding the Qt licence: http://www.trolltech.com/products/qt/licensing.html
 */


/*!
 * \file otherdlg.h
 * \author Anders Fernstr�m
 */

#ifndef OTHERDLG_H
#define OTHERDLG_H


#include "ui_OtherDlg.h"


namespace IAEX
{
	/*!
	 * \class OtherDlg
	 * \author Anders Fernstr�m
	 * \date 2005-11-04
	 *
	 * \breif Class of opening a dialog window for entering av value...
	 */
	class OtherDlg : public QDialog
	{
	public:
		OtherDlg( QWidget *parent, int min, int max)
			: QDialog(parent), min_(min), max_(max)
		{
			ui.setupUi(this);

			QString minW;
			QString maxW;
			minW.setNum( min_ );
			maxW.setNum( max_ );

			QString text = QString("Enter value (") + minW +
				QString("-") + maxW + QString(")");

			ui.label->setText( text );
		}
		virtual ~OtherDlg(){}
		int value()
		{
			bool ok;
			int value = ui.lineEdit->text().toInt(&ok);

			if(ok)
				if( min_ <= value && value <= max_ )
					return value;

			return -1;
		}

	private:
		Ui::Dialog ui;
		int min_;
		int max_;
	};
}

#endif
