import SwiftUI

struct CattleGridView: View {
    @ObservedObject var cattle: Cattle
    var isSelecting: Bool
    var isSelected: Bool
    var toggleSelection: () -> Void
    
    var body: some View {
        
        VStack {
            if let qrImageData = cattle.qr, let qrImage = UIImage(data: qrImageData) {
                Image(uiImage: qrImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .padding(.bottom, 5)
            }
            VStack(alignment: .leading) {
                HStack{
                    Text("\(cattle.id ?? "")")
                        .bold()
                        .lineLimit(1)
                }
                
                HStack{
                    Text("\(cattle.especie ?? "")/\(cattle.raza ?? "")")
                        .bold()
                        .lineLimit(1)
                }
                
                HStack{
                    Text("\(cattle.proveedor ?? "")")
                        .bold()
                        .lineLimit(1)
                }
                
                
            }
            
            .padding(.horizontal, 5)
            
            
        }
        .frame(width: UIScreen.main.bounds.width / 3 - 15, height: UIScreen.main.bounds.width / 3 - 15)
                   .padding(20)
                   .background(Color.primary.opacity(0.1))
                   .cornerRadius(10)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct CattleGridView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let sampleCattle = Cattle(context: context)
        sampleCattle.id = "001"
        sampleCattle.especie = "Bovino"
        sampleCattle.raza = "Angus"
        sampleCattle.proveedor = "Juan bustos"
        sampleCattle.qr = UIImage(named: "placeholder_qr")?.pngData()
        
        return CattleGridView(
            cattle: sampleCattle,
            isSelecting: true,
            isSelected: false,
            toggleSelection: {}
        )
        .environment(\.managedObjectContext, context)
        .previewLayout(.sizeThatFits)
    }
}
