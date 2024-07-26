import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Cattle.fechaCreacion, ascending: true)],
        predicate: NSPredicate(format: "fechaEliminado == nil"),
        animation: .default)
    private var cattle: FetchedResults<Cattle>
    
    @State private var showingAddCattleView = false
    @State private var navigateToTrashView = false
    
    @StateObject private var viewModel = SortFilterViewModel()
    @State private var cattleListActive = true
    
    @State private var shouldRefresh = false
    @State private var isSelecting = false
    @State private var selectedCattle = Set<Cattle>()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        HStack(alignment: .center) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 10)
                            TextField("Search", text: $viewModel.searchText)
                                .padding(.vertical, 1)
                                .cornerRadius(8)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 10)
                        
                        Spacer()
                        
                        Menu {
                            if cattleListActive {
                                Button(action: {
                                    cattleListActive = false
                                }) {
                                    Label("Ver como cuadrícula", systemImage: "square.grid.2x2.fill")
                                }
                            } else {
                                Button(action: {
                                    cattleListActive = true
                                }) {
                                    Label("Ver como lista", systemImage: "list.bullet")
                                }
                            }
                            
                            Button(action: {
                                // Acción para seleccionar fichas
                            }) {
                                Label("Exportar fichas", systemImage: "square.and.arrow.up.fill")
                            }
                            
                            Button(action: {
                                isSelecting.toggle()
                                selectedCattle.removeAll()
                            }) {
                                Label("Seleccionar", systemImage: "circle")
                            }
                            
                            Menu {
                                Text("Ordenar por:")
                                ForEach(SortFilterViewModel.SortOption.allCases) { option in
                                    Button(action: {
                                        if viewModel.sortOption == option {
                                            viewModel.sortAscending.toggle()
                                        } else {
                                            viewModel.sortOption = option
                                            viewModel.sortAscending = true // Por defecto orden ascendente al cambiar opción
                                        }
                                    }) {
                                        HStack {
                                            Text(option.rawValue.capitalized)
                                            if viewModel.sortOption == option {
                                                Image(systemName: viewModel.sortAscending ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                            }
                                        }
                                    }
                                }
                                Divider()
                                Button(action: {
                                    viewModel.sortAscending = true
                                }) {
                                    HStack {
                                        Text("De forma ascendente")
                                        if viewModel.sortAscending {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                }
                                Button(action: {
                                    viewModel.sortAscending = false
                                }) {
                                    HStack {
                                        Text("De forma descendente")
                                        if !viewModel.sortAscending {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                }
                            } label: {
                                Label("Ordenar", systemImage: "arrow.up.arrow.down.circle.fill")
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .imageScale(.large)
                                .padding(.leading, -5)
                        }
                        .padding(.trailing, 5)
                    }
                    .padding(.horizontal, 15)
                    
                    if cattleListActive {
                        List {
                            ForEach(viewModel.filteredAndSortedCattle(cattle: cattle)) { item in
                                if !isSelecting {
                                    NavigationLink(destination: CattleDetailView(cattle: item)) {
                                        CattleRowView(cattle: item, isSelecting: isSelecting, isSelected: selectedCattle.contains(item)) {
                                            if selectedCattle.contains(item) {
                                                selectedCattle.remove(item)
                                            } else {
                                                selectedCattle.insert(item)
                                            }
                                        }
                                    }
                                } else {
                                    CattleRowView(cattle: item, isSelecting: isSelecting, isSelected: selectedCattle.contains(item)) {
                                        if selectedCattle.contains(item) {
                                            selectedCattle.remove(item)
                                        } else {
                                            selectedCattle.insert(item)
                                        }
                                    }
                                }
                            }
                        }
                        
                    } else {
                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(), count: 2), spacing: 20) {
                                ForEach(viewModel.filteredAndSortedCattle(cattle: cattle)) { item in
                                    if !isSelecting {
                                        NavigationLink(destination: CattleDetailView(cattle: item)) {
                                            CattleRowView(cattle: item, isSelecting: isSelecting, isSelected: selectedCattle.contains(item)) {
                                                if selectedCattle.contains(item) {
                                                    selectedCattle.remove(item)
                                                } else {
                                                    selectedCattle.insert(item)
                                                }
                                            }
                                            .onAppear {
                                                // Desactivar isSelecting cuando se navega a la vista de detalle de ganado
                                                isSelecting = false
                                            }
                                        }
                                        
                                        .buttonStyle(PlainButtonStyle())
                                    } else {
                                        CattleGridView(cattle: item, isSelecting: isSelecting, isSelected: selectedCattle.contains(item)) {
                                            if selectedCattle.contains(item) {
                                                selectedCattle.remove(item)
                                            } else {
                                                selectedCattle.insert(item)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            .padding(.top, 35)
                        }
                        
                    }
                    
                    ZStack{
                        HStack {
                            if cattle.count > 1 {
                                Text("\(cattle.count) fichas")
                                    .font(.subheadline)
                            } else {
                                Text("\(cattle.count) ficha")
                                    .font(.subheadline)
                            }
                        }
                        HStack {
                            Spacer(minLength: 350)
                            NavigationLink(destination: TrashCattleView()) {
                                Image(systemName: "trash")
                                    .imageScale(.large)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
                    }
                    
                }
                
                .navigationBarItems(
                    leading: {
                        Group {
                            if isSelecting && !selectedCattle.isEmpty {
                                Button(action: {
                                    selectedCattle.forEach { cattle in
                                        moveToTrash(cattle: cattle)
                                    }
                                    selectedCattle.removeAll()
                                    isSelecting = false
                                }) {
                                    Image(systemName: "trash")
                                }
                            } else {
                                if isSelecting{
                                    //Espacio vacio
                                    Button(action: {
                                    }) {
                                        Image(systemName: "")
                                    }
                                } else {
                                    Button(action: {
                                        // Acción del primer botón (qrcode.viewfinder)
                                    }) {
                                        Image(systemName: "qrcode.viewfinder")
                                    }
                                }
                            }
                        }
                    }(),
                    trailing: {
                        Group {
                            if isSelecting {
                                Button(action: {
                                    isSelecting = false
                                }) {
                                    Text("Listo")
                                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                }
                            } else {
                                Button(action: {
                                    showingAddCattleView.toggle()
                                }) {
                                    Image(systemName: "doc.badge.plus")
                                }
                            }
                        }
                    }()
                )
                
                .sheet(isPresented: $showingAddCattleView) {
                    AddCattleView().environment(\.managedObjectContext, viewContext)
                    // Desactivar isSelecting cuando se presenta la vista de agregar ganado
                        .onAppear {
                            isSelecting = false
                        }
                }
                
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ShouldRefreshContentView"))) { _ in
            shouldRefresh.toggle()
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: viewContext, queue: .main) { _ in
                shouldRefresh.toggle()
            }
            deleteOldTrashedItems()
        }
    }
    
    private func moveToTrash(cattle: Cattle) {
        cattle.fechaEliminado = Date()
        do {
            try viewContext.save()
        } catch {
            // Manejar el error
            print("Error al mover la ficha a la papelera: \(error.localizedDescription)")
        }
    }
    
    private func deleteOldTrashedItems() {
        let fetchRequest: NSFetchRequest<Cattle> = Cattle.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "fechaEliminado != nil AND fechaEliminado <= %@", Date().addingTimeInterval(-30*24*60*60) as CVarArg)
        
        do {
            let oldTrashedItems = try viewContext.fetch(fetchRequest)
            for item in oldTrashedItems {
                viewContext.delete(item)
            }
            try viewContext.save()
        } catch {
            // Manejar el error
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return ContentView().environment(\.managedObjectContext, context)
    }
}
