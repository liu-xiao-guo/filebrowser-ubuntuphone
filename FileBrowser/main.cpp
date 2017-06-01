#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>

#include "DriveList.h"
#include "fileio.h"
#include "livereload.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    DriveList driveList;
    qmlRegisterType<FileIO>("FileIO", 1, 0, "FileIO");
    qmlRegisterType<LiveReload>("LiveReload", 1, 0, "LiveReload");

    QQuickView view;
    view.engine()->rootContext()->setContextProperty("DriveList", &driveList);
    view.setSource(QUrl(QStringLiteral("qrc:///Main.qml")));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.show();
    return app.exec();
}

