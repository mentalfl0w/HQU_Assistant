#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QQuickWindow>
#include <QProcess>
#include <FramelessHelper/Quick/framelessquickmodule.h>
#include <FramelessHelper/Core/private/framelessconfig_p.h>
#include "language/Lang.h"
#include "AppInfo.h"
#include "qmlhttprequest.hpp"
#include "fileio.h"
#include "config.h"

FRAMELESSHELPER_USE_NAMESPACE
#ifdef FLUENTUI_BUILD_STATIC_LIB
Q_IMPORT_PLUGIN(FluentUIPlugin)
#endif
int main(int argc, char *argv[])
{
    //将样式设置为Basic，不然会导致组件显示异常
    qputenv("QT_QUICK_CONTROLS_STYLE","Basic");
    //6.4及以下监听系统深色模式变化
    FramelessHelper::Quick::initialize();
    QCoreApplication::setOrganizationName("mentalfl0wLabs");
    QCoreApplication::setOrganizationDomain("https://blog.ourdocs.cn");
    QCoreApplication::setApplicationName("HQU助手");

    QGuiApplication app(argc, argv);
#ifdef Q_OS_WIN // 此设置仅在Windows下生效
    FramelessConfig::instance()->set(Global::Option::ForceHideWindowFrameBorder);
#endif
    FramelessConfig::instance()->set(Global::Option::DisableLazyInitializationForMicaMaterial);
    FramelessConfig::instance()->set(Global::Option::CenterWindowBeforeShow);
    FramelessConfig::instance()->set(Global::Option::ForceNonNativeBackgroundBlur);
    FramelessConfig::instance()->set(Global::Option::EnableBlurBehindWindow);
#ifdef Q_OS_MACOS
    FramelessConfig::instance()->set(Global::Option::ForceNonNativeBackgroundBlur,false);
#endif
    app.setQuitOnLastWindowClosed(false);
    QQmlApplicationEngine engine;
    FramelessHelper::Quick::registerTypes(&engine);
    AppInfo* appInfo = new AppInfo();
    QQmlContext * context = engine.rootContext();
    Lang* lang = appInfo->lang();
    context->setContextProperty("lang",lang);
    QObject::connect(appInfo,&AppInfo::langChanged,&app,[context,appInfo]{
        context->setContextProperty("lang",appInfo->lang());
    });
    context->setContextProperty("appInfo",appInfo);
#ifdef FLUENTUI_BUILD_STATIC_LIB
    engine.addImportPath("qrc:/"); // 让静态资源可以被QML引擎搜索到
#endif
    qmlRegisterType<FileIO>("FileIO",1,0,"FileIO");
    qmlRegisterSingletonType<Config>("Config",1,0,"Config", [=](QQmlEngine* qmlEngine, QJSEngine* jsEngine)->Config*{
        Q_UNUSED(qmlEngine)
        Q_UNUSED(jsEngine)
        Config* instance = new Config();
        return instance;
    });
    qmlRegisterSingletonType<qhr::QmlHttpRequest>("QmlHttpRequest", 1,0, "QmlHttpRequest", qhr::QmlHttpRequest::create);
    const QUrl url(QStringLiteral("qrc:/HQU_Assistant/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
