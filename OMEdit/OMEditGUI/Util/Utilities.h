/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-2014, Open Source Modelica Consortium (OSMC),
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

#include <QMdiArea>
#include <QThread>
#include <QToolButton>
#include <QComboBox>
#include <QPushButton>
#include <QFile>
#include <QLabel>
#include <QDoubleSpinBox>
#include <QCheckBox>
#include <QVariant>
#include <QAbstractMessageHandler>
#include <QDebug>
#include <QPlainTextEdit>
#include <QTextEdit>
#include <QProcess>
#include <QSettings>
#include <QFileIconProvider>
#include <QGroupBox>
#include <QListWidget>
#include <QListWidgetItem>

#ifdef WIN32
#include <windows.h>
#include <tlhelp32.h>
#endif

#ifndef UTILITIES_H
#define UTILITIES_H

class MainWindow;
class MdiArea : public QMdiArea
{
  Q_OBJECT
public:
  MdiArea(QWidget *pParent = 0);
  MainWindow* getMainWindow();
protected:
  MainWindow *mpMainWindow;
};

//! @brief Used to create platform independent sleep for the application.
class Sleep : public QThread
{
  Q_OBJECT
public:
  Sleep() {}
  ~Sleep() {}
  static void sleep(unsigned long secs) {QThread::sleep(secs);}
protected:
  void run() {}
};

class TreeSearchFilters : public QWidget
{
  Q_OBJECT
public:
  TreeSearchFilters(QWidget *pParent = 0);
  QLineEdit* getSearchTextBox() {return mpSearchTextBox;}
  QComboBox* getSyntaxComboBox() {return mpSyntaxComboBox;}
  QCheckBox* getCaseSensitiveCheckBox() {return mpCaseSensitiveCheckBox;}
  QPushButton* getExpandAllButton() {return mpExpandAllButton;}
  QPushButton* getCollapseAllButton() {return mpCollapseAllButton;}
private:
  QLineEdit *mpSearchTextBox;
  QToolButton *mpShowHideButton;
  QWidget *mpFiltersWidget;
  QComboBox *mpSyntaxComboBox;
  QCheckBox *mpCaseSensitiveCheckBox;
  QPushButton *mpExpandAllButton;
  QPushButton *mpCollapseAllButton;
private slots:
  void showHideFilters(bool On);
};

class FileDataNotifier : public QThread
{
  Q_OBJECT
public:
  FileDataNotifier(const QString fileName);
  void exit(int retcode = 0);
private:
  QFile mFile;
  bool mStop;
  qint64 mBytesAvailable;
protected:
  void run();
public slots:
  void start(Priority = InheritPriority);
signals:
  void bytesAvailable(qint64 bytes);
};

/*!
 * \class Label
 * \brief Creates a QLabel with elidable text. The default elide mode is Qt::ElideNone. Allows text selection via mouse.
 */
class Label : public QLabel
{
public:
  Label(QWidget *parent = 0, Qt::WindowFlags flags = 0);
  Label(const QString &text, QWidget *parent = 0, Qt::WindowFlags flags = 0);
  Qt::TextElideMode elideMode() const {return mElideMode;}
  void setElideMode(Qt::TextElideMode elideMode) {mElideMode = elideMode;}
  virtual QSize minimumSizeHint() const;
  virtual QSize sizeHint() const;
  void setText(const QString &text);
private:
  Qt::TextElideMode mElideMode;
  QString mText;
protected:
  virtual void resizeEvent(QResizeEvent *event);
};

//! @class DoubleSpinBox
/*! \brief Only keeping this class so that if in future we need to change the way QDoubleSpinBox works then we don't have to change the
 * forms controls again.
 */
/* Old Description */
/*! \brief It creates a double spinbox with a specified precision value.
 * If you want the precision value to be changed based on the global precision value defined in omedit.ini then connect this object with
 * the object of GeneralSettingsPage object right after creating this object. e.g,\n
 * connect(GeneralSettingsPage, SIGNAL(globalPrecisionValueChanged(int)), DoubleSpinBox, SLOT(handleGlobalPrecisionValueChange(int)));
 */
