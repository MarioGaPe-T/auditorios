//
//  AuthManager.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import Foundation

class AuthManager {

    // MARK: - Singleton
    static let shared = AuthManager()
    private init() {}

    // Usuario activo en sesión
    private(set) var usuarioActual: Usuario? = nil

    // MARK: - Iniciar sesión
    func iniciarSesion(correo: String, contrasena: String) -> Result<Usuario, ErrorAutenticacion> {

        // Buscar usuario en SQLite
        guard let resultado = DatabaseManager.shared.buscarUsuario(correo: correo) else {
            return .failure(.correoNoRegistrado)
        }

        // Verificar contraseña
        guard resultado.contrasena == contrasena else {
            return .failure(.contrasenaIncorrecta)
        }

        // Guardar sesión activa
        usuarioActual = resultado.usuario
        print("✅ Sesión iniciada: \(resultado.usuario.nombre) [\(resultado.usuario.rol.descripcion)]")

        return .success(resultado.usuario)
    }

    // MARK: - Cerrar sesión
    func cerrarSesion() {
        print("🔒 Sesión cerrada: \(usuarioActual?.nombre ?? "desconocido")")
        usuarioActual = nil
    }

    // MARK: - Verificar si hay sesión activa
    var hayUsuarioActivo: Bool {
        return usuarioActual != nil
    }
}
