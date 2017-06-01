import QtQuick 2.4
import Qt.labs.folderlistmodel 2.1
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3
import Ubuntu.Components.Popups 1.3
import "jscode.js" as JS

Item {
    id: root
    width: 200
    height: 300
    signal fileSelected(var model)
    //    property string filePath: list.model.get(list.currentIndex, "filePath")
    property real spacing: 6
    property string selectedNameFilter: "*.*"
    property alias showHidden: foldermodel.showHidden

    property alias color: background.color

    function __dirDown(url) {
        list.model.folder = url;
        list.currentIndex = -1;
    }

    function __dirUp() {
        list.model.folder = list.model.parentFolder;
        list.currentIndex = -1;
    }

    FolderListModel {
        id: foldermodel
        folder: "file:///"
        showDirsFirst: true
        sortField: FolderListModel.Name
        //        showDotAndDotDot:true
        nameFilters: settings.log ? [ "*.log"] : "*"
        showHidden: settings.hidden

        onFolderChanged: {
            currentPathText.text = list.model.folder.toString().replace("file:///", "/");
        }
    }

    Component {
        id: driveSelector
        Popover {
            Column {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(10)
                Header {
                    id: header
                    text: i18n.tr("Select drives")
                }

                ListView {
                    clip: true
                    width: parent.width
                    height: parent.height - header.height
                    model: DriveList.availableDrives
                    delegate: Standard {
                        text: modelData
                        onClicked: {
                            caller.text = modelData
                            hide()
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: __palette.window
        Rectangle {
            id: titleBar
            width: parent.width
            height: units.gu(4)
            color: Qt.darker(__palette.window, 1.2)
            border.color: Qt.darker(__palette.window, 1.3)

            Button {
                id: upButton
                height: parent.height
                width: height*1.2
                anchors.left: parent.left
                iconSource: "qrc:///images/up.png"
                onClicked:  {
                    if (list.model.parentFolder.toString() !== "") {
                        __dirUp();
                    }
                }
            }

            Button {
                id: driveList
                anchors.top: upButton.top
                anchors.bottom: upButton.bottom
                anchors.left: upButton.right
                text: "/"
                width: 0
                visible:false
                onClicked: {
                    PopupUtils.open(driveSelector, driveList)
                    list.model.folder = "file:///" + text
                }
            }
            Label {
                id: currentPathText
                height: parent.height
                anchors.left: driveList.right
                anchors.right: parent.right
                text: list.model.folder.toString().replace("file:///", "/")
                color: __palette.text
                elide: Text.ElideLeft
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                fontSize: "small"
            }
        }

        ScrollView {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: titleBar.bottom
            anchors.bottom: parent.bottom

            UbuntuListView {
                id: list
                clip: true
                focus: true
                model: foldermodel
                delegate: folderDelegate
                highlight: Rectangle {
                    color: __palette.midlight
                    border.color: Qt.darker(__palette.window, 1.3)
                }
                highlightMoveDuration: -1
                highlightMoveVelocity: -1
                highlightFollowsCurrentItem: true
            }
        }

        SystemPalette { id: __palette }

        Component {
            id: folderDelegate
            Rectangle {
                id: wrapper
                width: root.width
                height: nameText.implicitHeight * 1.7
                color: "transparent"

                Image {
                    id: icon
                    source: "qrc:///images/folder.png"
                    height: parent.height - spacing * 2
                    width: height
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.leftMargin: spacing
                    anchors.topMargin: spacing
                    visible: list.model.isFolder(index)
                    property int spacing: 2
                }
                Label {
                    id: nameText
                    text: fileName
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: icon.right
                    anchors.leftMargin: icon.spacing
                    anchors.right: parent.right
                    verticalAlignment: Text.AlignVCenter
                    fontSize: "large"
                }
                MouseArea {
                    id: mouseRegion
                    anchors.fill: parent
                    onDoubleClicked: {
                        if (list.model.isFolder(index)) {
                            __dirDown(fileURL) // fileURL
                        } else {
                            console.log("it is a file: " + fileURL)
                            var filename = "" + fileURL
                            var ext = filename.split('.').pop();
                            if ( JS.isRecognizedFile(ext)) {
                                console.log("it is a recognized file!")
                                fileSelected(model)
                            }
                        }
                    }
                    onClicked: {
                        list.currentIndex = index;
                    }
                }

                SwipeArea {
                    id: swiperight
                    anchors.fill: parent
                    direction: SwipeArea.Rightwards

                    onDraggingChanged: {
                        if ( dragging ) {
                            console.log("swipe right")

                            if (list.model.isFolder(index)) {
                                __dirDown(fileURL) // fileURL
                            } else {
                                console.log("it is a file: " + fileURL)
                                var filename = "" + fileURL
                                var ext = filename.split('.').pop();
                                if ( JS.isRecognizedFile(ext)) {
                                    console.log("it is a recognized file")
                                    fileSelected(model)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    SwipeArea {
        id: swipeleft
        anchors.fill: parent
        direction:  SwipeArea.Leftwards

        onDraggingChanged: {
            if ( dragging ) {
                console.log("swipe left")
                if (list.model.parentFolder.toString() !== "") {
                    __dirUp();
                }
            }
        }
    }
}
