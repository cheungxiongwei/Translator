#pragma once

#include <QCryptographicHash>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QNetworkProxy>
#include <QObject>
#include <QQmlEngine>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>

#include <QFile>

class BasicData
{
    Q_GADGET
    Q_PROPERTY(QString query MEMBER query)
    Q_PROPERTY(QStringList examType MEMBER examType)
    Q_PROPERTY(QStringList explains MEMBER explains)
    Q_PROPERTY(QString phonetic MEMBER phonetic)
    Q_PROPERTY(QVariantList wfs MEMBER wfs)

public:
    QString query;         // 查询
    QStringList examType;  // 考试
    QStringList explains;  // 解释
    QString phonetic;      // 音标
    QVariantList wfs;      // 词性变换
};

Q_DECLARE_METATYPE(BasicData)

class Translator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QStringList sourceLanguage READ sourceLanguage WRITE setSourceLanguage NOTIFY sourceLanguageChanged)
    Q_PROPERTY(QStringList targetLanguage READ targetLanguage WRITE setTargetLanguage NOTIFY targetLanguageChanged)
    QML_ELEMENT

public:
    Translator(QObject *parent = nullptr)
      : QObject(parent)
      , mManager(new QNetworkAccessManager(this)) {
        mSourceLanguage = QStringList {"自动识别", "中文", "英文", "俄文"};
        mTargetLanguage = QStringList {"中文", "英文", "俄文"};

        // 填充语言映射
        mLanguageMap.insert("自动识别", "auto");
        mLanguageMap.insert("中文", "zh-CHS");
        mLanguageMap.insert("英文", "en");
        mLanguageMap.insert("俄文", "ru");
        // 以此类推，将其他语言也添加到映射中

        mManager->setProxy(QNetworkProxy::NoProxy);
        QObject::connect(mManager, &QNetworkAccessManager::finished, this, &Translator::onManagerFinished);
    }

    QStringList sourceLanguage() const { return mSourceLanguage; }

    void setSourceLanguage(const QStringList &newSourceLanguage) {
        if(mSourceLanguage == newSourceLanguage) return;
        mSourceLanguage = newSourceLanguage;
        emit sourceLanguageChanged();
    }

    QStringList targetLanguage() const { return mTargetLanguage; }

    void setTargetLanguage(const QStringList &newTargetLanguage) {
        if(mTargetLanguage == newTargetLanguage) return;
        mTargetLanguage = newTargetLanguage;
        emit targetLanguageChanged();
    }

public slots:

    void translate(const QString &sourceLanguage, const QString &targetLanguage, const QString &text) {
        const QString appKey    = qgetenv("TranslateAppId");           //"your_app_key";
        const QString appSecret = qgetenv("TranslateAppKey");          //"your_app_secret";
        const QString from      = mLanguageMap.value(sourceLanguage);  // 从语言映射中查出源语言的代码
        const QString to        = mLanguageMap.value(targetLanguage);  // 从语言映射中查出目标语言的代码

        QString salt    = QUuid::createUuid().toString().remove('{').remove('}').remove('-');
        QString curtime = QString::number(QDateTime::currentSecsSinceEpoch());

        QString input;
        if(text.length() <= 20) {
            input = text;
        } else {
            input = text.left(10) + QString::number(text.length()) + text.right(10);
        }

        QString signStr     = appKey + input + salt + curtime + appSecret;
        QByteArray signData = QCryptographicHash::hash(signStr.toUtf8(), QCryptographicHash::Sha256).toHex();

        QUrl url("https://openapi.youdao.com/api");
        QUrlQuery query;
        query.addQueryItem("q", text);
        query.addQueryItem("from", from);
        query.addQueryItem("to", to);
        query.addQueryItem("appKey", appKey);
        query.addQueryItem("salt", salt);
        query.addQueryItem("sign", signData);
        query.addQueryItem("signType", "v3");
        query.addQueryItem("curtime", curtime);
        url.setQuery(query);
        QNetworkRequest request(url);
        mManager->get(request);
    }

signals:
    void translationFinished(const QString &result);

    void translationWordFinished(const BasicData &result);

    void sourceLanguageChanged();

    void targetLanguageChanged();

private slots:

    void onManagerFinished(QNetworkReply *reply);

private:
    QNetworkAccessManager *mManager;
    QStringList mSourceLanguage;
    QStringList mTargetLanguage;
    QMap<QString, QString> mLanguageMap;  // 保存语言名到语言代码的映射
};
