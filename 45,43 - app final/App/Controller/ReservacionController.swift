//
//  ReservacionController.swift
//  45,43 - app final
//

import Foundation

class ReservacionController {

    // MARK: - Singleton
    static let shared = ReservacionController()
    private init() {}

    // MARK: - Procesar acción según rol
    func procesarAccion(
        usuario: Usuario,
        bloques: [BloqueHorario],
        sala: String
    ) -> String {

        guard !bloques.isEmpty else {
            return "Selecciona al menos un horario."
        }

        let fecha = fechaActual()
        let horaInicio = bloques.first?.horaInicio ?? ""
        let horaFin = bloques.last?.horaFin ?? ""
        let hora = "\(horaInicio) - \(horaFin)"

        switch usuario.rol {

        case .administrador:
            let exito = DatabaseManager.shared.insertarReservacion(
                usuarioId: usuario.id,
                nombreUsuario: usuario.nombre,
                sala: sala,
                fecha: fecha,
                horaInicio: horaInicio,
                horaFin: horaFin,
                tipo: .confirmada
            )

            return exito
                ? "✅ Reservación confirmada para \(sala) — \(hora)"
                : "❌ Error al guardar la reservación."

        case .directivo:
            let exito = DatabaseManager.shared.insertarReservacion(
                usuarioId: usuario.id,
                nombreUsuario: usuario.nombre,
                sala: sala,
                fecha: fecha,
                horaInicio: horaInicio,
                horaFin: horaFin,
                tipo: .confirmada
            )

            return exito
                ? "✅ Reservación confirmada automáticamente — \(hora)"
                : "❌ Error al guardar la reservación."

        case .jefatura:
            let exito = DatabaseManager.shared.insertarSolicitud(
                usuarioId: usuario.id,
                usuario: usuario.nombre,
                correo: usuario.correo,
                sala: sala,
                fecha: fecha,
                horaInicio: horaInicio,
                horaFin: horaFin,
                motivo: "Reservación de sala audiovisual",
                necesitaMicrofono: false,
                necesitaBocina: false,
                necesitaProyector: false
            )

            return exito
                ? "📋 Solicitud enviada. Pendiente de aprobación del administrador."
                : "❌ Error al enviar la solicitud."
        }
    }

    // MARK: - Fecha actual formateada
    private func fechaActual() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: Date())
    }
}
