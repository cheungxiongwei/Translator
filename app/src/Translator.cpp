#include "Translator.h"

void Translator::onManagerFinished(QNetworkReply *reply) {
    if(reply->error() != QNetworkReply::NoError) {
        // Handle error
        return;
    }

    QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());

    if constexpr(false) {
        QFile fs("ts.txt");
        fs.open(QFile::ReadWrite | QFile::Truncate | QFile::Text);
        fs.write(doc.toJson(QJsonDocument::Indented));
        fs.close();
    }

    QJsonObject obj = doc.object();

    if(obj["errorCode"].toInt() != 0) {
        emit translationFinished("404");
        return;
    }

    if(obj["isWord"].toBool()) {
        auto basic = obj["basic"].toObject();
        auto map   = basic.toVariantMap();

        BasicData data;
        data.query    = obj["query"].toString();
        data.examType = map["exam_type"].toStringList();
        data.explains = map["explains"].toStringList();
        data.phonetic = map["phonetic"].toString();

        if(map.contains("wfs")) {
            for(auto a = map["wfs"].toList(); auto v: a) {
                auto m = v.toMap()["wf"];  // name:value
                data.wfs.append(m);
            }

            // qDebug() << data.wfs;
        }

        emit translationWordFinished(data);
    } else {
        QString result = obj["translation"].toArray().first().toString();
        emit translationFinished(result);
    }
}
