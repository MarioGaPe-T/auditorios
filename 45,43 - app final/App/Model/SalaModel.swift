//
//  SalaModel.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import Foundation

// MARK: - Sala
struct Sala: Identifiable {
    let id: Int
    var nombre: String         // ej. "Sala A", "Sala B"
    var descripcion: String    // descripción breve
    var capacidad: Int         // número de personas
    var tieneMicrofono: Bool   // equipo disponible
    var tieneBocina: Bool
    var tieneProyector: Bool
    var activa: Bool           // si está disponible para reservar
}
