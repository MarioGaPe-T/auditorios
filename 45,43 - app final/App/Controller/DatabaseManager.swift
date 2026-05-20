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
        insertarSalasPrecargadas()
    }

    // MARK: - Abrir BD
    private func abrirBaseDeDatos() {
        let rutaDocumentos = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!

        // Nueva versión para crear tablas nuevas como salas y usuarios con estado activo.
        let rutaDB = rutaDocumentos.appendingPathComponent("audiovisual_v5.sqlite")

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
                rol         TEXT NOT NULL,
                activa      INTEGER NOT NULL DEFAULT 1
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

        let sqlSalas = """
            CREATE TABLE IF NOT EXISTS salas (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre TEXT NOT NULL UNIQUE,
                descripcion TEXT NOT NULL,
                capacidad INTEGER NOT NULL DEFAULT 0,
                tiene_microfono INTEGER NOT NULL DEFAULT 0,
                tiene_bocina INTEGER NOT NULL DEFAULT 0,
                tiene_proyector INTEGER NOT NULL DEFAULT 0,
                activa INTEGER NOT NULL DEFAULT 1
            );
        """

        ejecutarSQL(sqlUsuarios)
        ejecutarSQL(sqlSolicitudes)
        ejecutarSQL(sqlReservaciones)
        ejecutarSQL(sqlSalas)
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

    // MARK: - Usuarios precargados
    private func insertarUsuariosPrecargados() {
        let usuarios: [(nombre: String, correo: String, contrasena: String, rol: String)] = [
            ("Administrador", "admin@tuxtla.tecnm.mx", "admin123", "administrador"),
            ("Dir. General", "directivo@tuxtla.tecnm.mx", "dir123", "directivo"),
            ("Jefe de Área", "jefatura@tuxtla.tecnm.mx", "jef123", "jefatura")
        ]

        for usuario in usuarios {
            _ = insertarUsuarioSiNoExiste(
                nombre: usuario.nombre,
                correo: usuario.correo,
                contrasena: usuario.contrasena,
                rol: usuario.rol
            )
        }
    }

    private func insertarUsuarioSiNoExiste(
        nombre: String,
        correo: String,
        contrasena: String,
        rol: String
    ) -> Bool {
        let sql = """
            INSERT OR IGNORE INTO usuarios (nombre, correo, contrasena, rol, activa)
            VALUES (?, ?, ?, ?, 1);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando insertarUsuarioSiNoExiste: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (correo as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (contrasena as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (rol as NSString).utf8String, -1, nil)

        let resultado = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)

        return resultado
    }

    // MARK: - Buscar usuario por correo
    func buscarUsuario(correo: String) -> (contrasena: String, usuario: Usuario)? {
        let sql = """
            SELECT id, nombre, correo, contrasena, rol
            FROM usuarios
            WHERE correo = ?
            AND activa = 1;
        """

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

    // MARK: - Insertar usuario
    func insertarUsuario(
        nombre: String,
        correo: String,
        contrasena: String,
        rol: RolUsuario
    ) -> Bool {
        let sql = """
            INSERT INTO usuarios (nombre, correo, contrasena, rol, activa)
            VALUES (?, ?, ?, ?, 1);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando insertarUsuario: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (correo as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (contrasena as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (rol.rawValue as NSString).utf8String, -1, nil)

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error insertando usuario: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return resultado
    }

    // MARK: - Obtener usuarios
    func obtenerUsuarios(incluirInactivos: Bool = false) -> [Usuario] {
        let filtro = incluirInactivos ? "" : "WHERE activa = 1"

        let sql = """
            SELECT id, nombre, correo, rol
            FROM usuarios
            \(filtro)
            ORDER BY nombre ASC;
        """

        var statement: OpaquePointer?
        var usuarios: [Usuario] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando obtenerUsuarios: \(String(cString: sqlite3_errmsg(db)))")
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(statement, 0))
            let nombre = textoColumna(statement, 1)
            let correo = textoColumna(statement, 2)
            let rolString = textoColumna(statement, 3)
            let rol = RolUsuario(rawValue: rolString) ?? .jefatura

            usuarios.append(
                Usuario(
                    id: id,
                    nombre: nombre,
                    correo: correo,
                    rol: rol
                )
            )
        }

        sqlite3_finalize(statement)
        return usuarios
    }

    // MARK: - Actualizar usuario
    func actualizarUsuario(
        id: Int,
        nombre: String,
        correo: String,
        rol: RolUsuario,
        contrasena: String? = nil
    ) -> Bool {
        let cambiarContrasena = !(contrasena ?? "").isEmpty

        let sql: String

        if cambiarContrasena {
            sql = """
                UPDATE usuarios
                SET nombre = ?, correo = ?, rol = ?, contrasena = ?
                WHERE id = ?;
            """
        } else {
            sql = """
                UPDATE usuarios
                SET nombre = ?, correo = ?, rol = ?
                WHERE id = ?;
            """
        }

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando actualizarUsuario: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (correo as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (rol.rawValue as NSString).utf8String, -1, nil)

        if cambiarContrasena {
            sqlite3_bind_text(statement, 4, ((contrasena ?? "") as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 5, Int32(id))
        } else {
            sqlite3_bind_int(statement, 4, Int32(id))
        }

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error actualizando usuario: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return resultado
    }

    // MARK: - Eliminar usuario
    func eliminarUsuario(id: Int) -> Bool {
        guard let usuario = obtenerUsuarioPorId(id: id) else {
            return false
        }

        if usuario.rol == .administrador && contarAdministradoresActivos() <= 1 {
            print("⚠️ No se puede eliminar el último administrador activo.")
            return false
        }

        let sql = "UPDATE usuarios SET activa = 0 WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando eliminarUsuario: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_int(statement, 1, Int32(id))

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error eliminando usuario: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return resultado
    }

    func reactivarUsuario(id: Int) -> Bool {
        let sql = "UPDATE usuarios SET activa = 1 WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int(statement, 1, Int32(id))

        let resultado = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return resultado
    }

    private func obtenerUsuarioPorId(id: Int) -> Usuario? {
        let sql = """
            SELECT id, nombre, correo, rol
            FROM usuarios
            WHERE id = ?;
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return nil
        }

        sqlite3_bind_int(statement, 1, Int32(id))

        if sqlite3_step(statement) == SQLITE_ROW {
            let usuario = Usuario(
                id: Int(sqlite3_column_int(statement, 0)),
                nombre: textoColumna(statement, 1),
                correo: textoColumna(statement, 2),
                rol: RolUsuario(rawValue: textoColumna(statement, 3)) ?? .jefatura
            )

            sqlite3_finalize(statement)
            return usuario
        }

        sqlite3_finalize(statement)
        return nil
    }

    private func contarAdministradoresActivos() -> Int {
        let sql = """
            SELECT COUNT(*)
            FROM usuarios
            WHERE rol = 'administrador'
            AND activa = 1;
        """

        var statement: OpaquePointer?
        var total = 0

        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                total = Int(sqlite3_column_int(statement, 0))
            }
        }

        sqlite3_finalize(statement)
        return total
    }

    // MARK: - Salas precargadas
    private func insertarSalasPrecargadas() {
        _ = insertarSalaSiNoExiste(
            nombre: "Sala Audiovisual E",
            descripcion: "Sala principal audiovisual",
            capacidad: 40,
            tieneMicrofono: true,
            tieneBocina: true,
            tieneProyector: true,
            activa: true
        )

        _ = insertarSalaSiNoExiste(
            nombre: "Sala Audiovisual A",
            descripcion: "Sala audiovisual adicional",
            capacidad: 35,
            tieneMicrofono: true,
            tieneBocina: true,
            tieneProyector: true,
            activa: true
        )
    }

    private func insertarSalaSiNoExiste(
        nombre: String,
        descripcion: String,
        capacidad: Int,
        tieneMicrofono: Bool,
        tieneBocina: Bool,
        tieneProyector: Bool,
        activa: Bool
    ) -> Bool {
        let sql = """
            INSERT OR IGNORE INTO salas (
                nombre,
                descripcion,
                capacidad,
                tiene_microfono,
                tiene_bocina,
                tiene_proyector,
                activa
            )
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando insertarSalaSiNoExiste: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (descripcion as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(capacidad))
        sqlite3_bind_int(statement, 4, tieneMicrofono ? 1 : 0)
        sqlite3_bind_int(statement, 5, tieneBocina ? 1 : 0)
        sqlite3_bind_int(statement, 6, tieneProyector ? 1 : 0)
        sqlite3_bind_int(statement, 7, activa ? 1 : 0)

        let resultado = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)

        return resultado
    }

    // MARK: - Insertar sala
    func insertarSala(
        nombre: String,
        descripcion: String,
        capacidad: Int,
        tieneMicrofono: Bool,
        tieneBocina: Bool,
        tieneProyector: Bool,
        activa: Bool
    ) -> Bool {
        let sql = """
            INSERT INTO salas (
                nombre,
                descripcion,
                capacidad,
                tiene_microfono,
                tiene_bocina,
                tiene_proyector,
                activa
            )
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando insertarSala: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (descripcion as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(capacidad))
        sqlite3_bind_int(statement, 4, tieneMicrofono ? 1 : 0)
        sqlite3_bind_int(statement, 5, tieneBocina ? 1 : 0)
        sqlite3_bind_int(statement, 6, tieneProyector ? 1 : 0)
        sqlite3_bind_int(statement, 7, activa ? 1 : 0)

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error insertando sala: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return resultado
    }

    // MARK: - Obtener salas activas
    func obtenerSalasActivas() -> [Sala] {
        return obtenerSalas(incluirInactivas: false)
    }

    // MARK: - Obtener salas
    func obtenerSalas(incluirInactivas: Bool = true) -> [Sala] {
        let filtro = incluirInactivas ? "" : "WHERE activa = 1"

        let sql = """
            SELECT
                id,
                nombre,
                descripcion,
                capacidad,
                tiene_microfono,
                tiene_bocina,
                tiene_proyector,
                activa
            FROM salas
            \(filtro)
            ORDER BY nombre ASC;
        """

        var statement: OpaquePointer?
        var salas: [Sala] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando obtenerSalas: \(String(cString: sqlite3_errmsg(db)))")
            return []
        }

        while sqlite3_step(statement) == SQLITE_ROW {
            let sala = Sala(
                id: Int(sqlite3_column_int(statement, 0)),
                nombre: textoColumna(statement, 1),
                descripcion: textoColumna(statement, 2),
                capacidad: Int(sqlite3_column_int(statement, 3)),
                tieneMicrofono: sqlite3_column_int(statement, 4) == 1,
                tieneBocina: sqlite3_column_int(statement, 5) == 1,
                tieneProyector: sqlite3_column_int(statement, 6) == 1,
                activa: sqlite3_column_int(statement, 7) == 1
            )

            salas.append(sala)
        }

        sqlite3_finalize(statement)
        return salas
    }

    // MARK: - Actualizar sala
    func actualizarSala(
        id: Int,
        nombre: String,
        descripcion: String,
        capacidad: Int,
        tieneMicrofono: Bool,
        tieneBocina: Bool,
        tieneProyector: Bool,
        activa: Bool
    ) -> Bool {
        let sql = """
            UPDATE salas
            SET nombre = ?,
                descripcion = ?,
                capacidad = ?,
                tiene_microfono = ?,
                tiene_bocina = ?,
                tiene_proyector = ?,
                activa = ?
            WHERE id = ?;
        """

        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando actualizarSala: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_text(statement, 1, (nombre as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (descripcion as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(capacidad))
        sqlite3_bind_int(statement, 4, tieneMicrofono ? 1 : 0)
        sqlite3_bind_int(statement, 5, tieneBocina ? 1 : 0)
        sqlite3_bind_int(statement, 6, tieneProyector ? 1 : 0)
        sqlite3_bind_int(statement, 7, activa ? 1 : 0)
        sqlite3_bind_int(statement, 8, Int32(id))

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error actualizando sala: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return resultado
    }

    // MARK: - Eliminar sala
    func eliminarSala(id: Int) -> Bool {
        let sql = "UPDATE salas SET activa = 0 WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando eliminarSala: \(String(cString: sqlite3_errmsg(db)))")
            return false
        }

        sqlite3_bind_int(statement, 1, Int32(id))

        let resultado = sqlite3_step(statement) == SQLITE_DONE

        if !resultado {
            print("❌ Error eliminando sala: \(String(cString: sqlite3_errmsg(db)))")
        }

        sqlite3_finalize(statement)
        return resultado
    }

    func reactivarSala(id: Int) -> Bool {
        let sql = "UPDATE salas SET activa = 1 WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            return false
        }

        sqlite3_bind_int(statement, 1, Int32(id))

        let resultado = sqlite3_step(statement) == SQLITE_DONE
        sqlite3_finalize(statement)
        return resultado
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
        if existeSolicitudActiva(
            sala: sala,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin
        ) {
            print("⚠️ Ya existe una solicitud activa en ese horario.")
            return false
        }

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
            let solicitud = Solicitud(
                id: Int(sqlite3_column_int(statement, 0)),
                usuarioId: Int(sqlite3_column_int(statement, 1)),
                usuario: textoColumna(statement, 2),
                correo: textoColumna(statement, 3),
                sala: textoColumna(statement, 4),
                fecha: textoColumna(statement, 5),
                horaInicio: textoColumna(statement, 6),
                horaFin: textoColumna(statement, 7),
                motivo: textoColumna(statement, 8),
                necesitaMicrofono: sqlite3_column_int(statement, 9) == 1,
                necesitaBocina: sqlite3_column_int(statement, 10) == 1,
                necesitaProyector: sqlite3_column_int(statement, 11) == 1,
                estado: EstadoSolicitud(rawValue: textoColumna(statement, 12)) ?? .pendiente
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
    
    // MARK: - Registrar solicitud aprobada automáticamente
    func registrarSolicitudAutoAprobada(
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
        necesitaProyector: Bool
    ) -> Bool {
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
            print("❌ Error preparando registrarSolicitudAutoAprobada: \(String(cString: sqlite3_errmsg(db)))")
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
        sqlite3_bind_text(statement, 12, (EstadoSolicitud.aprobada.rawValue as NSString).utf8String, -1, nil)

        let seGuardoSolicitud = sqlite3_step(statement) == SQLITE_DONE

        if !seGuardoSolicitud {
            print("❌ Error insertando solicitud autoaprobada: \(String(cString: sqlite3_errmsg(db)))")
            sqlite3_finalize(statement)
            return false
        }

        let solicitudId = Int(sqlite3_last_insert_rowid(db))
        sqlite3_finalize(statement)

        let seGuardoReservacion = insertarReservacion(
            usuarioId: usuarioId,
            nombreUsuario: usuario,
            sala: sala,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin,
            tipo: .confirmada,
            exceptoSolicitudId: solicitudId
        )

        if !seGuardoReservacion {
            actualizarEstadoSolicitud(id: solicitudId, nuevoEstado: .rechazada)
            return false
        }

        return true
    }

    // MARK: - Obtener solicitudes por usuario
    func obtenerSolicitudesPorUsuario(usuarioId: Int) -> [Solicitud] {
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
            WHERE usuario_id = ?
            ORDER BY id DESC;
        """

        var statement: OpaquePointer?
        var solicitudes: [Solicitud] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else {
            print("❌ Error preparando obtenerSolicitudesPorUsuario: \(String(cString: sqlite3_errmsg(db)))")
            return []
        }

        sqlite3_bind_int(statement, 1, Int32(usuarioId))

        while sqlite3_step(statement) == SQLITE_ROW {
            let solicitud = Solicitud(
                id: Int(sqlite3_column_int(statement, 0)),
                usuarioId: Int(sqlite3_column_int(statement, 1)),
                usuario: textoColumna(statement, 2),
                correo: textoColumna(statement, 3),
                sala: textoColumna(statement, 4),
                fecha: textoColumna(statement, 5),
                horaInicio: textoColumna(statement, 6),
                horaFin: textoColumna(statement, 7),
                motivo: textoColumna(statement, 8),
                necesitaMicrofono: sqlite3_column_int(statement, 9) == 1,
                necesitaBocina: sqlite3_column_int(statement, 10) == 1,
                necesitaProyector: sqlite3_column_int(statement, 11) == 1,
                estado: EstadoSolicitud(rawValue: textoColumna(statement, 12)) ?? .pendiente
            )

            solicitudes.append(solicitud)
        }

        sqlite3_finalize(statement)
        return solicitudes
    }
    
}
