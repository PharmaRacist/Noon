import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.common
import qs.common.widgets

BottomDialog {
    id: root
    collapsedHeight: 450
    hoverHeight: 120
    enableStagedReveal: false
    bottomAreaReveal: true
    color: Colors.colLayer2

    bgAnchors {
        leftMargin: expanded ? Padding.massive * 4 : Padding.small
        rightMargin: expanded ? Padding.massive * 4 : Padding.small
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Padding.huge
        spacing: Padding.normal

        BottomDialogHeader {
            title: "Surah List"
            subTitle: "you can search by name or number"
        }

        StyledRect {
            height: 40
            radius: Rounding.full
            Layout.fillWidth: true
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Padding.normal
                anchors.rightMargin: Padding.normal
                spacing: Padding.small

                Symbol {
                    text: "search"
                    Layout.leftMargin: Padding.huge
                    fill: searchField.focus
                    font.pixelSize: 26
                    color: Colors.colOnLayer0
                }

                StyledTextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "Surah name, e.g. Al-Fatiha"
                    background: null
                    onAccepted: QuranService.getSurahByName(searchField.text)
                }
            }
        }

        BottomDialogSeparator {}

        StyledListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Padding.small
            hint: false
            clip: true
            model: QuranService.surahs.filter(surah => surah.englishName.toLowerCase().includes(searchField.text.toLowerCase()))
            delegate: StyledDelegateItem {
                title: modelData.englishName
                subtext: modelData.englishNameTranslation
                materialIcon: modelData.number
                releaseAction: () =>  {
                    QuranService.getSurahByName(modelData.englishName)
                    root.show = false
                }
            }
        }
    }
}
