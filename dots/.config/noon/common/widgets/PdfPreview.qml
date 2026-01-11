import QtQuick.Pdf

PdfPageView {
    id: root
    property string source
    document: PdfDocument {
        source: root.source
    }
}
