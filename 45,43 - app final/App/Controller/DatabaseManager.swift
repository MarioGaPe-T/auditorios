//
//  DatabaseManager.swift
//  45,43 - app final
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

        // Cambié el nombre para evitar conflictos con tablas viejas del simulador.
        // Si quieres conservar tu base anterior, vuelve a "audiovisual.sqlite".
        let rutaDB = rutaDocumentos.appendingPathComponent("audiovisual_v4.sqlite")

        if sqlite3_open(rutaDB.path, &db) != SQLITE_OK {
            print("❌ Error al abrir la base de datos: \(String(cString: sqlite3_errmsg(db)))")
        } else {
            print("✅ Base de datos abierta en: \(rutaDB.path)")
            ejecutarSQL("PRAGMA foreign_keys = ON;")
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
            ("Administrador", "admin@tuxtla.tecnm.mx", "admin123", "administrador"),
            ("Dir. General", "directivo@tuxtla.tecnm.mx", "dir123", "directivo"),
            ("Jefe de Área", "jefatura@tuxtla.tecnm.mx", "jef123", "jefatura")
        ]

        for usuario in usuarios {
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
                            sqlite3_bind_text(insertStatement, 1, (usuario.nombre as NSString).utf8String, -1, nil)
                            sqlite3_bind_text(insertStatement, 2, (usuario.correo as NSString).utf8String, -1, nil)
                            sqlite3_bind_text(insertStatement, 3, (usuario.contrasena as NSString).utf8String, -1, nil)
                            sqlite3_bind_text(insertStatement, 4, (usuario.rol as NSString).utf8String, -1, nil)

                            if sqlite3_step(insertStatement) == SQLITE_DONE {
                                print("✅ Usuario precargado: \(usuario.correo)")
                            }

                            sqlite3_finalize(insertStatement)
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

    private func textoColumna(_ statement: OpaquePointer?, _ index: Int32) -> String {
        guard let texto = sqlite3_column_text(statement, index) else {
            return ""
        }

        return String(cString: texto)
    }

    // MARK: - Buscar usuario por correo
    func buscarUsuario(correo: String) -> (contrasena: String, usuario: Usuario)? {
        let sql = "SELECT id, nombre, correo, contrasena, rol FROM usuarios WHERE correo = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando buscarUsuario: \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }

        sqlite3_bind_text(statement, 1, (correo as NSString).utf8String, -1, nil)

        if sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let nombre = textoColumna(statement, 1)
            let correoDB = textoColumna(statement, 2)
            let contrasena = textoColumna(statement, 3)
            let rolString = textoColumna(statement, 4)
            let rol = RolUsuario(rawValue: rolString) ?? .jefatura

            sqlite3_finalize(statement)

            let usuario = Usuario(
                id: id,
                nombre: nombre,
                correo: correoDB,
                rol: rol
            )

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
        // Evita que jefatura duplique una solicitud activa en el mismo horario.
        if existeSolicitudActiva(
            sala: sala,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin
        ) {
            print("⚠️ Ya existe una solicitud activa en ese horario.")
            return false
        }

        // Si ya hay reservación confirmada, no se puede solicitar.
        if existeReservacionConfirmada(
            sala: sala,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin
        ) {
            print("⚠️ Ya existe una reservación confirmada en ese horario.")
            return false
        }

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
            ORDER BY
                CASE
                    WHEN estado = 'por_confirmar' THEN 0
                    WHEN estado = 'pendiente' THEN 1
                    WHEN estado = 'aprobada' THEN 2
                    WHEN estado = 'rechazada' THEN 3
                    ELSE 4
                END,
                id DESC;
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
            let usuario = textoColumna(statement, 2)
            let correo = textoColumna(statement, 3)
            let sala = textoColumna(statement, 4)
            let fecha = textoColumna(statement, 5)
            let horaInicio = textoColumna(statement, 6)
            let horaFin = textoColumna(statement, 7)
            let motivo = textoColumna(statement, 8)
            let necesitaMicrofono = sqlite3_column_int(statement, 9) == 1
            let necesitaBocina = sqlite3_column_int(statement, 10) == 1
            let necesitaProyector = sqlite3_column_int(statement, 11) == 1
            let estadoStr = textoColumna(statement, 12)
            let estado = EstadoSolicitud(rawValue: estadoStr) ?? .pendiente

            let solicitud = Solicitud(
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

            solicitudes.append(solicitud)
        }

        sqlite3_finalize(statement)
        return solicitudes
    }

    // MARK: - Actualizar estado de solicitud
    func actualizarEstadoSolicitud(id: Int, nuevoEstado: EstadoSolicitud) {
        let sql = "UPDATE solicitudes SET estado = ? WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando actualizarEstadoSolicitud: \(String(cString: sqlite3_errmsg(db)))")
            return
        }

        sqlite3_bind_text(statement, 1, (nuevoEstado.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(id))

        if sqlite3_step(statement) != SQLITE_DONE {
            print("❌ Error actualizando solicitud: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
    }

    // MARK: - Aprobar solicitud
    func aprobarSolicitud(_ solicitud: Solicitud) -> Bool {
        // Si alguien ya confirmó ese horario, se rechaza la solicitud.
        if existeReservacionConfirmada(
            sala: solicitud.sala,
            fecha: solicitud.fecha,
            horaInicio: solicitud.horaInicio,
            horaFin: solicitud.horaFin
        ) {
            actualizarEstadoSolicitud(id: solicitud.id, nuevoEstado: .rechazada)
            return false
        }

        let seGuardoReservacion = insertarReservacion(
            usuarioId: solicitud.usuarioId,
            nombreUsuario: solicitud.usuario,
            sala: solicitud.sala,
            fecha: solicitud.fecha,
            horaInicio: solicitud.horaInicio,
            horaFin: solicitud.horaFin,
            tipo: .confirmada,
            exceptoSolicitudId: solicitud.id
        )

        guard seGuardoReservacion else {
            return false
        }

        actualizarEstadoSolicitud(id: solicitud.id, nuevoEstado: .aprobada)
        return true
    }

    // MARK: - Rechazar solicitud
    func rechazarSolicitud(id: Int) {
        actualizarEstadoSolicitud(id: id, nuevoEstado: .rechazada)
    }

    // MARK: - Insertar reservación confirmada
    func insertarReservacion(
        usuarioId: Int,
        nombreUsuario: String,
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String,
        tipo: TipoReservacion,
        exceptoSolicitudId: Int? = nil
    ) -> Bool {
        // No permite dos reservaciones confirmadas en el mismo horario.
        if existeReservacionConfirmada(
            sala: sala,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin
        ) {
            print("⚠️ Ya existe una reservación confirmada en ese horario.")
            return false
        }

        let sql = """
            INSERT INTO reservaciones (
                usuario_id,
                nombre_usuario,
                sala,
                fecha,
                hora_inicio,
                hora_fin,
                tipo
            )
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando insertarReservacion: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_int(statement, 1, Int32(usuarioId))
        sqlite3_bind_text(statement, 2, (nombreUsuario as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (sala as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (fecha as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (horaInicio as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 6, (horaFin as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 7, (tipo.rawValue as NSString).utf8String, -1, nil)

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error insertando reservación: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)

        if resultado {
            // Si se confirmó una reservación, las demás solicitudes en conflicto se rechazan.
            rechazarSolicitudesEnConflicto(
                sala: sala,
                fecha: fecha,
                horaInicio: horaInicio,
                horaFin: horaFin,
                exceptoSolicitudId: exceptoSolicitudId
            )
        }

        return resultado
    }

    // MARK: - Estado de horario
    func estadoHorario(
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String
    ) -> EstadoBloqueHorario {
        if existeReservacionConfirmada(
            sala: sala,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin
        ) {
            return .ocupado
        }

        if existeSolicitudActiva(
            sala: sala,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin
        ) {
            return .porConfirmar
        }

        return .disponible
    }

    // MARK: - Verificar reservación confirmada
    func existeReservacionConfirmada(
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String
    ) -> Bool {
        let sql = """
            SELECT COUNT(*)
            FROM reservaciones
            WHERE sala = ?
            AND fecha = ?
            AND hora_inicio < ?
            AND hora_fin > ?;
        """

        var statement: OpaquePointer?
        var existe = false

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (sala as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (fecha as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (horaFin as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (horaInicio as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_ROW {
                existe = sqlite3_column_int(statement, 0) > 0
            }
        } else {
            print("❌ Error preparando existeReservacionConfirmada: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return existe
    }

    // MARK: - Verificar solicitud activa
    func existeSolicitudActiva(
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String
    ) -> Bool {
        let sql = """
            SELECT COUNT(*)
            FROM solicitudes
            WHERE sala = ?
            AND fecha = ?
            AND estado IN ('pendiente', 'por_confirmar')
            AND hora_inicio < ?
            AND hora_fin > ?;
        """

        var statement: OpaquePointer?
        var existe = false

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (sala as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (fecha as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (horaFin as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (horaInicio as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) == SQLITE_ROW {
                existe = sqlite3_column_int(statement, 0) > 0
            }
        } else {
            print("❌ Error preparando existeSolicitudActiva: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return existe
    }

    // MARK: - Rechazar solicitudes en conflicto
    func rechazarSolicitudesEnConflicto(
        sala: String,
        fecha: String,
        horaInicio: String,
        horaFin: String,
        exceptoSolicitudId: Int? = nil
    ) {
        var sql = """
            UPDATE solicitudes
            SET estado = 'rechazada'
            WHERE sala = ?
            AND fecha = ?
            AND estado IN ('pendiente', 'por_confirmar')
            AND hora_inicio < ?
            AND hora_fin > ?
        """

        if exceptoSolicitudId != nil {
            sql += " AND id != ?"
        }

        sql += ";"

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando rechazarSolicitudesEnConflicto: \(String(cString: sqlite3_errmsg(db)))")
            return
        }

        sqlite3_bind_text(statement, 1, (sala as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (fecha as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (horaFin as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (horaInicio as NSString).utf8String, -1, nil)

        if let exceptoSolicitudId = exceptoSolicitudId {
            sqlite3_bind_int(statement, 5, Int32(exceptoSolicitudId))
        }

        if sqlite3_step(statement) != SQLITE_DONE {
            print("❌ Error rechazando solicitudes en conflicto: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
    }
}
