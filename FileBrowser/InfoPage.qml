import QtQuick 2.0
import Ubuntu.Components 1.3

Item {

    Column {
        anchors.centerIn: parent
        spacing: units.gu(5)

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "images/icon.jpg"
            width: parent.width/3
            height: width
        }

        Label {
            text: "Swipe left/right to navigate the folders.\nUse \"h\" to show the hidden files. \nUse log to short list .log files. \nUse \"syslog\" to show syslog info. \nAuthor: xiaoguo.liu@canonical.com\nVersion 0.1"
            fontSize: "large"
        }
    }
}

