//
//  Cattle+CoreDataProperties.swift
//  CowTrack
//
//  Created by Alejandro on 12/07/24.
//
//

import Foundation
import CoreData

extension Cattle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cattle> {
        return NSFetchRequest<Cattle>(entityName: "Cattle")
    }

    @NSManaged public var comprador: String?
    @NSManaged public var docCom: Data?
    @NSManaged public var docVen: Data?
    @NSManaged public var especie: String?
    @NSManaged public var fechaCom: Date?
    @NSManaged public var fechaCreacion: Date?
    @NSManaged public var fechaEliminado: Date?
    @NSManaged public var fechaVen: Date?
    @NSManaged public var id: String?
    @NSManaged public var preCom: Double
    @NSManaged public var preVen: Double
    @NSManaged public var proveedor: String?
    @NSManaged public var qr: Data?
    @NSManaged public var raza: String?
    @NSManaged public var sexo: String?
}

extension Cattle: Identifiable {

}
