//
//  ReservacionView.swift
//  45,43 - app final
//

//
//  ReservacionView.swift
//  45,43 - app final
//

import SwiftUI

struct ReservacionView: View {
    let usuario: Usuario
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    @State private var fechaSeleccionada = Date()
    @State private var mostrarCalendario = false

    @State private var seleccionados: Set<UUID> = []
    @State private var bloques: [BloqueHorario] = []

    @State private var mostrarConfirmacion = false
    @State private var mensajeConfirmacion = ""

    @State private var mostrarFormularioSolicitud = false
    @State private var bloquesParaSolicitud: [BloqueHorario] = []

    private let salaActual = "Sala Audiovisual E"
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

                        selectorSemana

                        encabezadoDiasSemana

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
            bloques = crearBloquesDeSemana(fechaBase: fechaSeleccionada)
            cargarEstadosDesdeBaseDeDatos()
        }
        .sheet(isPresented: $mostrarCalendario) {
            NavigationView {
                VStack(spacing: 18) {
                    DatePicker(
                        "Selecciona una fecha",
                        selection: $fechaSeleccionada,
                        in: Calendar.current.startOfDay(for: Date())...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding()

                    Button(action: {
                        bloques = crearBloquesDeSemana(fechaBase: fechaSeleccionada)
                        seleccionados.removeAll()
                        cargarEstadosDesdeBaseDeDatos()
                        mostrarCalendario = false
                    }) {
                        Text("Aceptar")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                }
                .navigationTitle("Calendario")
            }
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

    // MARK: - Selector de semana

    private var selectorSemana: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mesActualTexto())
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))

                Text(rangoSemanaTexto())
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                mostrarCalendario = true
            }) {
                Text("Elegir fecha")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 130, height: 52)
                    .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                    .cornerRadius(25)
            }
        }
    }

    private var encabezadoDiasSemana: some View {
        LazyVGrid(columns: columnas, spacing: 10) {
            ForEach(encabezadosSemana, id: \.self) { dia in
                Text(dia)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color.gray)
            }
        }
    }

    private var encabezadosSemana: [String] {
        let calendario = Calendar.current
        let lunes = obtenerLunesDeSemana(fechaSeleccionada)

        return (0..<5).compactMap { dia in
            guard let fechaDia = calendario.date(byAdding: .day, value: dia, to: lunes) else {
                return nil
            }

            return etiquetaEncabezado(fechaDia)
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
        .frame(height: 120)
        .background(colorBloque(bloque: bloque, seleccionado: estaSeleccionado))
        .cornerRadius(8)
        .opacity(puedeSeleccionar(bloque) ? 1.0 : 0.60)
        .onTapGesture {
            seleccionarBloque(bloque)
        }
    }

    private func seleccionarBloque(_ bloque: BloqueHorario) {
        guard puedeSeleccionar(bloque) else {
            return
        }

        // Evita mezclar horarios de diferentes días en una sola solicitud/reservación.
        if let primerId = seleccionados.first,
           let primerBloque = bloques.first(where: { $0.id == primerId }),
           primerBloque.fecha != bloque.fecha {
            seleccionados.removeAll()
        }

        if seleccionados.contains(bloque.id) {
            seleccionados.remove(bloque.id)
        } else {
            seleccionados.insert(bloque.id)
        }
    }

    private func puedeSeleccionar(_ bloque: BloqueHorario) -> Bool {
        if esFechaISOAnteriorAHoy(bloque.fecha) {
            return false
        }

        if usuario.rol == .directivo {
            return bloque.estado == .disponible || bloque.estado == .porConfirmar
        }

        return bloque.estado == .disponible
    }

    private func colorBloque(bloque: BloqueHorario, seleccionado: Bool) -> Color {
        if seleccionado {
            return Color(red: 0.10, green: 0.45, blue: 0.67)
        }

        if esFechaISOAnteriorAHoy(bloque.fecha) {
            return Color(red: 1.00, green: 0.34, blue: 0.34)
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

        let bloquesSeleccionados = bloquesSeleccionadosOrdenados()

        if usuario.rol == .jefatura {
            bloquesParaSolicitud = bloquesSeleccionados
            mostrarFormularioSolicitud = true
            return
        }

        reservarDirectamente(bloquesSeleccionados)
    }

    private func reservarDirectamente(_ bloquesSeleccionados: [BloqueHorario]) {
        guard let primerBloque = bloquesSeleccionados.first,
              let ultimoBloque = bloquesSeleccionados.last else {
            return
        }

        let exito = DatabaseManager.shared.insertarReservacion(
            usuarioId: usuario.id,
            nombreUsuario: usuario.nombre,
            sala: salaActual,
            fecha: primerBloque.fecha,
            horaInicio: primerBloque.horaInicio,
            horaFin: ultimoBloque.horaFin,
            tipo: .confirmada
        )

        mostrarConfirmacion = true

        if exito {
            mensajeConfirmacion = usuario.rol == .directivo
            ? "✅ Reservación confirmada automáticamente."
            : "✅ Reservación confirmada."

            seleccionados.removeAll()
            cargarEstadosDesdeBaseDeDatos()
        } else {
            mensajeConfirmacion = "❌ Error al guardar la reservación."
        }

        ocultarMensajeDespues()
    }

    private func enviarSolicitudJefatura(
        motivo: String,
        necesitaMicrofono: Bool,
        necesitaBocina: Bool,
        necesitaProyector: Bool
    ) {
        let bloquesOrdenados = bloquesParaSolicitud.sorted {
            if $0.fecha == $1.fecha {
                return $0.horaInicio < $1.horaInicio
            }
            return $0.fecha < $1.fecha
        }

        guard let primerBloque = bloquesOrdenados.first,
              let ultimoBloque = bloquesOrdenados.last else {
            mensajeConfirmacion = "Selecciona al menos un horario."
            mostrarConfirmacion = true
            return
        }

        let exito = DatabaseManager.shared.insertarSolicitud(
            usuarioId: usuario.id,
            usuario: usuario.nombre,
            correo: usuario.correo,
            sala: salaActual,
            fecha: primerBloque.fecha,
            horaInicio: primerBloque.horaInicio,
            horaFin: ultimoBloque.horaFin,
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
            seleccionados.removeAll()
            bloquesParaSolicitud.removeAll()
            cargarEstadosDesdeBaseDeDatos()
        } else {
            mensajeConfirmacion = "❌ Error al enviar la solicitud."
        }

        ocultarMensajeDespues()
    }

    private func bloquesSeleccionadosOrdenados() -> [BloqueHorario] {
        return bloques
            .filter { seleccionados.contains($0.id) }
            .sorted {
                if $0.fecha == $1.fecha {
                    return $0.horaInicio < $1.horaInicio
                }

                return $0.fecha < $1.fecha
            }
    }

    private func limpiarSeleccion() {
        seleccionados.removeAll()
        mostrarConfirmacion = false
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

    // MARK: - Crear horarios

    private func crearBloquesDeSemana(fechaBase: Date) -> [BloqueHorario] {
        let calendario = Calendar.current
        let lunes = obtenerLunesDeSemana(fechaBase)

        let horarios: [(String, String)] = [
            ("07:00", "08:00"),
            ("08:00", "09:00"),
            ("09:00", "10:00"),
            ("10:00", "11:00"),
            ("11:00", "12:00"),
            ("12:00", "13:00"),
            ("13:00", "14:00")
        ]

        var nuevosBloques: [BloqueHorario] = []

        for horario in horarios {
            for dia in 0..<5 {
                guard let fechaDia = calendario.date(byAdding: .day, value: dia, to: lunes) else {
                    continue
                }

                let fechaISO = formatearFechaISO(fechaDia)

                let estadoInicial: EstadoBloqueHorario = esFechaAnterior(fechaDia)
                ? .ocupado
                : .disponible

                nuevosBloques.append(
                    BloqueHorario(
                        etiquetaDia: nil,
                        fecha: fechaISO,
                        horaInicio: horario.0,
                        horaFin: horario.1,
                        estado: estadoInicial
                    )
                )
            }
        }

        return nuevosBloques
    }

    private func cargarEstadosDesdeBaseDeDatos() {
        for index in bloques.indices {
            let bloque = bloques[index]

            if esFechaISOAnteriorAHoy(bloque.fecha) {
                bloques[index].estado = .ocupado
            } else {
                bloques[index].estado = DatabaseManager.shared.estadoHorario(
                    sala: salaActual,
                    fecha: bloque.fecha,
                    horaInicio: bloque.horaInicio,
                    horaFin: bloque.horaFin
                )
            }
        }
    }

    // MARK: - Fechas

    private func obtenerLunesDeSemana(_ fecha: Date) -> Date {
        var calendario = Calendar.current
        calendario.firstWeekday = 2

        let componentes = calendario.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: fecha
        )

        return calendario.date(from: componentes) ?? fecha
    }

    private func formatearFechaISO(_ fecha: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: fecha)
    }

    private func fechaDesdeISO(_ texto: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: texto)
    }

    private func etiquetaEncabezado(_ fecha: Date) -> String {
        let formatterDia = DateFormatter()
        formatterDia.locale = Locale(identifier: "es_MX")
        formatterDia.dateFormat = "EEEE"

        let formatterFecha = DateFormatter()
        formatterFecha.dateFormat = "dd/MM"

        let dia = formatterDia.string(from: fecha).uppercased()
        let fechaTexto = formatterFecha.string(from: fecha)

        return "\(dia)\n\(fechaTexto)"
    }

    private func esFechaAnterior(_ fecha: Date) -> Bool {
        let calendario = Calendar.current
        let hoy = calendario.startOfDay(for: Date())
        let fechaComparar = calendario.startOfDay(for: fecha)

        return fechaComparar < hoy
    }

    private func esFechaISOAnteriorAHoy(_ fechaISO: String) -> Bool {
        guard let fecha = fechaDesdeISO(fechaISO) else {
            return false
        }

        return esFechaAnterior(fecha)
    }

    private func mesActualTexto() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return formatter.string(from: fechaSeleccionada).capitalized
    }

    private func rangoSemanaTexto() -> String {
        let calendario = Calendar.current
        let lunes = obtenerLunesDeSemana(fechaSeleccionada)

        guard let viernes = calendario.date(byAdding: .day, value: 4, to: lunes) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.dateFormat = "dd/MM/yyyy"

        return "\(formatter.string(from: lunes)) - \(formatter.string(from: viernes))"
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
