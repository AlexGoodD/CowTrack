import SwiftUI
import UniformTypeIdentifiers

struct AddCattleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var id = String(UUID().uuidString.prefix(10))
    @State private var fechaCom = Date()
    @State private var fechaVen: Date? = nil
    @State private var especie = ""
    @State private var raza = ""
    @State private var sexo = "Macho" // Valor inicial
    @State private var preCom = ""
    @State private var preVen = ""
    @State private var docCom = [Data]()
    @State private var docVen = [Data]()
    @State private var proveedor = ""
    @State private var comprador = ""
    @State private var vendido = false // Nuevo estado para controlar si está vendido o no
    @State private var mostrarDocPickerCom = false
    @State private var mostrarDocPickerVen = false
    @State private var mensajeAlerta = ""
    @State private var mostrarAlerta = false
    @State private var fechaCreacion = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información general")) {
                    HStack {
                        Text("ID:")
                        TextField("ID", text: $id)
                    }
                    HStack {
                        Text("Especie:")
                        TextField("Bovino", text: $especie)
                    }
                    HStack {
                        Text("Raza:")
                        TextField("Angus", text: $raza)
                    }
                    Picker("Sexo:", selection: $sexo) {
                        Text("Macho").tag("Macho")
                        Text("Hembra").tag("Hembra")
                    }
                }
                
                Section(header: Text("Información de compra")) {
                    DatePicker("Fecha de compra:", selection: $fechaCom, displayedComponents: .date)
                    HStack {
                        Text("Precio de compra:")
                        TextField("$ 2000", text: $preCom)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Proveedor:")
                        TextField("Rancho El Roble", text: $proveedor)
                    }
                    
                    /*
                    HStack {
                        Text("Documentos de compra:")
                        Button(action: {
                            mostrarDocPickerCom = true
                        }) {
                            Label("\(docCom.count)", systemImage: "paperclip")
                        }
                        .sheet(isPresented: $mostrarDocPickerCom) {
                            DocumentPicker(documentData: $docCom)
                        }
                    }
                    
                    */
                }
                
                Toggle("Vendido", isOn: $vendido.animation())
                
                if vendido {
                    Section(header: Text("Información de venta")) {
                        DatePicker("Fecha de venta:", selection: Binding(get: {
                            fechaVen ?? Date()
                        }, set: {
                            fechaVen = $0
                        }), displayedComponents: .date)
                        HStack {
                            Text("Precio de venta:")
                            TextField("$ 30000", text: $preVen)
                                .keyboardType(.decimalPad)
                        }
                        HStack {
                            Text("Comprador:")
                            TextField("Agropecuaria Lupe", text: $comprador)
                        }
                        
                        /*
                        HStack {
                            Text("Documentos de venta:")
                            Button(action: {
                                mostrarDocPickerVen = true
                            }) {
                                Label("\(docVen.count)", systemImage: "paperclip")
                            }
                            .sheet(isPresented: $mostrarDocPickerVen) {
                                DocumentPicker(documentData: $docVen)
                            }
                        }
                        */
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    if validarInformacion() {
                        addCattle()
                    } else {
                        mostrarAlerta = true
                    }
                }
                .alert(isPresented: $mostrarAlerta) {
                    Alert(title: Text("Error"), message: Text(mensajeAlerta), dismissButton: .default(Text("Ok")))
                }
            )
            .navigationBarTitle("Agregar ganado", displayMode: .inline)
        }
    }
    
    // Serializa un array de Data a un solo Data
    func serializeDocuments(_ documents: [Data]) -> Data? {
        do {
            let jsonData = try JSONEncoder().encode(documents)
            return jsonData
        } catch {
            print("Error serializando documentos: \(error)")
            return nil
        }
    }

    // Deserializa un Data a un array de Data
    func deserializeDocuments(_ data: Data) -> [Data]? {
        do {
            let documents = try JSONDecoder().decode([Data].self, from: data)
            return documents
        } catch {
            print("Error deserializando documentos: \(error)")
            return nil
        }
    }

    private func addCattle() {
        let newCattle = Cattle(context: viewContext)
        newCattle.id = id
        newCattle.fechaCom = fechaCom
        newCattle.fechaVen = fechaVen
        newCattle.especie = especie
        newCattle.raza = raza
        newCattle.sexo = sexo
        newCattle.preCom = Double(preCom) ?? 0
        newCattle.preVen = Double(preVen) ?? 0
        newCattle.proveedor = proveedor
        newCattle.comprador = comprador
        newCattle.fechaCreacion = fechaCreacion
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        // Serializar y asignar los documentos de compra
        if let serializedDocCom = serializeDocuments(docCom) {
            newCattle.docCom = serializedDocCom
        }
        // Serializar y asignar los documentos de venta
        if let serializedDocVen = serializeDocuments(docVen) {
            newCattle.docVen = serializedDocVen
        }
        // Generar código QR
        let qrString = newCattle.id ?? ""
        if let qrCode = generateQRCode(from: qrString) {
            if let imageData = qrCode.pngData() {
                newCattle.qr = imageData
            }
        }
        
    }

    private func validarInformacion() -> Bool {
        if especie.isEmpty || raza.isEmpty {
            mensajeAlerta = "Por favor, complete toda la información general."
            return false
        }
        return true
    }
}

struct AddCattleView_Previews: PreviewProvider {
    static var previews: some View {
        AddCattleView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
