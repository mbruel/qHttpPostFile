#ifndef HTTPPOSTER_H
#define HTTPPOSTER_H

#include "Singleton.h"
#include <QObject>
#include <QNetworkAccessManager>

class HttpPoster : public QObject, public Singleton<HttpPoster>
{
    Q_OBJECT
    friend class Singleton<HttpPoster>;

public:
    ~HttpPoster() = default;

    Q_INVOKABLE QString post(const QString &url, const QString &fileKey, const QString &filePath, const QStringList &extraKeys);

signals:
    void posted();
    void error(const QString &errorMsg);

private slots:
    void onUploadDone();


private:
    HttpPoster(QObject *parent = nullptr);

    QNetworkAccessManager _netMgr;

};

#endif // HTTPPOSTER_H
