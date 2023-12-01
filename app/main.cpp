#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include "Translator.h"

// ref https://doc.qt.io/qt-6/scalability.html
int main(int argc, char *argv[]) {
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);                                               // 启用高 DPI 缩放
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);  // 设置缩放因子舍入策略
    QGuiApplication::setAttribute(Qt::AA_Use96Dpi, false);                                                    // 禁用默认的 96 DPI 缩放
    QGuiApplication app(argc, argv);

    app.setOrganizationName("cheungxiongwei");
    app.setOrganizationDomain("cheungxiongwei.com");
    app.setApplicationName("Translator");

    QTranslator translator;
    const QStringList uiLanguages = QLocale::system().uiLanguages();
    for(const QString &locale: uiLanguages) {
        const QString baseName = "Translator_" + QLocale(locale).name();
        if(translator.load(":/i18n/" + baseName)) {
            app.installTranslator(&translator);
            break;
        }
    }

    qreal scaleFactor = app.devicePixelRatio();
    qDebug() << "Device Pixel Ratio: " << scaleFactor;

    QQmlApplicationEngine engine;

    qmlRegisterType<Translator>("Translator", 1, 0, "Translator");
    qmlRegisterAnonymousType<BasicData>("Translator", 1);

    QObject::connect(
      &engine,
      &QQmlApplicationEngine::objectCreated,
      &app,
      [](QObject *object, const QUrl &) {
          if(!object) QCoreApplication::exit(-1);
      },
      Qt::QueuedConnection);
    engine.addImportPath("qrc:/");
    engine.load("qrc:/main.qml");

    return app.exec();
}
