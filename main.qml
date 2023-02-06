import QtQuick
//import "script.js" as Script

Window {
    width: Screen.width
    height: Screen.height
    visible: true
    title: "Server Monitor"

    readonly property string serverUrl: "http://localhost:8000/"
    readonly property string statusQuery: "status/"

    //Queries
    function customGetRequest(query, callBack) {
        const xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
            console.log("On ready change got")
            console.log(xhr.responseText)
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                console.log("Request done!")
                let response = JSON.parse(xhr.responseText)
                callBack(response)
            }
        };

        xhr.open("GET", query)
        xhr.send()
    }

    function requestStatus() {
        function callback(response) {
            console.log("Got a response")
            results.clear()
            for(let i = 0; i < response.length; i++) {
                let newItem = {}
                newItem.serverName = response[i].url
                newItem.status = response[i].status
                results.append(newItem)
            }
        }

        customGetRequest(serverUrl + statusQuery, callback)
    }

ListModel {
    id: results
    ListElement { serverName: ""; status: 1 }
}

    Rectangle {
        id: bg
        anchors { fill: parent; margins: 30 }
        radius: 20
        color: "#ffc3a0"

    Column {
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 100 }
        spacing: 25
        Repeater {
            model: results
            Row {
                spacing: 25
            Rectangle {
                color: "#bb77ff"
                height: 50
                width: bg.width - 400
                radius: 15
                Text {
                    text: serverName
                    anchors { left: parent.left; leftMargin: 20; verticalCenter: parent.verticalCenter }
                }
            }
            Rectangle {
                color: "#f1cbff"
                width: 200
                height: 50
                radius: 15
                Text {
                    text: status === 1 ? "OK" : "Down"
                    color: status === 1 ? "green" : "red"
                    anchors { centerIn: parent }
                }
            }
            }
        }
    }

    Rectangle {
        id: btn
        color: btnArea.pressed ? "#96c96c" : "#bbff77"
        width: 200
        height: 50
        radius: 15
        anchors { bottom: parent.bottom; bottomMargin: 50; horizontalCenter: parent.horizontalCenter }

        Text {
            text: "Refresh"
            anchors.centerIn: parent
        }

        MouseArea {
            id: btnArea
            anchors.fill: parent
            onClicked: {
                console.log("Refresh pressed")
                requestStatus()
            }
        }
    }
}
}
