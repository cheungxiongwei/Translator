import QtQuick
import QtQml
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import Translator
import Qt.labs.platform

ApplicationWindow {
    property bool isExit: false

    id: root
    visible: true
    width: 640
    height: 480
    title: qsTr("Translator")

    Material.roundedScale: Material.SmallScale

    onClosing: close => {
                   if (!isExit) {
                       close.accepted = false
                       root.hide()
                   }
               }
    SystemTrayIcon {
        id: trayIcon
        visible: true
        icon.source: "qrc:/favicon.ico"
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

    Translator {
        id: translator
        onTranslationFinished: result => {
                                   translatedText.text = result
                               }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
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

                TextArea {
                    id: sourceText
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: TextEdit.Wrap
                    text: ""
                    onTextChanged: {
                        if (text.length > 5000) {
                            text = text.substring(0, 5000)
                        }
                    }
                }
            }

            ColumnLayout {
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

                TextArea {
                    id: translatedText
                    Layout.preferredWidth: 1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                }
            }
        }

        Button {
            Layout.fillWidth: true
            text: qsTr("Translate")

            onClicked: {
                // Call your translation function here, for example:
                translator.translate(sourceLanguage.currentText,
                                     targetLanguage.currentText,
                                     sourceText.text)
            }
        }
    }
}
