import SwiftUI
import PDFKit

struct PDFPreview: UIViewControllerRepresentable {
    var data: Data
    var onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.modalPresentationStyle = .fullScreen
        
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.frame = viewController.view.bounds
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let document = PDFDocument(data: data) {
            pdfView.document = document
        } else {
            print("Error: No se pudo crear el PDF a partir de los datos proporcionados.")
        }
        
        viewController.view.addSubview(pdfView)
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Cerrar", for: .normal)
        closeButton.frame = CGRect(x: 20, y: 40, width: 100, height: 40)
        closeButton.autoresizingMask = [.flexibleBottomMargin, .flexibleRightMargin]
        closeButton.addTarget(context.coordinator, action: #selector(context.coordinator.dismiss), for: .touchUpInside)
        
        viewController.view.addSubview(closeButton)
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: PDFPreview

        init(_ parent: PDFPreview) {
            self.parent = parent
        }

        @objc func dismiss() {
            parent.onDismiss()
        }
    }
}