class DoubleSpinBox : public QDoubleSpinBox
{
  Q_OBJECT
public:
  DoubleSpinBox(QWidget *parent = 0) : QDoubleSpinBox(parent) {}
  /* old implementation
  DoubleSpinBox(int precision = 2, QWidget *parent = 0) : QDoubleSpinBox(parent) {setDecimals(precision);}
public slots:
  void handleGlobalPrecisionValueChange(int value) {setDecimals(value);}
  */
};

/*!
 * \class FixedCheckBox
 * \brief Creates a custom QCheckBox to represent the fixed modifier of components.
 */
class FixedCheckBox : public QCheckBox
{
  Q_OBJECT
private:
  bool mDefaultValue;
  bool mTickState;
public:
  FixedCheckBox(QWidget *parent = 0);
  void setTickState(bool defaultValue, bool tickStateString);
  bool tickState() {return mTickState;}
  QString tickStateString();
protected:
  virtual void paintEvent(QPaintEvent *event);
};

//! @struct RecentFile
/*! \brief It contains the recently opened file name and its encoding.
 * We must register this struct as a meta type since we need to use it as a QVariant.
 * This is used to store the recent files information in omedit.ini file.
 * The QDataStream also needed to be defined for this struct.
 */
struct RecentFile
{
  QString fileName;
  QString encoding;
  operator QVariant() const
  {
    return QVariant::fromValue(*this);
  }
};
Q_DECLARE_METATYPE(RecentFile)

inline QDataStream& operator<<(QDataStream& out, const RecentFile& recentFile)
{
  out << recentFile.fileName;
  out << recentFile.encoding;
  return out;
}

inline QDataStream& operator>>(QDataStream& in, RecentFile& recentFile)
{
  in >> recentFile.fileName;
  in >> recentFile.encoding;
  return in;
}

//! @struct FindTextOM
/*! \brief It contains the recently searched text from find/replace dialog .
 * We must register this struct as a meta type since we need to use it as a QVariant.
 * This is used to store the recent texts information in omedit.ini file.
 * The QDataStream also needed to be defined for this struct.
 */
struct FindTextOM
{
  QString text;
  operator QVariant() const
  {
    return QVariant::fromValue(*this);
  }
};
Q_DECLARE_METATYPE(FindTextOM)

inline QDataStream& operator<<(QDataStream& out, const FindTextOM& findText)
{
  out << findText.text;
  return out;
}

inline QDataStream& operator>>(QDataStream& in, FindTextOM& findText)
{
  in >> findText.text;
  return in;
}

//! @struct DebuggerConfiguration
/*! \brief It contains the debugger configuration settings  from debugger configuration dialog .
 * We must register this struct as a meta type since we need to use it as a QVariant.
 * This is used to store the debugger configuration settings information in omedit.ini file.
 * The QDataStream also needed to be defined for this struct.
 */
struct DebuggerConfiguration
{
  QString name;
  QString program;
  QString workingDirectory;
  QString GDBPath;
  QString arguments;
  operator QVariant() const
  {
    return QVariant::fromValue(*this);
  }
};
Q_DECLARE_METATYPE(DebuggerConfiguration)

inline QDataStream& operator<<(QDataStream& out, const DebuggerConfiguration& configurationSettings)
{
  out << configurationSettings.name;
  out << configurationSettings.program;
  out << configurationSettings.workingDirectory;
  out << configurationSettings.GDBPath;
  out << configurationSettings.arguments;
  return out;
}

inline QDataStream& operator>>(QDataStream& in, DebuggerConfiguration& configurationSettings)
{
  in >> configurationSettings.name;
  in >> configurationSettings.program;
  in >> configurationSettings.workingDirectory;
  in >> configurationSettings.GDBPath;
  in >> configurationSettings.arguments;
  return in;
}

/*!
 * \class MessageHandler
 * \brief Defines the appropriate error message of the parsed XML validated againast the XML Schema.\n
 * The class implementation and logic is inspired from Qt Creator sources.
 */
