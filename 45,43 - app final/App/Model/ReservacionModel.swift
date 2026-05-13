//
//  ReservacionModel.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import Foundation

// MARK: - Tipo de reservación
enum TipoReservacion: String {
    case confirmada = "confirmada"   // Directivo / Administrador → autoconfirmada
    case solicitud  = "solicitud"    // Jefatura → requiere aprobación
}

// MARK: - Reservación (historial)
struct Reservacion: Identifiable {
    let id: Int
    let usuarioId: Int
    let nombreUsuario: String
    let sala: String
    let fecha: String
    let horaInicio: String
    let horaFin: String
    let tipo: TipoReservacion
}

// MARK: - Bloque de horario para el calendario


struct BloqueHorario: Identifiable {
    let id = UUID()
    let etiquetaDia: String?
    let horaInicio: String
    let horaFin: String
    var disponible: Bool
}
