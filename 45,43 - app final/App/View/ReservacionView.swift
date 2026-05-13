//
//  ReservacionView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI


struct ReservacionView: View {
    let usuario: Usuario
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    // Bloques seleccionados por el usuario
    @State private var seleccionados: Set<UUID> = []
    @State private var mostrarConfirmacion = false
    @State private var mensajeConfirmacion = ""

    private let dias = ["LUNES", "MARTES", "MIÉRCOLES", "JUEVES", "VIERNES"]

    @State private var bloques: [BloqueHorario] = [
        BloqueHorario(etiquetaDia: "DIA 2", horaInicio: "07:00", horaFin: "08:00", disponible: false),
        BloqueHorario(etiquetaDia: "DIA 3", horaInicio: "07:00", horaFin: "08:00", disponible: true),
        BloqueHorario(etiquetaDia: "DIA 4", horaInicio: "07:00", horaFin: "08:00", disponible: false),
        BloqueHorario(etiquetaDia: "DIA 5", horaInicio: "07:00", horaFin: "08:00", disponible: false),
        BloqueHorario(etiquetaDia: "DIA 6", horaInicio: "07:00", horaFin: "08:00", disponible: false),

        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true)
    ]

    private let columnas = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                barraSuperior

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text("Sala Audiovisual E")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                            .padding(.top, 10)

                        // Etiqueta de rol del usuario
                        etiquetaRol

                        HStack {
                            Text("Marzo de 2026")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.gray)

                            Spacer()

                            Button(action: {}) {
                                Text("Filtrar")
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

                        // Mensaje de confirmación
                        if mostrarConfirmacion {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(mensajeConfirmacion)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.10))
                            .cornerRadius(12)
                        }

                        botonesAccion

                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    // MARK: - Etiqueta de rol
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
        switch usuario.rol {
        case .administrador: return "shield.fill"
        case .directivo: return "star.fill"
        case .jefatura: return "person.fill"
        }
    }

    private var colorRol: Color {
        switch usuario.rol {
        case .administrador: return Color(red: 0.10, green: 0.45, blue: 0.67)
        case .directivo: return Color(red: 0.55, green: 0.20, blue: 0.70)
        case .jefatura: return Color(red: 0.05, green: 0.55, blue: 0.35)
        }
    }

    // MARK: - Botones según rol
    private var botonesAccion: some View {
        VStack(spacing: 12) {
            HStack(spacing: 18) {
                // Botón principal según rol
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
        switch usuario.rol {
        case .administrador: return "Reservar (Admin)"
        case .directivo: return "Reservar"
        case .jefatura: return "Enviar Solicitud"
        }
    }

    private var colorBotonPrincipal: Color {
        switch usuario.rol {
        case .administrador: return Color(red: 0.10, green: 0.45, blue: 0.67)
        case .directivo: return Color(red: 0.55, green: 0.20, blue: 0.70)
        case .jefatura: return Color(red: 0.05, green: 0.75, blue: 0.38)
        }
    }

    // MARK: - Acción según rol
    private func accionPrincipal() {
        guard !seleccionados.isEmpty else { return }

        let bloquesSeleccionados = bloques.filter { seleccionados.contains($0.id) }
        let resultado = ReservacionController.shared.procesarAccion(
            usuario: usuario,
            bloques: bloquesSeleccionados,
            sala: "Sala Audiovisual E"
        )

        mostrarConfirmacion = true
        mensajeConfirmacion = resultado

        // Marcar bloques como no disponibles si fue autoconfirmado
        if usuario.rol == .directivo || usuario.rol == .administrador {
            for id in seleccionados {
                if let index = bloques.firstIndex(where: { $0.id == id }) {
                    bloques[index] = BloqueHorario(
                        etiquetaDia: bloques[index].etiquetaDia,
                        horaInicio: bloques[index].horaInicio,
                        horaFin: bloques[index].horaFin,
                        disponible: false
                    )
                }
            }
        }

        seleccionados.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mostrarConfirmacion = false
        }
    }

    private func limpiarSeleccion() {
        seleccionados.removeAll()
        mostrarConfirmacion = false
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

    // MARK: - Tarjeta de horario con selección
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
        .onTapGesture {
            guard bloque.disponible else { return }
            if estaSeleccionado {
                seleccionados.remove(bloque.id)
            } else {
                seleccionados.insert(bloque.id)
            }
        }
    }

    private func colorBloque(bloque: BloqueHorario, seleccionado: Bool) -> Color {
        if !bloque.disponible {
            return Color(red: 1.00, green: 0.34, blue: 0.34)
        }
        if seleccionado {
            return Color(red: 0.10, green: 0.45, blue: 0.67)
        }
        return Color(red: 0.05, green: 0.75, blue: 0.38)
    }
}

#Preview {
    ReservacionView(
        usuario: Usuario(id: 1, nombre: "Admin", correo: "admin@test.com", rol: .administrador),
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
