import SwiftUI
import CoreData

struct TrashCattleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Cattle.fechaEliminado, ascending: true)],
        predicate: NSPredicate(format: "fechaEliminado != nil"),
        animation: .default)
    private var trashedCattle: FetchedResults<Cattle>
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer(minLength: 25)
            Text("Los elementos en la papelera de reciclaje serán eliminados permanentemente al pasar 30 días.")
                .foregroundColor(.gray)
                .font(.subheadline)
                .padding(.horizontal)
            
            List {
                ForEach(trashedCattle) { item in
                    CattleRowView(cattle: item, isSelecting: false, isSelected: false) {
                        // No hay necesidad de acción en la papelera
                    }
                    .swipeActions {
                        Button {
                            recoverItem(item)
                        } label: {
                            Label("Recuperar", systemImage: "arrow.uturn.backward.circle.fill")
                        }
                        .tint(.green)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            
            HStack {
                if trashedCattle.count > 1 {
                    Text("\(trashedCattle.count) fichas")
                        .font(.subheadline)
                } else {
                    Text("\(trashedCattle.count) ficha")
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 10)
        }
        .navigationTitle("Papelera de reciclaje")
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { trashedCattle[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Manejar el error
                print("Error al eliminar el elemento de la papelera: \(error.localizedDescription)")
            }
        }
    }
    
    private func recoverItem(_ item: Cattle) {
        item.fechaEliminado = nil // Restaurar el item (eliminar la fecha de eliminación)
        do {
            try viewContext.save()
        } catch {
            // Manejar el error
            print("Error al recuperar el elemento de la papelera: \(error.localizedDescription)")
        }
    }
}

struct TrashCattleView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        TrashCattleView().environment(\.managedObjectContext, context)
    }
}
