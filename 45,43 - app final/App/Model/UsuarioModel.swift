import Foundation

enum RolUsuario: String, Codable {
    case administrador = "administrador"
    case directivo     = "directivo"
    case jefatura      = "jefatura"

    var descripcion: String {
        switch self {
        case .administrador:
            return "Administrador"
        case .directivo:
            return "Directivo"
        case .jefatura:
            return "Jefatura"
        }
    }
}

struct Usuario: Identifiable {
    let id: Int
    var nombre: String
    var correo: String
    var rol: RolUsuario

    var rolDescripcion: String {
        return rol.descripcion
    }
}
