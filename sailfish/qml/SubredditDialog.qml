import QtQuick 2.0
import Sailfish.Silica 1.0
import Quickddit 1.0

Dialog {
    id: subredditDialog

    property SubredditModel subredditModel
    property alias text: subredditTextField.text

    property bool busy: subredditModel ? subredditModel.busy : false

    acceptDestinationAction: PageStackAction.Replace
    canAccept: subredditTextField.acceptableInput

    SilicaFlickable {
        anchors.fill: parent
        pressDelay: 0

        PullDownMenu {
            enabled: !!subredditModel
            MenuItem {
                text: "Refresh subscribed subreddits"
                onClicked: subredditModel.refresh(false);
            }
        }

        DialogHeader {
            id: dialogHeader
            anchors { left: parent.left; right: parent.right; top: parent.top }
            dialog: subredditDialog
            title: "Subreddits"
        }

        TextField {
            id: subredditTextField
            anchors { left: parent.left; right: parent.right; top: dialogHeader.bottom }
            placeholderText: "Go to specific subreddit..."
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            // RegExp based on <https://github.com/reddit/reddit/blob/aae622d/r2/r2/lib/validator/validator.py#L525>
            validator: RegExpValidator { regExp: /^[A-Za-z0-9][A-Za-z0-9_]{2,20}$/ }
            EnterKey.enabled: subredditDialog.canAccept
            EnterKey.iconSource: "image://theme/icon-m-enter-accept"
            EnterKey.onClicked: accept();
        }

        Column {
            id: mainOptionColumn
            anchors { left: parent.left; right: parent.right; top: subredditTextField.bottom }
            height: childrenRect.height

            Repeater {
                id: mainOptionRepeater
                anchors { left: parent.left; right: parent.right }
                model: ["Front", "All", "Browse for Subreddits..."]

                ListItem {
                    contentHeight: Theme.itemSizeSmall
                    width: mainOptionRepeater.width

                    Text {
                        id: subredditText
                        anchors {
                            left: parent.left; right: parent.right; margins: constant.paddingLarge
                            verticalCenter: parent.verticalCenter
                        }
                        font.pixelSize: constant.fontSizeMedium
                        color: constant.colorLight
                        text: modelData
                    }

                    onClicked: {
                        switch (index) {
                        case 0: subredditTextField.text = ""; break;
                        case 1: subredditTextField.text = "all"; break;
                        case 2: acceptDestination = Qt.resolvedUrl("SubredditsBrowsePage.qml"); break;
                        }
                        subredditDialog.canAccept = true;
                        subredditDialog.accept();
                    }
                }
            }
        }

        SectionHeader {
            id: subscribedSubredditHeader
            anchors.top: mainOptionColumn.bottom
            visible: !!subredditModel
            text: "Subscribed Subreddits"
        }

        SilicaListView {
            id: subscribedSubredditListView
            anchors {
                top: subscribedSubredditHeader.bottom; bottom: parent.bottom
                left: parent.left; right: parent.right
            }
            pressDelay: 0
            visible: !!subredditModel
            clip: true
            model: visible ? subredditModel : 0
            delegate: ListItem {
                contentHeight: Theme.itemSizeSmall

                Text {
                    id: subscribedSubredditText
                    anchors {
                        left: parent.left; right: parent.right; margins: constant.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    font.pixelSize: constant.fontSizeMedium
                    color: constant.colorLight
                    text: model.url
                }

                onClicked: {
                    subredditTextField.text = model.displayName;
                    subredditDialog.accept();
                }
            }

            PushUpMenu {
                MenuItem {
                    text: "Load more"
                    enabled: subredditModel ? !subredditModel.busy : false
                    onClicked: subredditModel.refresh(true);
                }
            }

            VerticalScrollDecorator {}
        }
    }
}
