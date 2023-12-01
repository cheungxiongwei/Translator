import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15
import Translator 1.0
import Qt.labs.platform 1.1

import uikit 1.0

ApplicationWindow {
    property bool isExit: false

    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Translator")

    onClosing: close => {
                   if (!isExit) {
                       close.accepted = false
                       root.hide()
                   }
               }
    SystemTrayIcon {
        id: trayIcon
        visible: true
        icon.source: "qrc:/assets/favicon.ico"
        onActivated: reason => {
                         if (reason === SystemTrayIcon.Trigger) {
                             root.show()
                             root.raise()
                             root.requestActivate()
                         }
                     }

        menu: Menu {
            MenuItem {
                text: qsTr("Open")
                onTriggered: root.show()
            }
            MenuItem {
                text: qsTr("Close")
                onTriggered: {
                    isExit = true
                    Qt.quit()
                }
            }
        }
    }

    QtObject {
        id: wordData
        property var query: null
        property var examType: []
        property var explains: []
        property var phonetic: null
        property var wfs: []
    }

    QtObject {
        id: sentenceData
        property var result: null
    }

    Translator {
        id: translator
        property bool isWord: false

        onTranslationFinished: result => {
                                   isWord = false
                                   sentenceData.result = result
                               }
        onTranslationWordFinished: result => {
                                       isWord = true
                                       wordData.query = result.query
                                       wordData.examType = result.examType
                                       wordData.explains = result.explains
                                       wordData.phonetic = result.phonetic
                                       wordData.wfs = result.wfs
                                   }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                anchors.fill: parent

                spacing: 24

                ColumnLayout {
                    id: sourceLayout
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: qsTr("Source Language:")
                    }

                    ComboBox {
                        id: sourceLanguage
                        model: translator.sourceLanguage
                    }

                    Label {
                        text: qsTr("Source Text:")
                    }

                    ScrollView {
                        Layout.preferredWidth: 1
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextArea {
                            id: sourceText
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true
                            leftInset: -6
                            rightInset: -6
                            text: "Hello,World!"
                            onTextChanged: {
                                if (text.length > 5000) {
                                    text = text.substring(0, 5000)
                                }
                            }

                            background: Rectangle {
                                color: "white"
                                border.width: 1
                                border.color: "gray"
                                radius: 6
                            }
                        }
                    }
                }

                ColumnLayout {
                    id: targetLayout
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        text: qsTr("Target Language:")
                    }

                    ComboBox {
                        id: targetLanguage
                        model: translator.targetLanguage
                    }

                    Label {
                        text: qsTr("Translated Text:")
                    }

                    ScrollView {
                        id: word
                        clip: true
                        Layout.preferredWidth: 1
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: translator.isWord
                        Page {
                            anchors.left: parent.left
                            anchors.leftMargin: 24
                            id: page
                            header: Row {
                                visible: false
                                Label {
                                    text: qsTr("翻译引擎:")
                                }
                                Label {
                                    text: qsTr("有道翻译")
                                }
                            }

                            function calcQueryWithPhonetic() {
                                if (wordData.phonetic === null)
                                    return `${wordData.query ?? ""}`

                                return `${wordData.query ?? ""} / ${wordData.phonetic ?? ""} /`
                            }

                            function calcExplains() {
                                let s = ""
                                if (wordData.explains === null)
                                    return s

                                for (var a of wordData.explains) {
                                    s += `${a}    \n`
                                }
                                return s
                            }

                            function calcExamType() {
                                let s = ""
                                if (wordData.examType === null)
                                    return s

                                for (var a of wordData.examType) {
                                    s += `${a}/`
                                }
                                return s
                            }

                            function calcWfs() {
                                let s = ""
                                if (wordData.wfs === null)
                                    return s

                                for (var a of wordData.wfs) {
                                    s += `${a["name"]} ${a["value"]}\n`
                                }
                                return s
                            }

                            Label {
                                topPadding: 12
                                bottomPadding: 12
                                text: page.calcQueryWithPhonetic()
                            }

                            footer: Column {
                                Label {
                                    text: qsTr("词汇解释:")
                                }
                                Column {
                                    spacing: 6
                                    Label {
                                        text: page.calcExplains()
                                    }
                                    Label {
                                        text: page.calcExamType()
                                    }
                                    Label {
                                        text: page.calcWfs()
                                    }
                                }
                            }
                        }
                    }

                    ScrollView {
                        visible: !translator.isWord
                        Layout.preferredWidth: 1
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextArea {
                            text: sentenceData.result ?? ""
                            leftInset: -6
                            rightInset: -6
                            selectByMouse: true
                            wrapMode: TextEdit.Wrap
                            readOnly: true
                            background: Rectangle {
                                color: "white"
                                border.width: 1
                                border.color: "gray"
                                radius: 6
                            }
                        }
                    }
                }
            }

            RoundButton {
                anchors.horizontalCenter: parent.horizontalCenter
                y: sourceLayout.height / 2
                width: 64
                height: 64
                icon.color: "transparent"
                icon.source: "qrc:/assets/002-exchange.png"

                onClicked: {
                    if (sourceLanguage.currentIndex > 0) {
                        let temp = sourceLanguage.currentIndex - 1
                        sourceLanguage.currentIndex = targetLanguage.currentIndex + 1
                        targetLanguage.currentIndex = temp
                    }
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Translate")

            onClicked: {
                // Call your translation function here, for example:
                translator.translate(sourceLanguage.currentText, targetLanguage.currentText, sourceText.text)
            }
        }
    }
}
