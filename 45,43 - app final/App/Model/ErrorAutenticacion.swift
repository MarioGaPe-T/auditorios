//
//  ErrorAutenticacion.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import Foundation

// MARK: - Errores de autenticación
enum ErrorAutenticacion: Error {
    case correoNoRegistrado
    case contrasenaIncorrecta
    case camposVacios
    case errorBaseDatos

    var descripcion: String {
        switch self {
        case .correoNoRegistrado:  return "El correo no está registrado."
        case .contrasenaIncorrecta: return "La contraseña es incorrecta."
        case .camposVacios:        return "Por favor llena todos los campos."
        case .errorBaseDatos:      return "Error interno. Intenta de nuevo."
        }
    }
}

