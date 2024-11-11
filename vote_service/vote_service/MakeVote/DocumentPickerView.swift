import SwiftUI
import UniformTypeIdentifiers
import CoreXLSX

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var excelData: String

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType(filenameExtension: "xlsx")!])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPickerView

        init(_ parent: DocumentPickerView) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.parseExcelFile(at: url)
        }
    }

    func parseExcelFile(at url: URL) {
        do {
            guard let file = XLSXFile(filepath: url.path) else {
                print("파일을 열 수 없습니다.")
                return
            }
            var csvString = ""

            if let sharedStrings = try file.parseSharedStrings() {
                for wbk in try file.parseWorkbooks() {
                    for (_, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
                        let worksheet = try file.parseWorksheet(at: path)
                        for row in worksheet.data?.rows ?? [] {
                            let rowValues = row.cells.compactMap { cell -> String? in
                                return cell.stringValue(sharedStrings)
                            }
                            csvString += rowValues.joined(separator: ",") + "\n"
                        }
                    }
                }
            } else {
                for wbk in try file.parseWorkbooks() {
                    for (_, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
                        let worksheet = try file.parseWorksheet(at: path)
                        for row in worksheet.data?.rows ?? [] {
                            let rowValues = row.cells.compactMap { cell -> String? in
                                return cell.value
                            }
                            csvString += rowValues.joined(separator: ",") + "\n"
                        }
                    }
                }
            }
            excelData = csvString
        } catch {
            print("엑셀 파일 파싱 중 오류 발생: \(error)")
        }
    }
}
