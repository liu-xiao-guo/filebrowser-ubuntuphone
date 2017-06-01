#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QFileInfo>
#include <QTextCodec>

const QString tag1 = "<font color=\"red\"><strong>";
const QString tag2 = "</strong></font>";

FileIO::FileIO(QObject *parent) : QObject(parent)
{
    datapath = getenv("TMPDIR")  + "/";
    qDebug() << "datapath: " + datapath;
}

QStringList FileIO::read(QString keyword)
{    
    qDebug() << "reading ....!" << "keyword: " << keyword;
    qDebug() << "source: " << mSource;

    if ( mSource.isEmpty() ) {
        emit error("source is empty");
        return QStringList();
    }

    QFile file(mSource);
    QFileInfo fileInfo(file);
    qDebug() << "file path: " << fileInfo.absoluteFilePath();
    qDebug() << "absolute path: " << fileInfo.absolutePath();

    QStringList fileContent;
    int index = 0;
    if ( file.open(QIODevice::ReadOnly | QIODevice::Text ) ) {
        QString line;

        QTextStream t( &file );

        do {
            line = t.readLine();

            // Check if the line contains the keyword
            index = line.indexOf(keyword, 0, Qt::CaseInsensitive);
            if ( index != -1) {

                // we found a match, then we do something about it
                if ( keyword != "" ) {
                    QString result;
                    QString first = line.left(index);
                    result += first;
                    result += tag1;
                    QString middle = line.mid(index, keyword.length());
                    result += middle;
                    result += tag2;
                    QString last = line.right(line.length() - (index + keyword.length()));
                    result += last;
                    fileContent << result;
                } else {
                    fileContent << line;
                }
            }

        } while (!line.isNull());

        file.close();
        // qDebug() << fileContent;
        qDebug() << "number of lines: " << fileContent.count();
        return fileContent;
    } else {
        emit error("Unable to open the file");
        return QStringList();
    }
}

QString FileIO::readString()
{
    qDebug() << "reading ....!";
    qDebug() << "source: " << mSource;

    if ( mSource.isEmpty() ) {
        emit error("source is empty");
        return "";
    }

    QFile file(mSource);
    QFileInfo fileInfo(file);
    qDebug() << "file path: " << fileInfo.absoluteFilePath();
    qDebug() << "absolute path: " << fileInfo.absolutePath();

    QString fileContent;
    if ( file.open(QIODevice::ReadOnly | QIODevice::Text ) ) {
        QString line;

        QTextStream t( &file );

        do {
            line = t.readLine();

            fileContent += line + "\n";

        } while (!line.isNull());

        file.close();
        return fileContent;
    } else {
        emit error("Unable to open the file");
        return "";
    }
}

bool FileIO::write(const QString& data)
{
    qDebug() << "writing.....";

    if (mSource.isEmpty())
        return false;

    QFile file(datapath + mSource);
    QFileInfo fileInfo(file.fileName());
    qDebug() << "file path: " << fileInfo.absoluteFilePath();
    if (!file.open(QFile::WriteOnly | QFile::Truncate))
        return false;

    QTextStream out(&file);
    out << data;

    file.close();

    return true;
}

QString FileIO::getenv(const QString envVarName) const
{
    QByteArray result = qgetenv(envVarName.toStdString().c_str());
    QString output = QString::fromLocal8Bit(result);
    qDebug() << envVarName << " value is: "  << output;
    return output;
}
