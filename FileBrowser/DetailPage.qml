import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
    property alias imgsrc: image.source
    property alias text: textarea.text
    property alias model: listview.model
//    property alias model: sortedModel.model
    property alias listView: listview

    Image {
        id: image
        anchors.fill: parent
        source: ""
        visible: source != ""
    }

    TextArea {
        id: textarea
        anchors.fill: parent
        visible: text != ""
        readOnly: true

        onLengthChanged: {
            // move cursor to the last position of interests
            cursorPosition = length
        }
    }

    SortFilterModel {
        id: sortedModel
//      model: mymodel
//      sort.property: "title"
//      sort.order: Qt.DescendingOrder
        filter.property: "logs"
//      filter.pattern: /blender/i
    }

    ListView {
        id: listview
        clip: true
        anchors.fill: parent
        visible: model !== undefined
        delegate: Text {
            width: parent.width
            text: modelData
            height: implicitHeight + 2
            wrapMode: Text.WordWrap

            Rectangle {
                width: parent.width
                height: 1
                color: UbuntuColors.darkGrey
            }
        }

        Component.onCompleted: {
            positionViewAtIndex(count - 1, ListView.Beginning)
        }
    }
}

