import QtQuick 2.4
import Ubuntu.Components 1.3
import Qt.labs.settings 1.0
import FileIO 1.0
import LiveReload 1.0
import "jscode.js" as JS

MainView {
    id: main
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "filebrowser.liu-xiao-guo"

    property bool monitor: false

    width: units.gu(60)
    height: units.gu(85)

    Settings {
        id: settings
        property bool hidden
        property bool log
    }

    function readFile(source, callback) {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function() {
            if (xhr.readyState == XMLHttpRequest.DONE) {
                var doc = xhr.responseText;
                callback(doc)
            }
        }

        xhr.send();
    }

    function clearDisplays() {
        detail.imgsrc = ""
        detail.text = ""
        detail.model = undefined
    }

    FileIO {
        id: file
        onError: console.log(msg)
    }

    LiveReload {
        id: livereload
        onFileChanged: {
            console.log("file changed in QML")
            if ( monitor ) {
                clearDisplays();
                var content = file.read(input.text)
                detail.model = content
                detail.listView.positionViewAtEnd()
            }
        }
    }

    AdaptivePageLayout {
        id: layout
        anchors.fill: parent
        primaryPage: filebrowserpage

        layouts: PageColumnsLayout {
            when: width > units.gu(100)
            // column #0
            PageColumn {
                minimumWidth: units.gu(30)
                maximumWidth: units.gu(60)
                preferredWidth: units.gu(40)
            }
            // column #1
            PageColumn {
                fillWidth: true
            }
        }

        Page {
            id: filebrowserpage
            header: PageHeader {
                title: "L-Browser"
                trailingActionBar.actions: [
                    Action {
                        iconSource: settings.log ? "images/log.png" : "images/log1.png"
                        onTriggered: {
                            settings.log = !settings.log
                            console.log("settings.log: " + settings.log)
                            iconSource = settings.log ? "images/log.png" : "images/log1.png"
                        }
                    },
                    Action {
                        iconSource: settings.hidden ? "images/hidden.png" : "images/hidden1.png"
                        onTriggered: {
                            settings.hidden = !settings.hidden
                            browser.showHidden = settings.hidden
                            console.log("setting.hidden: " + settings.hidden)
                        }
                    },
                    Action {
                        iconSource: "images/syslog.png"
                        onTriggered: {
                            // open the syslog file
                            clearDisplays();

                            edit.enabled = true;
                            edit.iconName = "edit"

                            activity.running = true
                            file.source = "/var/log/syslog"
                            console.log("going to read syslog")
                            var content = file.read(input.text)
                            //                            console.log("content1: " + content)
                            standardHeader.title = "syslog"
                            detail.model = content

                            layout.addPageToNextColumn(filebrowserpage, detailpage)
                            activity.running = false
                            detail.listView.positionViewAtEnd()

                            // Monitor the change of the file content
                            livereload.path = file.source
                            monitor = true;
                        }
                    },
                    Action {
                        iconName: "info"
                        onTriggered: {
                            layout.addPageToNextColumn(filebrowserpage, infopage)
                        }
                    }
                ]
            }

            FileBrowser {
                id: browser
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    top: filebrowserpage.header.bottom
                }

                ActivityIndicator {
                    anchors.centerIn: parent
                    id: activity
                }

                onFileSelected: {
                    clearDisplays()
                    monitor = false                    

                    console.log("fileURL: " + model.fileURL)
                    var filename = "" + model.fileURL
                    var ext = filename.split('.').pop();
                    console.log("ext: " + ext)
                    // Make sure the edit is working properly
                    edit.enabled = true;
                    edit.iconName = "edit"

                    if ( ext === "jpg" || ext === "jpeg" || ext === "png") {
                        console.log("it is an image file")
                        detail.imgsrc = model.fileURL
                        if ( !JS.isSearchable(ext) ) {
                            console.log("it is not searchable...")
                            edit.enabled = false
                            edit.iconName = ""
                        }
                    } else if ( JS.isSearchable(ext) ) {
                        console.log("it is a text file")
                        // we need to read the file out and fill it into
                        // the text area
                        // readFile(model.fileURL, updateText)
                        var temp = "" + model.fileURL;
                        var path = temp.replace("file://", "");
                        console.log("fileURL: " + path)
                        activity.running = true
                        file.source = path
                        var content = file.read(input.text)
                        detail.model = content
                        activity.running = false
                        detail.listView.positionViewAtEnd()

                        // Monitor the change of the file content
                        livereload.path = file.source
                        monitor = true
                    } else if ( JS.isViewable(ext) ) {
                        var temp = "" + model.fileURL;
                        var path = temp.replace("file://", "");
                        console.log("fileURL: " + path)
                        activity.running = true
                        file.source = path
                        var content = file.readString()
                        detail.text = content
                        activity.running = false

                        edit.enabled = false
                        edit.iconName = ""
                    }

                    var name = filename.replace(/^.*[\\\/]/, '');
                    detailpage.header.title = name;
                    console.log("filename: " + name)
                    layout.addPageToNextColumn(filebrowserpage, detailpage)
                }
            }
        }

        Page {
            id: detailpage
            clip: true

            header: standardHeader

            PageHeader {
                id: standardHeader
                visible: detailpage.header === standardHeader
                title: "Details"
                trailingActionBar.actions: [
                    Action {
                        id: edit
                        iconName: "edit"
                        text: "Edit"
                        onTriggered: detailpage.header = editHeader
                    }
                ]
            }

            PageHeader {
                id: editHeader
                visible: detailpage.header === editHeader
                leadingActionBar.actions: [
                    Action {
                        iconName: "back"
                        text: "Back"
                        onTriggered: {
                            console.log("back is selected")
                            input.text = ""
                            detailpage.header = standardHeader
                        }
                    }
                ]
                contents: Row {
                    spacing: units.gu(5)
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: input
                        placeholderText: "input search words ..."
                    }

                    Button {
                        width: parent.width/3
                        text: "Search"
                        onClicked: {
                            var content = file.read(input.text)
                            detail.model = content
                            detail.listView.positionViewAtEnd()
                        }
                    }
                }
            }

            DetailPage {
                id: detail
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    top: detailpage.header.bottom
                }
            }
        }

        Page {
            id: infopage
            header: PageHeader {
                title: "Info"
            }

            InfoPage {
                anchors.fill: parent
            }

        }
    }
}

