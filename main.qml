import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3
import QtQuick.Layouts 1.15

Window {
    id     : root
    visible: true
    width  : 640
    height : 480
    title  : qsTr("Upload File via Http(s)")

    color  : "lightblue"

    property string urlAuth  : "http://localhost/upload.php"
    property string keyFile  : "file"
    property string keyLogin : "login"
    property string keyPass  : "pass"

    property string subTitle : qsTr("with potential extra key(s)/value(s)")

    property alias resText   : resText

    property color txtColor  : "black"
    property int   txtSize   : 13;


    Connections {
        target:   cppHttpPoster
        onPosted: filePostedOK()
        onError : filePostedError(errorMsg)
    }

    Component.onCompleted: {
        addNewKeyValue(keyLogin, "enter login", true);
        addNewKeyValue(keyPass,  "enter pass",  true);
    }

    FileDialog {
        id: fileDialog
        title: qsTr("Please choose a file")
        folder: shortcuts.home
        onAccepted: {
            console.log("File chosen: " + fileDialog.fileUrls)
            filePath.text = fileDialog.fileUrl
        }
        onRejected: {
            console.log("File Canceled")
        }
    }

    Text {
        id: title
        text: root.title+"\n"+root.subTitle
        color: "#ff0000"
        font.pointSize: 24
        font.bold: true
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            margins: 10;
        }
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap //If the text line length exceeds the width property
        width: parent.width
    }

    GridLayout {
        id: myForm
        columns: 2
        rows: 2
        anchors {
            top: title.bottom
            horizontalCenter: parent.horizontalCenter
//            verticalCenter: parent.verticalCenter
            margins: 10, 10, 10, 50;
        }
        width: parent.width - 2*10

        Text {
            id: urlLbl
            text: qsTr("url: ")
            color: root.txtColor
            font.pointSize: root.txtSize
        }
        TextField {
            id: urlField
            text: root.urlAuth

            Layout.fillWidth : true

            selectByMouse: true

            color: root.txtColor
            background: Rectangle { radius: 8 ; border.width: 0 }
        }


//        Text {
//            id: fileLbl
//            text: root.keyFile
//            color: root.txtColor
//            font.pointSize: root.txtSize
//        }
        TextField {
            id: fileKey
            text: root.keyFile

            Layout.fillWidth : true

            color: root.txtColor
            background: Rectangle { radius: 8 ; border.width: 0 }

            selectByMouse: true

            hoverEnabled: true
            ToolTip.visible:  hovered
            ToolTip.text: qsTr("key of the html form used to upload the File")
        }
        Row {
            Layout.fillWidth : true
            spacing: 2            

            TextField {
                id: filePath
                placeholderText: qsTr("file path")
                width: parent.width - fileButton.width

                selectByMouse: true

                color: root.txtColor
                background: Rectangle { radius: 8 ; border.width: 0 }
            }

            Button {
                id: fileButton
                text: "..."
                width: 30
                height: filePath.height

                onClicked: fileDialog.visible = true;
            }
        }
    } // Grid



    TextButton {
        id: addKeyButton
        anchors {
            top: myForm.bottom
            left: parent.left
            topMargin: 10;
        }
        text: qsTr("Add Key")
        borderRadius: 10
        fontSize: 12

        onClicked: addNewKeyValue();
    }


    TextButton {
        id: sendButton
        anchors {
            top: addKeyButton.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 10;
        }
        text: qsTr("Send File!")
        borderRadius: 10
        fontSize: 12

        onClicked: sendFile();
    }

    Text {
        id: resText
        anchors {
            top: sendButton.bottom
            horizontalCenter: parent.horizontalCenter
            topMargin: 10;
        }

        font {
            italic   : true
            bold     : true
            pointSize: 13;
        }
        color: "red"
    }



////////////////////////////////////////////////////////////////////
//  Javascript
////////////////////////////////////////////////////////////////////

    function sendFile()
    {
        var error = "";
        if (urlField.text === "")
            error += qsTr("you need to enter a valid url...\n"); // Todo: could use a RegExp to validate url format
        if (filePath.text === "")
            error += qsTr("you need to select a File...\n");

        var extraKeys = [];
        if (myForm.rows > 2)
        {
            for (var row = 2; row < myForm.rows ; ++row)
            {
                var key = myForm.children[2*row].text;
                var val = myForm.children[2*row+1].text;
                console.log('[sendFile] row  #' + row + ': (' + key + ', ' + val + ')');
                if (key !== "" && val !== ""){
                    extraKeys.push(key);
                    extraKeys.push(val);
                }
            }
        }

        if (error.length > 0)
        {
            resText.color = "red"
            resText.text  = 'Error: ' + error
        }
        else
        {
            resText.color = "blue"
            resText.text  = "Sending file... (nb extra keys: " + extraKeys.length/2 + ")";

            resText.text += '\n Res: ' + cppHttpPoster.post(urlField.text, fileKey.text, filePath.text, extraKeys);
        }

    }


    function addNewKeyValue(key = qsTr("Key"), value = qsTr("Value"), defaultKey = false){
        console.log("number of rows: "+myForm.rows)

        var keyField = Qt.createQmlObject('
        import QtQuick 2.12
        import QtQuick.Controls 2.14
        import QtQuick.Layouts 1.15
        TextField {
            Layout.fillWidth : true

            selectByMouse: true

            color: root.txtColor
            background: Rectangle { radius: 8 ; border.width: 0 }
        }', myForm);

        var valField = Qt.createQmlObject('
        import QtQuick 2.12
        import QtQuick.Controls 2.14
        import QtQuick.Layouts 1.15
        Row {
            property alias text: textField.text;

            Layout.fillWidth : true
            spacing: 2


            TextField {
                id: textField
                width: parent.width - 30

                selectByMouse: true

                color: root.txtColor
                background: Rectangle { radius: 8 ; border.width: 0 }
            }

            Button {
                text: "x"
                width: 30
                height: textField.height

                onClicked: deleteRow(parent);
            }
        }', myForm);

        if (defaultKey)
            keyField.text = key;
        else
            keyField.placeholderText = key;

        valField.children[0].placeholderText = value;

        ++myForm.rows;
    }

    function deleteRow(rowValueObject){
        for (var row = 2; row < myForm.rows ; ++row)
        {
            console.log("row: " + row);

            if (myForm.children[2*row + 1] === rowValueObject)
            {
                console.log("delete row: " + row);
                myForm.children[2*row + 1].destroy();
                myForm.children[2*row].destroy();
                --myForm.rows;
                break;
            }
        }
    }


    function filePostedOK(){
         resText.color = "darkgreen"
         resText.text  = 'File posted!'
    }
    function filePostedError(errorMsg){
      resText.color = "darkred"
      resText.text  = 'Error posting: ' + errorMsg
    }
}
