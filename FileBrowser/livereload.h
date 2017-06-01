#ifndef LIVERELOAD_H
#define LIVERELOAD_H

#include <QFileSystemWatcher>
#include <QObject>

class LiveReload : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)

public:
    explicit LiveReload(QObject *parent = 0);

    QString path() const;
    void setPath(const QString &path);

private slots:
    void fileChanged(const QString & path);

signals:
    void pathChanged();
    void fileChanged();

private:
    QFileSystemWatcher watcher;
    QString m_path;

};

#endif // LIVERELOAD_H
