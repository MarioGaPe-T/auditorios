//
//  ReservacionView.swift
//  45,43 - app final
//

import SwiftUI

struct ReservacionView: View {
    let usuario: Usuario
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    @State private var seleccionados: Set<UUID> = []
    @State private var bloques: [BloqueHorario] = []

    @State private var mostrarConfirmacion = false
    @State private var mensajeConfirmacion = ""

    @State private var mostrarFormularioSolicitud = false
    @State private var bloquesParaSolicitud: [BloqueHorario] = []

    private let salaActual = "Sala Audiovisual E"
    private let dias = ["LUNES", "MARTES", "MIÉRCOLES", "JUEVES", "VIERNES"]
    private let columnas = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                barraSuperior

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text(salaActual)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                            .padding(.top, 10)

                        etiquetaRol

                        leyendaEstados

                        HStack {
                            Text(mesActualTexto())
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.gray)

                            Spacer()

                            Button(action: {
                                cargarEstadosDesdeBaseDeDatos()
                            }) {
                                Text("Actualizar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(width: 120, height: 52)
                                    .background(Color(red: 0.84, green: 0.84, blue: 0.84))
                                    .cornerRadius(25)
                            }
                        }

                        LazyVGrid(columns: columnas, spacing: 10) {
                            ForEach(dias, id: \.self) { dia in
                                Text(dia)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color.gray)
                            }
                        }

                        LazyVGrid(columns: columnas, spacing: 12) {
                            ForEach(bloques.indices, id: \.self) { index in
                                tarjetaHorario(index: index)
                            }
                        }

                        if mostrarConfirmacion {
                            mensajeView
                        }

                        botonesAccion
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            if bloques.isEmpty {
                bloques = crearBloquesIniciales()
            }

            cargarEstadosDesdeBaseDeDatos()
        }
        .sheet(isPresented: $mostrarFormularioSolicitud) {
            FormularioSolicitudView(
                usuario: usuario,
                sala: salaActual,
                bloquesSeleccionados: bloquesParaSolicitud,
                accionCancelar: {
                    mostrarFormularioSolicitud = false
                },
                accionEnviar: { motivo, microfono, bocina, proyector in
                    enviarSolicitudJefatura(
                        motivo: motivo,
                        necesitaMicrofono: microfono,
                        necesitaBocina: bocina,
                        necesitaProyector: proyector
                    )
                }
            )
        }
    }

    // MARK: - Barra superior

    private var barraSuperior: some View {
        ZStack {
            Color(red: 0.10, green: 0.45, blue: 0.67)
                .ignoresSafeArea(edges: .top)

            HStack {
                Button(action: accionAbrirMenu) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Reservación")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: accionCerrarSesion) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .frame(height: 110)
    }

    // MARK: - Rol

    private var etiquetaRol: some View {
        HStack {
            Image(systemName: iconoRol)
                .foregroundColor(.white)

            Text("Sesión: \(usuario.nombre) — \(usuario.rol.descripcion)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(colorRol)
        .cornerRadius(20)
    }

    private var iconoRol: String {
        if usuario.rol == .administrador {
            return "shield.fill"
        } else if usuario.rol == .directivo {
            return "star.fill"
        } else {
            return "person.fill"
        }
    }

    private var colorRol: Color {
        if usuario.rol == .administrador {
            return Color(red: 0.10, green: 0.45, blue: 0.67)
        } else if usuario.rol == .directivo {
            return Color(red: 0.55, green: 0.20, blue: 0.70)
        } else {
            return Color(red: 0.05, green: 0.55, blue: 0.35)
        }
    }

    // MARK: - Leyenda

    private var leyendaEstados: some View {
        HStack(spacing: 10) {
            itemLeyenda(texto: "Disponible", color: Color(red: 0.05, green: 0.75, blue: 0.38))
            itemLeyenda(texto: "Apartado", color: .orange)
            itemLeyenda(texto: "Ocupado", color: Color(red: 1.00, green: 0.34, blue: 0.34))
        }
    }

    private func itemLeyenda(texto: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(texto)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.gray)
        }
    }

    // MARK: - Tarjeta de horario

    private func tarjetaHorario(index: Int) -> some View {
        let bloque = bloques[index]
        let estaSeleccionado = seleccionados.contains(bloque.id)

        return VStack(spacing: 6) {
            if let etiqueta = bloque.etiquetaDia {
                Text(etiqueta)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }

            Text(bloque.horaInicio)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            Text("–")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Text(bloque.horaFin)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            Text(textoEstado(bloque.estado))
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.90))

            if estaSeleccionado {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128)
        .background(colorBloque(bloque: bloque, seleccionado: estaSeleccionado))
        .cornerRadius(8)
        .opacity(puedeSeleccionar(bloque) ? 1.0 : 0.75)
        .onTapGesture {
            seleccionarBloque(bloque)
        }
    }

    private func seleccionarBloque(_ bloque: BloqueHorario) {
        guard puedeSeleccionar(bloque) else {
            return
        }

        if seleccionados.contains(bloque.id) {
            seleccionados.remove(bloque.id)
        } else {
            seleccionados.insert(bloque.id)
        }
    }

    private func puedeSeleccionar(_ bloque: BloqueHorario) -> Bool {
        if usuario.rol == .directivo {
            return bloque.estado == .disponible || bloque.estado == .porConfirmar
        }

        return bloque.estado == .disponible
    }

    private func colorBloque(bloque: BloqueHorario, seleccionado: Bool) -> Color {
        if seleccionado {
            return Color(red: 0.10, green: 0.45, blue: 0.67)
        }

        if bloque.estado == .disponible {
            return Color(red: 0.05, green: 0.75, blue: 0.38)
        } else if bloque.estado == .porConfirmar {
            return Color.orange
        } else {
            return Color(red: 1.00, green: 0.34, blue: 0.34)
        }
    }

    private func textoEstado(_ estado: EstadoBloqueHorario) -> String {
        if estado == .disponible {
            return "Disponible"
        } else if estado == .porConfirmar {
            return "Apartado"
        } else {
            return "Ocupado"
        }
    }

    // MARK: - Botones

    private var botonesAccion: some View {
        VStack(spacing: 12) {
            HStack(spacing: 18) {
                Button(action: accionPrincipal) {
                    Text(etiquetaBotonPrincipal)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(colorBotonPrincipal)
                        .cornerRadius(28)
                }
                .disabled(seleccionados.isEmpty)
                .opacity(seleccionados.isEmpty ? 0.5 : 1.0)

                Button(action: limpiarSeleccion) {
                    Text("Limpiar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 1.00, green: 0.34, blue: 0.34))
                        .cornerRadius(28)
                }
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 24)
    }

    private var etiquetaBotonPrincipal: String {
        if usuario.rol == .administrador {
            return "Reservar"
        } else if usuario.rol == .directivo {
            return "Reservar directo"
        } else {
            return "Enviar solicitud"
        }
    }

    private var colorBotonPrincipal: Color {
        if usuario.rol == .administrador {
            return Color(red: 0.10, green: 0.45, blue: 0.67)
        } else if usuario.rol == .directivo {
            return Color(red: 0.55, green: 0.20, blue: 0.70)
        } else {
            return Color(red: 0.05, green: 0.75, blue: 0.38)
        }
    }

    // MARK: - Acciones principales

    private func accionPrincipal() {
        guard !seleccionados.isEmpty else {
            return
        }

        let bloquesSeleccionados = bloques.filter { seleccionados.contains($0.id) }

        if usuario.rol == .jefatura {
            bloquesParaSolicitud = bloquesSeleccionados
            mostrarFormularioSolicitud = true
            return
        }

        let resultado = ReservacionController.shared.procesarAccion(
            usuario: usuario,
            bloques: bloquesSeleccionados,
            sala: salaActual
        )

        mensajeConfirmacion = resultado
        mostrarConfirmacion = true

        if usuario.rol == .administrador || usuario.rol == .directivo {
            marcarBloquesSeleccionadosComo(.ocupado)
        }

        seleccionados.removeAll()

        ocultarMensajeDespues()
    }

    private func enviarSolicitudJefatura(
        motivo: String,
        necesitaMicrofono: Bool,
        necesitaBocina: Bool,
        necesitaProyector: Bool
    ) {
        guard !bloquesParaSolicitud.isEmpty else {
            mensajeConfirmacion = "Selecciona al menos un horario."
            mostrarConfirmacion = true
            return
        }

        let fecha = bloquesParaSolicitud.first?.fecha ?? fechaActualTexto()
        let horaInicio = bloquesParaSolicitud.first?.horaInicio ?? ""
        let horaFin = bloquesParaSolicitud.last?.horaFin ?? ""

        let exito = DatabaseManager.shared.insertarSolicitud(
            usuarioId: usuario.id,
            usuario: usuario.nombre,
            correo: usuario.correo,
            sala: salaActual,
            fecha: fecha,
            horaInicio: horaInicio,
            horaFin: horaFin,
            motivo: motivo,
            necesitaMicrofono: necesitaMicrofono,
            necesitaBocina: necesitaBocina,
            necesitaProyector: necesitaProyector,
            estado: .porConfirmar
        )

        mostrarFormularioSolicitud = false
        mostrarConfirmacion = true

        if exito {
            mensajeConfirmacion = "📋 Solicitud enviada. El horario quedó apartado."
            marcarBloquesSeleccionadosComo(.porConfirmar)
        } else {
            mensajeConfirmacion = "❌ Error al enviar la solicitud."
        }

        seleccionados.removeAll()
        bloquesParaSolicitud.removeAll()

        ocultarMensajeDespues()
    }

    private func limpiarSeleccion() {
        seleccionados.removeAll()
        mostrarConfirmacion = false
    }

    private func marcarBloquesSeleccionadosComo(_ estado: EstadoBloqueHorario) {
        for id in seleccionados {
            if let index = bloques.firstIndex(where: { $0.id == id }) {
                bloques[index].estado = estado
            }
        }
    }

    private func ocultarMensajeDespues() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mostrarConfirmacion = false
        }
    }

    // MARK: - Mensaje

    private var mensajeView: some View {
        HStack {
            Image(systemName: mensajeConfirmacion.contains("❌") ? "xmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(mensajeConfirmacion.contains("❌") ? .red : .green)

            Text(mensajeConfirmacion)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(mensajeConfirmacion.contains("❌") ? .red : .green)
        }
        .padding()
        .background(
            mensajeConfirmacion.contains("❌")
            ? Color.red.opacity(0.10)
            : Color.green.opacity(0.10)
        )
        .cornerRadius(12)
    }

    // MARK: - Cargar horarios

    private func crearBloquesIniciales() -> [BloqueHorario] {
        let fecha = fechaActualTexto()

        return [
            BloqueHorario(etiquetaDia: "DIA 2", fecha: fecha, horaInicio: "07:00", horaFin: "08:00", estado: .disponible),
            BloqueHorario(etiquetaDia: "DIA 3", fecha: fecha, horaInicio: "07:00", horaFin: "08:00", estado: .disponible),
            BloqueHorario(etiquetaDia: "DIA 4", fecha: fecha, horaInicio: "07:00", horaFin: "08:00", estado: .disponible),
            BloqueHorario(etiquetaDia: "DIA 5", fecha: fecha, horaInicio: "07:00", horaFin: "08:00", estado: .disponible),
            BloqueHorario(etiquetaDia: "DIA 6", fecha: fecha, horaInicio: "07:00", horaFin: "08:00", estado: .disponible),

            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "08:00", horaFin: "09:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "08:00", horaFin: "09:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "08:00", horaFin: "09:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "08:00", horaFin: "09:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "08:00", horaFin: "09:00", estado: .disponible),

            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "09:00", horaFin: "10:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "09:00", horaFin: "10:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "09:00", horaFin: "10:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "09:00", horaFin: "10:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "09:00", horaFin: "10:00", estado: .disponible),

            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "10:00", horaFin: "11:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "10:00", horaFin: "11:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "10:00", horaFin: "11:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "10:00", horaFin: "11:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "10:00", horaFin: "11:00", estado: .disponible),

            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "11:00", horaFin: "12:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "11:00", horaFin: "12:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "11:00", horaFin: "12:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "11:00", horaFin: "12:00", estado: .disponible),
            BloqueHorario(etiquetaDia: nil, fecha: fecha, horaInicio: "11:00", horaFin: "12:00", estado: .disponible)
        ]
    }

    private func cargarEstadosDesdeBaseDeDatos() {
        for index in bloques.indices {
            let bloque = bloques[index]

            bloques[index].estado = DatabaseManager.shared.estadoHorario(
                sala: salaActual,
                fecha: bloque.fecha,
                horaInicio: bloque.horaInicio,
                horaFin: bloque.horaFin
            )
        }
    }

    // MARK: - Fechas

    private func fechaActualTexto() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: Date())
    }

    private func mesActualTexto() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter.string(from: Date()).capitalized
    }
}

#Preview {
    ReservacionView(
        usuario: Usuario(
            id: 1,
            nombre: "Administrador",
            correo: "admin@tuxtla.tecnm.mx",
            rol: .administrador
        ),
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
