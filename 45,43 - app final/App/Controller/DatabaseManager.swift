//
//  DatabaseManager.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import Foundation
import SQLite3

class DatabaseManager {

    // MARK: - Singleton
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        abrirBaseDeDatos()
        crearTablas()
        insertarUsuariosPrecargados()
    }

    // MARK: - Abrir BD
    private func abrirBaseDeDatos() {
        let rutaDocumentos = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        let rutaDB = rutaDocumentos.appendingPathComponent("audiovisual.sqlite")

        if sqlite3_open(rutaDB.path, &db) != SQLITE_OK {
            print("❌ Error al abrir la base de datos: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            print("✅ Base de datos abierta en: \(rutaDB.path)")
        }
    }

    // MARK: - Crear tablas
    private func crearTablas() {
        let sqlUsuarios = """
            CREATE TABLE IF NOT EXISTS usuarios (
                id          INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre      TEXT NOT NULL,
                correo      TEXT NOT NULL UNIQUE,
                contrasena  TEXT NOT NULL,
                rol         TEXT NOT NULL
            );
        """

        let sqlSolicitudes = """
            CREATE TABLE IF NOT EXISTS solicitudes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                usuario_id INTEGER NOT NULL,
                usuario TEXT NOT NULL,
                correo TEXT NOT NULL,
                sala TEXT NOT NULL,
                fecha TEXT NOT NULL,
                hora_inicio TEXT NOT NULL,
                hora_fin TEXT NOT NULL,
                motivo TEXT NOT NULL,
                necesita_microfono INTEGER NOT NULL DEFAULT 0,
                necesita_bocina INTEGER NOT NULL DEFAULT 0,
                necesita_proyector INTEGER NOT NULL DEFAULT 0,
                estado TEXT NOT NULL DEFAULT 'pendiente',
                FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
            );
        """

        let sqlReservaciones = """
            CREATE TABLE IF NOT EXISTS reservaciones (
                id              INTEGER PRIMARY KEY AUTOINCREMENT,
                usuario_id      INTEGER NOT NULL,
                nombre_usuario  TEXT NOT NULL,
                sala            TEXT NOT NULL,
                fecha           TEXT NOT NULL,
                hora_inicio     TEXT NOT NULL,
                hora_fin        TEXT NOT NULL,
                tipo            TEXT NOT NULL,
                FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
            );
        """

        ejecutarSQL(sqlUsuarios)
        ejecutarSQL(sqlSolicitudes)
        ejecutarSQL(sqlReservaciones)
    }

    
    // MARK: - Usuarios precargados
    private func insertarUsuariosPrecargados() {
        let usuarios: [(nombre: String, correo: String, contrasena: String, rol: String)] = [
            ("Administrador",   "admin@tuxtla.tecnm.mx",     "admin123", "administrador"),
            ("Dir. General",    "directivo@tuxtla.tecnm.mx", "dir123",   "directivo"),
            ("Jefe de Área",    "jefatura@tuxtla.tecnm.mx",  "jef123",   "jefatura")
        ]

        for usuario in usuarios {
            // Solo insertar si el correo no existe
            let sqlVerificar = "SELECT COUNT(*) FROM usuarios WHERE correo = ?;"
            var statement: OpaquePointer?

            if sqlite3_prepare_v2(db, sqlVerificar, -1, &statement, nil) == SQLITE_OK {
                sqlite3_bind_text(statement, 1, (usuario.correo as NSString).utf8String, -1, nil)

                if sqlite3_step(statement) == SQLITE_ROW {
                    let count = sqlite3_column_int(statement, 0)
                    sqlite3_finalize(statement)

                    if count == 0 {
                        let sqlInsertar = """
                            INSERT INTO usuarios (nombre, correo, contrasena, rol)
                            VALUES (?, ?, ?, ?);
                        """
                        var insertStatement: OpaquePointer?
                        if sqlite3_prepare_v2(db, sqlInsertar, -1, &insertStatement, nil) == SQLITE_OK {
                            sqlite3_bind_text(insertStatement, 1, (usuario.nombre     as NSString).utf8String, -1, nil)
                            sqlite3_bind_text(insertStatement, 2, (usuario.correo     as NSString).utf8String, -1, nil)
                            sqlite3_bind_text(insertStatement, 3, (usuario.contrasena as NSString).utf8String, -1, nil)
                            sqlite3_bind_text(insertStatement, 4, (usuario.rol        as NSString).utf8String, -1, nil)
                            sqlite3_step(insertStatement)
                            sqlite3_finalize(insertStatement)
                            print("✅ Usuario precargado: \(usuario.correo)")
                        }
                    }
                } else {
                    sqlite3_finalize(statement)
                }
            }
        }
    }

    // MARK: - Ejecutar SQL genérico
    private func ejecutarSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        } else {
            print("❌ Error SQL: \(String(cString: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(statement)
    }

    // MARK: - Buscar usuario por correo
    func buscarUsuario(correo: String) -> (contrasena: String, usuario: Usuario)? {
        let sql = "SELECT id, nombre, correo, contrasena, rol FROM usuarios WHERE correo = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return nil
        }

        sqlite3_bind_text(statement, 1, (correo as NSString).utf8String, -1, nil)

        if sqlite3_step(statement) == SQLITE_ROW {
            let id         = Int(sqlite3_column_int(statement, 0))
            let nombre     = String(cString: sqlite3_column_text(statement, 1))
            let correoDB   = String(cString: sqlite3_column_text(statement, 2))
            let contrasena = String(cString: sqlite3_column_text(statement, 3))
            let rolString  = String(cString: sqlite3_column_text(statement, 4))
            let rol        = RolUsuario(rawValue: rolString) ?? .jefatura

            sqlite3_finalize(statement)

            let usuario = Usuario(id: id, nombre: nombre, correo: correoDB, rol: rol)
            return (contrasena, usuario)
        }

        sqlite3_finalize(statement)
        return nil
    }

    // MARK: - Insertar solicitud
    func insertarSolicitud(
        usuarioId: Int,
        usuario: String,
        correo: String,
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String,
        motivo: String,
        necesitaMicrofono: Bool,
        necesitaBocina: Bool,
        necesitaProyector: Bool,
        estado: EstadoSolicitud
    ) -> Bool {
        let sql = """
            INSERT INTO solicitudes (
                usuario_id,
                usuario,
                correo,
                sala,
                fecha,
                hora_inicio,
                hora_fin,
                motivo,
                necesita_microfono,
                necesita_bocina,
                necesita_proyector,
                estado
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando insertarSolicitud: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_int(statement, 1, Int32(usuarioId))
        sqlite3_bind_text(statement, 2, (usuario as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (correo as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (sala as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (fecha as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 6, (horaInicio as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 7, (horaFin as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 8, (motivo as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 9, necesitaMicrofono ? 1 : 0)
        sqlite3_bind_int(statement, 10, necesitaBocina ? 1 : 0)
        sqlite3_bind_int(statement, 11, necesitaProyector ? 1 : 0)
        sqlite3_bind_text(statement, 12, (estado.rawValue as NSString).utf8String, -1, nil)

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error insertando solicitud: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return resultado
    }

    // MARK: - Obtener solicitudes
    func obtenerSolicitudes() -> [Solicitud] {
        let sql = """
            SELECT
                id,
                usuario_id,
                usuario,
                correo,
                sala,
                fecha,
                hora_inicio,
                hora_fin,
                motivo,
                necesita_microfono,
                necesita_bocina,
                necesita_proyector,
                estado
            FROM solicitudes
            ORDER BY id DESC;
        """

        var statement: OpaquePointer?
        var solicitudes: [Solicitud] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando obtenerSolicitudes: \(String(cString: sqlite3_errmsg(db)))")
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let usuarioId = Int(sqlite3_column_int(statement, 1))
            let usuario = String(cString: sqlite3_column_text(statement, 2))
            let correo = String(cString: sqlite3_column_text(statement, 3))
            let sala = String(cString: sqlite3_column_text(statement, 4))
            let fecha = String(cString: sqlite3_column_text(statement, 5))
            let horaInicio = String(cString: sqlite3_column_text(statement, 6))
            let horaFin = String(cString: sqlite3_column_text(statement, 7))
            let motivo = String(cString: sqlite3_column_text(statement, 8))
            let necesitaMicrofono = sqlite3_column_int(statement, 9) == 1
            let necesitaBocina = sqlite3_column_int(statement, 10) == 1
            let necesitaProyector = sqlite3_column_int(statement, 11) == 1
            let estadoStr = String(cString: sqlite3_column_text(statement, 12))
            let estado = EstadoSolicitud(rawValue: estadoStr) ?? .pendiente

            solicitudes.append(
                Solicitud(
                    id: id,
                    usuarioId: usuarioId,
                    usuario: usuario,
                    correo: correo,
                    sala: sala,
                    fecha: fecha,
                    horaInicio: horaInicio,
                    horaFin: horaFin,
                    motivo: motivo,
                    necesitaMicrofono: necesitaMicrofono,
                    necesitaBocina: necesitaBocina,
                    necesitaProyector: necesitaProyector,
                    estado: estado
                )
            )
        }

        sqlite3_finalize(statement)
        return solicitudes
    }

    // MARK: - Actualizar estado de solicitud
    func actualizarEstadoSolicitud(id: Int, nuevoEstado: EstadoSolicitud) {
        let sql = "UPDATE solicitudes SET estado = ? WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return
        }

        sqlite3_bind_text(statement, 1, (nuevoEstado.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement,  2, Int32(id))
        sqlite3_step(statement)
        sqlite3_finalize(statement)
    }

    // MARK: - Insertar reservación confirmada
    func insertarReservacion(
        usuarioId: Int,
        nombreUsuario: String,
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String,
        tipo: TipoReservacion
    ) -> Bool {
        let sql = """
            INSERT INTO reservaciones (usuario_id, nombre_usuario, sala, fecha, hora_inicio, hora_fin, tipo)
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int(statement,  1, Int32(usuarioId))
        sqlite3_bind_text(statement, 2, (nombreUsuario as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (sala          as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (fecha         as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (horaInicio    as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 6, (horaFin       as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 7, (tipo.rawValue as NSString).utf8String, -1, nil)

        let resultado = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return resultado
    }
    
    func estadoHorario(
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String
    ) -> EstadoBloqueHorario {

        // 1. Primero revisar si ya existe una reservación confirmada
        let sqlReservacion = """
            SELECT COUNT(*)
            FROM reservaciones
            WHERE sala = ?
            AND fecha = ?
            AND hora_inicio < ?
            AND hora_fin > ?;
        """

        var statementReservacion: OpaquePointer?
        var ocupado = false

        if sqlite3_prepare_v2(db, sqlReservacion, -1, &statementReservacion, nil) == SQLITE_OK {
            sqlite3_bind_text(statementReservacion, 1, (sala as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statementReservacion, 2, (fecha as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statementReservacion, 3, (horaFin as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statementReservacion, 4, (horaInicio as NSString).utf8String, -1, nil)

            if sqlite3_step(statementReservacion) == SQLITE_ROW {
                ocupado = sqlite3_column_int(statementReservacion, 0) > 0
            }
        }

        sqlite3_finalize(statementReservacion)

        if ocupado {
            return .ocupado
        }

        // 2. Luego revisar si existe una solicitud apartada o pendiente
        let sqlSolicitud = """
            SELECT COUNT(*)
            FROM solicitudes
            WHERE sala = ?
            AND fecha = ?
            AND estado IN ('pendiente', 'por_confirmar')
            AND hora_inicio < ?
            AND hora_fin > ?;
        """

        var statementSolicitud: OpaquePointer?
        var porConfirmar = false

        if sqlite3_prepare_v2(db, sqlSolicitud, -1, &statementSolicitud, nil) == SQLITE_OK {
            sqlite3_bind_text(statementSolicitud, 1, (sala as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statementSolicitud, 2, (fecha as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statementSolicitud, 3, (horaFin as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statementSolicitud, 4, (horaInicio as NSString).utf8String, -1, nil)

            if sqlite3_step(statementSolicitud) == SQLITE_ROW {
                porConfirmar = sqlite3_column_int(statementSolicitud, 0) > 0
            }
        }

        sqlite3_finalize(statementSolicitud)

        if porConfirmar {
            return .porConfirmar
        }

        return .disponible
    }
}
