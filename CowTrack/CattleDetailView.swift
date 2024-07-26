import SwiftUI
import CoreData

struct CattleDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var cattle: Cattle

    
    @State private var isEditing = false
    
    // State variables for editable fields
    @State private var editedEspecie = ""
    @State private var editedRaza = ""
    @State private var editedSexo = ""
    @State private var editedFechaCom = Date()
    @State private var editedPreCom = ""
    @State private var editedProveedor = ""
    @State private var editedFechaVen = Date()
    @State private var editedPreVen = ""
    @State private var editedComprador = ""
    
    // State variables for original values
    @State private var originalEspecie = ""
    @State private var originalRaza = ""
    @State private var originalSexo = ""
    @State private var originalFechaCom = Date()
    @State private var originalPreCom = ""
    @State private var originalProveedor = ""
    @State private var originalFechaVen = Date()
    @State private var originalPreVen = ""
    @State private var originalComprador = ""
    
    @State private var vendido = false
    @State private var mensajeAlerta = ""
    @State private var mostrarAlerta = false
    
    // State variables for documents
    @State private var selectedDocCom: Data? = nil
    @State private var selectedDocVen: Data? = nil
    @State private var docCom: [Data] = []
    @State private var docVen: [Data] = []
    
        
    var body: some View {
        Form {
            Section(header: Text("Información general")) {
                HStack {
                    Spacer(minLength: 50)
                    
                    if let qrImageData = cattle.qr, let qrImage = UIImage(data: qrImageData) {
                        Image(uiImage: qrImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.vertical)
                    }
                    
                    Spacer(minLength: 50)
                }

                if isEditing {
                    Text("ID: \(cattle.id ?? "")")
                    HStack {
                        Text("Especie:")
                        TextField("Especie", text: $editedEspecie)
                    }
                    HStack {
                        Text("Raza:")
                        TextField("Raza", text: $editedRaza)
                    }
                    Picker("Sexo:", selection: $editedSexo) {
                        Text("Macho").tag("Macho")
                        Text("Hembra").tag("Hembra")
                    }
                } else {
                    Text("ID: \(cattle.id ?? "")")
                    Text("Especie: \(cattle.especie ?? "")")
                        .onAppear {
                            originalEspecie = cattle.especie ?? ""
                            editedEspecie = originalEspecie
                        }
                    Text("Raza: \(cattle.raza ?? "")")
                        .onAppear {
                            originalRaza = cattle.raza ?? ""
                            editedRaza = originalRaza
                        }
                    Text("Sexo: \(cattle.sexo ?? "")")
                        .onAppear {
                            originalSexo = cattle.sexo ?? ""
                            editedSexo = originalSexo
                        }
                }
            }
            
            Section(header: Text("Información de compra")) {
                if isEditing {
                    DatePicker("Fecha de compra:", selection: $editedFechaCom, displayedComponents: .date)
                    HStack {
                        Text("Precio de compra:")
                        TextField("$ 2,000", text: $editedPreCom)
                            .keyboardType(.decimalPad)
                    }
                    HStack {
                        Text("Proveedor:")
                        TextField("Rancho El Roble", text: $editedProveedor)
                    }
                    // Agregar documento de compra
                    Button("Agregar Documento") {
                        // Aquí debes implementar la lógica para agregar un documento
                        // Por ejemplo, mostrar un picker o una hoja de selección de documentos
                        // Y luego asignar el documento seleccionado a selectedDocCom
                    }
                } else {
                    Text("Fecha de Compra: \(cattle.fechaCom ?? Date(), formatter: itemFormatter)")
                        .onAppear {
                            originalFechaCom = cattle.fechaCom ?? Date()
                            editedFechaCom = originalFechaCom
                        }
                    Text("Precio de compra: \(cattle.preCom, specifier: "%.2f")")
                        .onAppear {
                            originalPreCom = "\(cattle.preCom)"
                            editedPreCom = originalPreCom
                        }
                    Text("Proveedor: \(cattle.proveedor ?? "")")
                        .onAppear {
                            originalProveedor = cattle.proveedor ?? ""
                            editedProveedor = originalProveedor
                        }
                    
                    // Visualizar documento de compra
                    if let selectedDocCom = selectedDocCom {
                        Image(uiImage: UIImage(data: selectedDocCom)!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 200)
                    }
                }
                
                
                // Mostrar documentos de compra
                if let docComData = cattle.docCom, let docCom = deserializeDocuments(docComData) {
                    ForEach(0..<docCom.count, id: \.self) { index in
                        Button(action: {
                            // Mostrar el documento seleccionado
                            selectedDocCom = docCom[index]
                        }) {
                            Text("Documento de compra \(index + 1)")
                        }
                    }
                }
            }
            if isEditing{
                Toggle("Vendido", isOn: $vendido.animation())
                    .onChange(of: vendido) { value in
                            editedFechaVen = Date()
                            editedPreVen = ""
                            editedComprador = ""
                    }
            } else {
                Toggle("Vendido", isOn: $vendido.animation()).disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }

            if vendido {
                Section(header: Text("Información de venta")) {
                    if isEditing {
                        DatePicker("Fecha de venta:", selection: $editedFechaVen, displayedComponents: .date)
                        HStack {
                            Text("Precio de venta:")
                            TextField("$ 1,500", text: $editedPreVen)
                                .keyboardType(.decimalPad)

                        }
                        HStack{
                            Text("Comprador:")
                            TextField("Agropecuaria La Estrella", text: $editedComprador)
                            // Agregar documento de venta
                        }
                        Button("Agregar Documento") {
                        }
                    } else {
                        Text("Fecha de Venta: \(cattle.fechaVen ?? Date(), formatter: itemFormatter)")
                            .onAppear {
                                originalFechaVen = cattle.fechaVen ?? Date()
                                editedFechaVen = originalFechaVen
                            }
                        Text("Precio de Venta: \(cattle.preVen, specifier: "%.2f")")
                            .onAppear {
                                originalPreVen = "\(cattle.preVen)"
                                editedPreVen = originalPreVen
                                vendido = cattle.preVen != 0.0
                            }
                        Text("Comprador: \(cattle.comprador ?? "")")
                            .onAppear {
                                originalComprador = cattle.comprador ?? ""
                                editedComprador = originalComprador
                            }
                        
                        // Visualizar documento de venta
                        if let selectedDocVen = selectedDocVen {
                            Image(uiImage: UIImage(data: selectedDocVen)!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 200)
                        }
                    }
                    
                    // Mostrar documentos de venta
                    if let docVenData = cattle.docVen, let docVen = deserializeDocuments(docVenData) {
                        ForEach(0..<docVen.count, id: \.self) { index in
                            Button(action: {
                                // Mostrar el documento seleccionado
                                selectedDocVen = docVen[index]
                            }) {
                                Text("Documento de venta \(index + 1)")
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Detalles del ganado", displayMode: .inline)
        .navigationBarItems(trailing:
            HStack {
                if isEditing {
                    Button("Guardar") {
                        if validarInformacion() {
                            saveChanges()
                            isEditing.toggle()
                        } else {
                            mostrarAlerta = true

                        }

                    }
                    .alert(isPresented: $mostrarAlerta) {
                        Alert(title: Text("Error"), message: Text(mensajeAlerta), dismissButton: .default(Text("Ok")))
                    }
                } else {
                    Button("Editar") {
                        isEditing.toggle()
                    }
                }
            }
        )
        .onAppear {
            // Verificar si preVen es diferente de 0.0 y actualizar vendido
            vendido = cattle.preVen != 0.0
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    func deserializeDocuments(_ data: Data) -> [Data]? {
        do {
            let documents = try JSONDecoder().decode([Data].self, from: data)
            return documents
        } catch {
            print("Error deserializando documentos: \(error)")
            return nil
        }
    }
    
    private func validarInformacion() -> Bool {
        if editedEspecie.isEmpty || editedRaza.isEmpty {
                    mensajeAlerta = "Por favor, complete toda la información general."
                    return false
                }
        return true
    }
       
    
    private func saveChanges() {
        // Update Core Data entity with edited values
        cattle.especie = editedEspecie
        cattle.raza = editedRaza
        cattle.sexo = editedSexo
        cattle.fechaCom = editedFechaCom
        cattle.preCom = Double(editedPreCom) ?? 0.0
        cattle.proveedor = editedProveedor
        cattle.fechaVen = editedFechaVen
        cattle.preVen = Double(editedPreVen) ?? 0.0
        cattle.comprador = editedComprador
        
        vendido = cattle.preVen != 0.0
        
        do {
            NotificationCenter.default.post(name: Notification.Name("ShouldRefreshContentView"), object: nil)
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
}



struct CattleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let testCattle = Cattle(context: context)
        testCattle.id = "1234567890"
        testCattle.fechaCom = Date()
        testCattle.fechaVen = Date()
        testCattle.especie = "Bovino"
        testCattle.raza = "Angus"
        testCattle.sexo = "Macho"
        testCattle.preCom = 20000.0
        testCattle.preVen = 10
        testCattle.proveedor = "Proveedor 1"
        testCattle.comprador = "Comprador 1"
        testCattle.qr = UIImage(named: "placeholder_qr")?.pngData()
        
        return NavigationView {
            CattleDetailView(cattle: testCattle)
        }
        .environment(\.managedObjectContext, context)
    }
}
