#include "HttpPoster.h"
#include <QDebug>
#include <QNetworkReply>
#include <QHttpMultiPart>
#include <QFile>
#include <QFileInfo>
HttpPoster::HttpPoster(QObject *parent) :
    QObject(parent), Singleton<HttpPoster>(),
    _netMgr()
{}


QString HttpPoster::post(const QString &url, const QString &fileKey, const QString &filePath, const QStringList &extraKeys)
{
    qDebug() << "[HttpPoster::post] Url: " << url << ", fileKey: " << fileKey
             << ", File: " << filePath << ", extraKeys: " << extraKeys << " (nb: "<< extraKeys.length() << ")";

    QFile *file = new QFile(filePath.startsWith("file://")?filePath.mid(7):filePath);
    if (file->open(QIODevice::ReadOnly))
    {
        QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);

        if (extraKeys.length() > 0)
        {
            int nbKeys = extraKeys.length() / 2;
            for (int i = 0 ; i < nbKeys ; ++i)
            {
                QHttpPart textPart;
                textPart.setHeader(QNetworkRequest::ContentDispositionHeader,
                                   QString("form-data; name=\"%1\"").arg(extraKeys.at(2*i)));
                textPart.setBody(extraKeys.at(2*i+1).toLocal8Bit());
                multiPart->append(textPart);
            }
        }

        QString fileName = QFileInfo(filePath).fileName();
        fileName.replace('"', '\'');
        QHttpPart filePart;
        filePart.setHeader(QNetworkRequest::ContentDispositionHeader,
                           QString("form-data; name=\"%1\"; filename=\"%2\"").arg(fileKey).arg(fileName));
        filePart.setBodyDevice(file);
        file->setParent(multiPart); // file deleted on the destruction of multiPart

        multiPart->append(filePart);


        QUrl proFileURL(url);
        QNetworkRequest req(proFileURL);
        req.setRawHeader( "User-Agent" , "HttpPoster C++ app" );

        QNetworkReply *reply = _netMgr.post(req, multiPart);
        QObject::connect(reply, &QNetworkReply::finished, this, &HttpPoster::onUploadDone);

        multiPart->setParent(reply); // multiPart deleted on the destruction of reply

        return "OK";
    }
    else
        return tr("Can't open file: '%1'").arg(filePath);
}

void HttpPoster::onUploadDone()
{
    qDebug() << "[HttpPoster::onUploadDone] Done!";
    QNetworkReply *reply = static_cast<QNetworkReply*>(sender());
    qDebug() << "HttpStatusCodeAttribute: " << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute)
             << ", " << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute);
    qDebug() << reply->readAll();

    int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    if ( httpStatus != 200)
        emit error(QString("%1 %2").arg(httpStatus).arg(reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString()));
    else
    {
        // TODO: Here we should check the reply to see if the post was accepted...
        // Is the Authentication OK?
        // Is the file format or size OK?
        emit posted(); // warn QML
    }

    reply->deleteLater(); // delete reply and thus corresponding multiPart and file
}
