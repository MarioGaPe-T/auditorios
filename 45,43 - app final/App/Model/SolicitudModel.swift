//
//  SolicitudModel.swift
//  45,43 - app final
//
//  Created by Alumno on 21/04/26.
//

import Foundation

// MARK: - Estado de solicitud
enum EstadoSolicitud: String {
    case pendiente = "pendiente"
    case aprobada = "aprobada"
    case rechazada = "rechazada"
    case porConfirmar = "por_confirmar"
}


// MARK: - Solicitud completa
struct Solicitud: Identifiable {
    let id: Int
    let usuarioId: Int
    let usuario: String        // nombre del solicitante
    let correo: String         // correo del solicitante
    let sala: String           // sala A o B
    let fecha: String          // fecha seleccionada en el calendario
    let horaInicio: String     // ej. "08:00"
    let horaFin: String        // ej. "09:00"
    let motivo: String         // motivo de la reservación
    let necesitaMicrofono: Bool
    let necesitaBocina: Bool
    let necesitaProyector: Bool
    let estado: EstadoSolicitud
}

// MARK: - Formulario de nueva solicitud (usado en FormularioSolicitudView)
struct FormularioSolicitud {
    var sala: String = ""
    var fecha: String = ""
    var horaInicio: String = ""
    var horaFin: String = ""
    var motivo: String = ""
    var necesitaMicrofono: Bool = false
    var necesitaBocina: Bool = false
    var necesitaProyector: Bool = false
}
