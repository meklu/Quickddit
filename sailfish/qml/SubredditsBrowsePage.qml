/*
    Quickddit - Reddit client for mobile phones
    Copyright (C) 2014  Dickson Leong

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see [http://www.gnu.org/licenses/].
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.quickddit.Core 1.0

AbstractPage {
    id: subredditsBrowsePage
    title: subredditModel.section == SubredditModel.SearchSection
           ? "Subreddits Search: " + searchQuery
           : subredditsSectionModel[subredditModel.section]

    property alias searchQuery: subredditModel.query
    property bool isSearch: searchQuery

    readonly property variant subredditsSectionModel: ["Popular Subreddits", "New Subreddits",
        "My Subreddits - Subscriber", "My Subreddits - Approved Submitter", "My Subreddits - Moderator"]

    function refresh() {
        subredditModel.refresh(false);
    }

    SilicaListView {
        id: subredditsListView
        anchors.fill: parent
        model: subredditModel

        PullDownMenu {
            MenuItem {
                text: "Section"
                onClicked: {
                    globalUtils.createSelectionDialog("Section", subredditsSectionModel, subredditModel.section,
                    function(selectedIndex) {
                        subredditModel.section = selectedIndex;
                        subredditModel.refresh(false);
                    })
                }
            }
            MenuItem {
                text: "Refresh"
                onClicked: subredditModel.refresh(false);
            }
        }

        header: PageHeader { title: subredditsBrowsePage.title }

        delegate: SubredditDelegate {
            onClicked: {
                var mainPage = pageStack.find(function(page) { return page.objectName == "mainPage"; });
                mainPage.refresh(model.displayName);
                pageStack.pop(mainPage);
            }
        }

        footer: LoadingFooter { visible: subredditModel.busy; listViewItem: subredditsListView }

        onAtYEndChanged: {
            if (atYEnd && count > 0 && !subredditModel.busy && subredditModel.canLoadMore)
                subredditModel.refresh(true);
        }

        ViewPlaceholder { enabled: subredditsListView.count == 0 && !subredditModel.busy; text: "Nothing here :(" }

        VerticalScrollDecorator {}
    }

    SubredditModel {
        id: subredditModel
        manager: quickdditManager
        section: isSearch ? SubredditModel.SearchSection : SubredditModel.PopularSection
        onError: infoBanner.alert(errorString);
    }
}
