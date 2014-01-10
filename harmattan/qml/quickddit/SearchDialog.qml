import QtQuick 1.1
import com.nokia.meego 1.0

Sheet {
    id: searchDialog
    acceptButtonText: "Search"
    acceptButton.enabled: searchTextField.text.length > 0 || searchTextField.platformPreedit.length > 0
    rejectButtonText: "Cancel"

    property alias text: searchTextField.text
    property int type: 0

    onAccepted: searchTextField.parent.focus = true; // force commit of predictive text

    content: Column {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: constant.paddingMedium }
        height: childrenRect.height
        spacing: constant.paddingLarge

        TextField {
            id: searchTextField
            placeholderText: "Enter search query..."
            anchors { left: parent.left; right: parent.right }
            platformSipAttributes: SipAttributes {
                actionKeyEnabled: searchDialog.acceptButton.enabled
                actionKeyLabel: searchDialog.acceptButtonText
            }
            onAccepted: searchDialog.accept();
        }

        Text {
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: constant.fontSizeMedium
            color: constant.colorLight
            text: "Search for:"
        }

        ButtonRow {
            id: typeButtonRow
            anchors { left: parent.left; right: parent.right }
            onCheckedButtonChanged: {
                if (checkedButton == searchButton) searchDialog.type = 0;
                else searchDialog.type = 1;
            }

            Button {
                id: searchButton
                text: "Posts"
            }

            Button {
                id: subredditButton
                text: "Subreddits"
            }
        }
    }
}
