#include <QDebug>
#include <QFileInfo>

#include "livereload.h"

LiveReload::LiveReload(QObject *parent) : QObject(parent)
{
    connect(&watcher, SIGNAL(directoryChanged(const QString &)),
            this, SLOT(fileChanged(const QString &)));
    connect(&watcher, SIGNAL(fileChanged(const QString &)),
            this, SLOT(fileChanged(const QString &)));
}

void LiveReload::fileChanged(const QString & path){
    qDebug() << "file changed: " << path;
    emit fileChanged();
}

QString LiveReload::path() const
{
    return m_path;
}

void LiveReload::setPath(const QString &path)
{
    if (path != m_path) {
        m_path = path;

        QFileInfo file(m_path);
        watcher.addPath(file.path());
        watcher.addPath(file.filePath());

        emit pathChanged();
    }
}
