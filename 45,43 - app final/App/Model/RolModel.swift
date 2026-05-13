//
//  RolModel.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import Foundation

// MARK: - Permisos fijos del sistema
struct PermisosRol: Codable {
    var puedeReservar: Bool          // Reserva autoconfirmada
    var puedeSolicitar: Bool         // Enviar solicitud de reservación
    var puedeAprobar: Bool           // Aprobar / rechazar solicitudes
    var puedeVerHistorial: Bool      // Ver historial completo de reservaciones
    var puedeGestionarUsuarios: Bool // Agregar, editar, eliminar usuarios
    var puedeGestionarRoles: Bool    // Modificar roles y permisos
    var puedeGestionarSalas: Bool    // Agregar, editar, eliminar salas

    // MARK: - Presets por tipo de rol
    static var administrador: PermisosRol {
        PermisosRol(
            puedeReservar: true,
            puedeSolicitar: true,
            puedeAprobar: true,
            puedeVerHistorial: true,
            puedeGestionarUsuarios: true,
            puedeGestionarRoles: true,
            puedeGestionarSalas: true
        )
    }

    static var directivo: PermisosRol {
        PermisosRol(
            puedeReservar: true,
            puedeSolicitar: true,
            puedeAprobar: false,
            puedeVerHistorial: false,
            puedeGestionarUsuarios: false,
            puedeGestionarRoles: false,
            puedeGestionarSalas: false
        )
    }

    static var jefatura: PermisosRol {
        PermisosRol(
            puedeReservar: false,
            puedeSolicitar: true,
            puedeAprobar: false,
            puedeVerHistorial: false,
            puedeGestionarUsuarios: false,
            puedeGestionarRoles: false,
            puedeGestionarSalas: false
        )
    }

    static var sinPermisos: PermisosRol {
        PermisosRol(
            puedeReservar: false,
            puedeSolicitar: false,
            puedeAprobar: false,
            puedeVerHistorial: false,
            puedeGestionarUsuarios: false,
            puedeGestionarRoles: false,
            puedeGestionarSalas: false
        )
    }
}

// MARK: - Rol del sistema
struct Rol: Identifiable {
    let id: Int
    var nombre: String
    var permisos: PermisosRol
    var esRolBase: Bool  // true = administrador, directivo, jefatura (no se pueden eliminar)

    // MARK: - Helpers
    /// Convierte permisos a JSON String para guardar en SQLite
    func permisosJSON() -> String {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(permisos),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return "{}"
    }

    /// Reconstruye permisos desde JSON String
    static func permisosDesdJSON(_ json: String) -> PermisosRol {
        guard let data = json.data(using: .utf8) else { return .sinPermisos }
        let decoder = JSONDecoder()
        return (try? decoder.decode(PermisosRol.self, from: data)) ?? .sinPermisos
    }
}
