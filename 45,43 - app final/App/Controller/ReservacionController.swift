//
//  ReservacionController.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import Foundation

class ReservacionController {

    // MARK: - Singleton
    static let shared = ReservacionController()
    private init() {}

    // MARK: - Procesar acción según rol
    /// Devuelve un mensaje de resultado para mostrar en la UI
    func procesarAccion(
        usuario: Usuario,
        bloques: [BloqueHorario],
        sala: String
    ) -> String {

        guard !bloques.isEmpty else {
            return "Selecciona al menos un horario."
        }

        let fecha      = fechaActual()
        let horaInicio = bloques.first?.horaInicio ?? ""
        let horaFin    = bloques.last?.horaFin ?? ""
        let hora       = "\(horaInicio) - \(horaFin)"

        switch usuario.rol {

        // ─── Administrador: reserva directa confirmada ───────────────────────
        case .administrador:
            let exito = DatabaseManager.shared.insertarReservacion(
                usuarioId:     usuario.id,
                nombreUsuario: usuario.nombre,
                sala:          sala,
                fecha:         fecha,
                horaInicio:    horaInicio,
                horaFin:       horaFin,
                tipo:          .confirmada
            )
            return exito
                ? "✅ Reservación confirmada para \(sala) — \(hora)"
                : "❌ Error al guardar la reservación."

        // ─── Directivo: reserva autoconfirmada ───────────────────────────────
        case .directivo:
            let exito = DatabaseManager.shared.insertarReservacion(
                usuarioId:     usuario.id,
                nombreUsuario: usuario.nombre,
                sala:          sala,
                fecha:         fecha,
                horaInicio:    horaInicio,
                horaFin:       horaFin,
                tipo:          .confirmada
            )
            return exito
                ? "✅ Reservación confirmada automáticamente — \(hora)"
                : "❌ Error al guardar la reservación."

        // ─── Jefatura: genera solicitud pendiente de aprobación ──────────────
        case .jefatura:
            let exito = DatabaseManager.shared.insertarSolicitud(
                usuario: usuario.nombre,
                sala:    sala,
                fecha:   fecha,
                hora:    hora
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
