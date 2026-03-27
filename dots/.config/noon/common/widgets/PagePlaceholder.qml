import QtQuick
import QtQuick.Layouts
import qs.common
import qs.common.widgets

Item {
    id: root

    property bool shown: true
    property alias iconFill: shapeWidget.fill
    property alias icon: shapeWidget.text
    property alias shapePadding: shapeWidget.padding
    property alias title: widgetNameText.text
    property alias description: widgetDescriptionText.text
    property alias shape: shapeWidget.shape
    property alias descriptionHorizontalAlignment: widgetDescriptionText.horizontalAlignment
    property alias iconSize: shapeWidget.iconSize
    property alias colBackground: shapeWidget.color
    property alias colOnBackground: shapeWidget.colSymbol
    property int spacing: Padding.large
    property QtObject colors: Colors

    opacity: shown ? 1 : 0
    visible: opacity > 0

    anchors {
        fill: parent
        topMargin: -30 * (1 - opacity)
        bottomMargin: 30 * (1 - opacity)
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: root.spacing

        MaterialShapeWrappedSymbol {
            id: shapeWidget
            colors: root.colors
            Layout.alignment: Qt.AlignHCenter
            padding: 12
            iconSize: 90
            rotation: -30 * (1 - root.opacity)
        }

        StyledText {
            id: widgetNameText

            visible: text !== ""
            Layout.alignment: Qt.AlignHCenter
            color: root.colors.colOnLayer0
            horizontalAlignment: Text.AlignHCenter

            font {
                family: Fonts.family.main
                pixelSize: Fonts.sizes.verylarge
                variableAxes: Fonts.variableAxes.title
            }
        }

        StyledText {
            id: widgetDescriptionText

            visible: description !== ""
            Layout.fillWidth: true
            font.pixelSize: Fonts.sizes.small
            color: root.colOnBackground
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.Wrap
        }
    }

    Behavior on opacity {
        Anim {}
    }
}
