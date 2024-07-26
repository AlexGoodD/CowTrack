import CoreData
import UIKit
import CoreImage.CIFilterBuiltins  // Asegúrate de importar CoreImage.CIFilterBuiltins para usar CIQRCodeGenerator

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CowTrack")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Reemplaza fatalError con un manejo de errores mejorado
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0..<1 {
            let newItem = Cattle(context: viewContext)
            newItem.id = String(UUID().uuidString.prefix(10))
            newItem.fechaCom = Date()
            newItem.fechaVen = Date()
            newItem.especie = "Bovino"
            newItem.raza = "AngustiaAngustiaAngustiaAngustia"
            newItem.sexo = "Macho"
            newItem.preCom = 20000.0
            newItem.preVen = 25000.0
            newItem.proveedor = "Proveedor 1"
            newItem.comprador = "Comprador 1"
            
            // Generar QR Code
            let qrString = newItem.id ?? ""
            if let qrCode = generateQRCode(from: qrString) {
                if let imageData = qrCode.pngData() {  // Convierte UIImage a Data usando pngData() o jpegData()
                    newItem.qr = imageData
                }
            }
        }
        
        do {
            try viewContext.save()
            NotificationCenter.default.post(name: Notification.Name("ShouldRefreshContentView"), object: nil)
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
}

// Función para generar QR Code
func generateQRCode(from string: String) -> UIImage? {
    guard let data = string.data(using: .utf8) else { return nil }
    let filter = CIFilter.qrCodeGenerator()
    
    filter.setValue(data, forKey: "inputMessage")
    
    guard let ciImage = filter.outputImage else { return nil }
    
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
    
    return UIImage(cgImage: cgImage)
}
