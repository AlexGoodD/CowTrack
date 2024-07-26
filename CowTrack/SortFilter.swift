import SwiftUI
import CoreData

class SortFilterViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var sortOption: SortOption = .ninguno
    @Published var sortAscending = true // Variable para controlar el orden ascendente/descendente
    
    enum SortOption: String, CaseIterable, Identifiable {
        case ninguno
        case especie
        case raza
        case proveedor
        
        var id: String { self.rawValue }
    }
    
    func filteredAndSortedCattle(cattle: FetchedResults<Cattle>) -> [Cattle] {
            var filteredCattle = cattle.filter { cattle in
                let lowercasedSearchText = searchText.lowercased()
                return lowercasedSearchText.isEmpty ||
                    (cattle.id?.lowercased().contains(lowercasedSearchText) == true) ||
                    (cattle.especie?.lowercased().contains(lowercasedSearchText) == true) ||
                    (cattle.raza?.lowercased().contains(lowercasedSearchText) == true) ||
                    (cattle.proveedor?.lowercased().contains(lowercasedSearchText) == true)
            }
        
        switch sortOption {
        case .especie:
            filteredCattle.sort { (cattle1, cattle2) in
                if sortAscending {
                    return cattle1.especie ?? "" < cattle2.especie ?? ""
                } else {
                    return cattle1.especie ?? "" > cattle2.especie ?? ""
                }
            }
        case .raza:
            filteredCattle.sort { (cattle1, cattle2) in
                if sortAscending {
                    return cattle1.raza ?? "" < cattle2.raza ?? ""
                } else {
                    return cattle1.raza ?? "" > cattle2.raza ?? ""
                }
            }
        case .proveedor:
            filteredCattle.sort { (cattle1, cattle2) in
                if sortAscending {
                    return cattle1.proveedor ?? "" < cattle2.proveedor ?? ""
                } else {
                    return cattle1.proveedor ?? "" > cattle2.proveedor ?? ""
                }
            }
        case .ninguno:
            break
        }
        
        return filteredCattle
    }
}
