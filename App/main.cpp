// Copyright (C) 2024 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QTimer>
#include <QFile>
#include <QDebug>

#include "autogen/environment.h"

int main(int argc, char *argv[])
{
    set_qt_environment();
    qputenv("QML_XHR_ALLOW_FILE_READ", "1");
    qputenv("QT_IMAGEIO_MAXALLOC", "1024");
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("LunarNavigator");
    QCoreApplication::setApplicationName("LunarNavigator");
    QCoreApplication::setApplicationVersion("1.0");

    QQmlApplicationEngine engine;
    const QUrl url(mainQmlFile);
    QObject::connect(
                &engine, &QQmlApplicationEngine::objectCreated, &app,
                [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");
    engine.load(url);

    if (engine.rootObjects().isEmpty())
        return -1;

    if (app.arguments().contains("--smoke-test")) {
        QTimer::singleShot(2500, &app, [&engine]() {
            const auto scene = engine.rootObjects().first()->findChild<QObject *>("sceneView");
            const bool assetsExist = QFile::exists(":/qt/qml/HackathonContent/assets/lander.glb")
                && QFile::exists(":/qt/qml/HackathonContent/assets/moon-nasa.jpg")
                && QFile::exists(":/qt/qml/HackathonContent/assets/science/moon-topography.glb")
                && QFile::exists(":/qt/qml/HackathonContent/assets/science/heights/global-0-0.bin")
                && QFile::exists(":/qt/qml/HackathonContent/assets/earth-nasa.jpg");
            const bool ready = scene && scene->property("landerReady").toBool()
                && scene->property("moonReady").toBool()
                && scene->property("assetError").toString().isEmpty() && assetsExist;
            qInfo() << (ready ? "Native smoke test passed" : "Native smoke test failed");
            QCoreApplication::exit(ready ? 0 : 2);
        });
    }

    return app.exec();
}
