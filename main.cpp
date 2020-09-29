#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSslSocket>

#include "HttpPoster.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qDebug() << QString("SSL support: %1, build version: %2, system version: %3").arg(QSslSocket::supportsSsl() ? "yes" : "no").arg(
             QSslSocket::sslLibraryBuildVersionString()).arg(QSslSocket::sslLibraryVersionString());

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);


    engine.rootContext()->setContextProperty("cppHttpPoster",   HttpPoster::getInstance());

    engine.load(url);
    return app.exec();
}
