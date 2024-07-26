import SwiftUI

struct CattleRowView: View {
    @ObservedObject var cattle: Cattle
    var isSelecting: Bool
    var isSelected: Bool
    var toggleSelection: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let qrImageData = cattle.qr, let qrImage = UIImage(data: qrImageData) {
                    Image(uiImage: qrImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .padding(.trailing, 5)
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text("ID:")
                            .bold()
                        Text("\(cattle.id ?? "")")
                    }
                    HStack {
                        Text("Especie/Raza:")
                            .bold()
                        Text("\(cattle.especie ?? "")/\(cattle.raza ?? "")")
                            .lineLimit(1)
                        
                    }
                    .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                    
                    HStack {
                        Text("Proveedor:")
                            .bold()
                        Text("\(cattle.proveedor ?? "")")
                            .lineLimit(1)
                    }
                }
                .padding(.trailing, 5)
                
                Spacer()
                
                if isSelecting {
                    Button(action: {
                        toggleSelection()
                    }) {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding(.vertical, 5)
        }
    }
}

struct CattleRowView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleCattle = Cattle(context: context)
        sampleCattle.id = "001"
        sampleCattle.especie = "Bovino"
        sampleCattle.raza = "Angus"
        sampleCattle.proveedor = "Rancho El Roble"
        sampleCattle.qr = UIImage(named: "placeholder_qr")?.pngData()
        
        return CattleRowView(
            cattle: sampleCattle,
            isSelecting: true,
            isSelected: false,
            toggleSelection: {}
        )
        .environment(\.managedObjectContext, context)
        .previewLayout(.sizeThatFits)
    }
}
