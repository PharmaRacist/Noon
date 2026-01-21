import QtQuick
import qs.common
import qs.common.widgets

ApplicationSkeleton {
    id: root
    title: "PDF Reader"
    contentItem: PDFReaderPreview {}
    states_target: "reader"
    secondary_sidebar_content_item: PDFReaderSecondarySidebar {}
    secondary_content_item: PDFReaderList {}
}
