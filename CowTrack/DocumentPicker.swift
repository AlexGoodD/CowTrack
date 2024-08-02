import SwiftUI
import UniformTypeIdentifiers

struct FilePicker: View {
    @Binding var selectedFileData: Data?
    @Binding var isDocumentPickerPresented: Bool
    
    var body: some View {
        FileImporter(
            isPresented: $isDocumentPickerPresented,
            allowedContentTypes: [UTType.data],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    do {
                        selectedFileData = try Data(contentsOf: url)
                    } catch {
                        print("Error al leer el archivo: \(error)")
                    }
                case .failure(let error):
                    print("Error al seleccionar el archivo: \(error)")
                }
            }
        )
    }
}