class MessageHandler : public QAbstractMessageHandler
{
public:
  MessageHandler() : QAbstractMessageHandler(0) {mFailed = false;}
  QString statusMessage() const { return mDescription;}
  int line() const { return mSourceLocation.line();}
  int column() const { return mSourceLocation.column();}
  void setFailed(bool failed) {mFailed = failed;}
  bool isFailed() {return mFailed;}
protected:
  virtual void handleMessage(QtMsgType type, const QString &description, const QUrl &identifier, const QSourceLocation &sourceLocation)
  {
    Q_UNUSED(type);
    Q_UNUSED(identifier);
    mDescription = description;
    mSourceLocation = sourceLocation;
  }
private:
  QString mDescription;
  QSourceLocation mSourceLocation;
  bool mFailed;
};

typedef struct {
  QString mDelay;
  QString mZf;
  QString mZfr;
  QString mAlpha;
} MetaModelConnection;

class PreviewPlainTextEdit : public QPlainTextEdit
{
  Q_OBJECT
public:
  PreviewPlainTextEdit(QWidget *parent = 0);
private:
  QTextCharFormat mParenthesesMatchFormat;
  QTextCharFormat mParenthesesMisMatchFormat;

  void highlightCurrentLine();
  void highlightParentheses();
public slots:
  void updateHighlights();
};

class ListWidgetItem : public QListWidgetItem
{
public:
  ListWidgetItem(QString text, QColor color, QListWidget *pParentListWidget);
  QColor getColor() {return mColor;}
  void setColor(QColor color) {mColor = color;}
private:
  QColor mColor;
};

class CodeColorsWidget : public QWidget
{
  Q_OBJECT
public:
  CodeColorsWidget(QWidget *pParent = 0);
  QListWidget* getItemsListWidget() {return mpItemsListWidget;}
  PreviewPlainTextEdit* getPreviewPlainTextEdit() {return mpPreviewPlainTextEdit;}
private:
  QGroupBox *mpColorsGroupBox;
  Label *mpItemsLabel;
  QListWidget *mpItemsListWidget;
  Label *mpItemColorLabel;
  QPushButton *mpItemColorPickButton;
  Label *mpPreviewLabel;
  PreviewPlainTextEdit *mpPreviewPlainTextEdit;
  ListWidgetItem *mpTextItem;
  ListWidgetItem *mpNumberItem;
  ListWidgetItem *mpKeywordItem;
  ListWidgetItem *mpTypeItem;
  ListWidgetItem *mpFunctionItem;
  ListWidgetItem *mpQuotesItem;
  ListWidgetItem *mpCommentItem;
signals:
  void colorUpdated();
private slots:
  void pickColor();
};

namespace Utilities {

  enum LineEndingMode {
    CRLFLineEnding = 0,
    LFLineEnding = 1,
    NativeLineEnding =
#ifdef WIN32
    CRLFLineEnding,
#else
    LFLineEnding
#endif
  };

  enum BomMode {
    AlwaysAddBom = 0,
    KeepBom = 1,
    AlwaysDeleteBom = 2
  };

  QString& tempDirectory();
  QSettings* getApplicationSettings();
  void parseMetaModelText(MessageHandler *pMessageHandler, QString contents);
  qreal convertUnit(qreal value, qreal offset, qreal scaleFactor);
  Label* getHeadingLabel(QString heading);
  QFrame* getHeadingLine();
  bool detectBOM(QString fileName);
  QTextCharFormat getParenthesesMatchFormat();
  QTextCharFormat getParenthesesMisMatchFormat();
  void highlightCurrentLine(QPlainTextEdit *pPlainTextEdit);
  void highlightParentheses(QPlainTextEdit *pPlainTextEdit, QTextCharFormat parenthesesMatchFormat, QTextCharFormat parenthesesMisMatchFormat);
  qint64 getProcessId(QProcess *pProcess);
#ifdef WIN32
  void killProcessTreeWindows(DWORD myprocID);
#endif
  bool isCFile(QString extension);
  bool isModelicaFile(QString extension);

  namespace FileIconProvider {
    class FileIconProviderImplementation : public QFileIconProvider
    {
    public:
      FileIconProviderImplementation();
      QIcon icon(const QFileInfo &info);
      using QFileIconProvider::icon;
      // Mapping of file suffix to icon.
      QHash<QString, QIcon> mIconsHash;
      QIcon mUnknownFileIcon;
    };
    // Access to the single instance
    QFileIconProvider *iconProvider();
    QIcon icon(const QFileInfo &info);
  } // namespace FileIconProvider

} // namespace Utilities

#endif // UTILITIES_H
