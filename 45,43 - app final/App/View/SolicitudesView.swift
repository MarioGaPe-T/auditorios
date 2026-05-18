//
//  SolicitudesView.swift
//  45,43 - app final
//

import SwiftUI

struct SolicitudesView: View {
    let usuario: Usuario
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    @State private var solicitudes: [Solicitud] = []
    @State private var mensajeAccion = ""
    @State private var mostrarMensaje = false

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                barraSuperior

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("Solicitudes de Reservación")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                            .padding(.top, 10)

                        if mostrarMensaje {
                            mensajeView
                        }

                        if solicitudes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.5))

                                Text("Sin solicitudes registradas")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(solicitudes.indices, id: \.self) { index in
                                tarjetaSolicitud(index: index)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            cargarSolicitudes()
        }
    }

    // MARK: - Cargar solicitudes

    private func cargarSolicitudes() {
        solicitudes = DatabaseManager.shared.obtenerSolicitudes()
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

                Text("Solicitudes")
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

    // MARK: - Tarjeta

    private func tarjetaSolicitud(index: Int) -> some View {
        let solicitud = solicitudes[index]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(solicitud.usuario)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    Text(solicitud.correo)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                estadoView(solicitud.estado)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                filaInfo(icono: "building.2.fill", titulo: "Sala", valor: solicitud.sala)

                filaInfo(
                    icono: "calendar",
                    titulo: "Fecha",
                    valor: solicitud.fecha
                )

                filaInfo(
                    icono: "clock.fill",
                    titulo: "Horario",
                    valor: "\(solicitud.horaInicio) - \(solicitud.horaFin)"
                )

                filaInfo(
                    icono: "text.alignleft",
                    titulo: "Motivo",
                    valor: solicitud.motivo
                )
            }

            equiposSolicitados(solicitud)

            if puedeGestionarSolicitud(solicitud) {
                botonesGestion(solicitud)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func filaInfo(icono: String, titulo: String, valor: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icono)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)

                Text(valor.isEmpty ? "Sin información" : valor)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
        }
    }

    private func equiposSolicitados(_ solicitud: Solicitud) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Equipo requerido")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                etiquetaEquipo(
                    texto: "Micrófono",
                    activo: solicitud.necesitaMicrofono
                )

                etiquetaEquipo(
                    texto: "Bocina",
                    activo: solicitud.necesitaBocina
                )

                etiquetaEquipo(
                    texto: "Proyector",
                    activo: solicitud.necesitaProyector
                )
            }
        }
    }

    private func etiquetaEquipo(texto: String, activo: Bool) -> some View {
        Text(texto)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(activo ? .white : .gray)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                activo
                ? Color(red: 0.10, green: 0.45, blue: 0.67)
                : Color.gray.opacity(0.15)
            )
            .cornerRadius(12)
    }

    // MARK: - Botones de gestión

    private func puedeGestionarSolicitud(_ solicitud: Solicitud) -> Bool {
        return solicitud.estado == .pendiente || solicitud.estado == .porConfirmar
    }

    private func botonesGestion(_ solicitud: Solicitud) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                aprobar(solicitud)
            }) {
                Text("Aprobar")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(red: 0.05, green: 0.75, blue: 0.38))
                    .cornerRadius(12)
            }

            Button(action: {
                rechazar(solicitud)
            }) {
                Text("Rechazar")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(red: 1.00, green: 0.34, blue: 0.34))
                    .cornerRadius(12)
            }
        }
        .padding(.top, 6)
    }

    private func aprobar(_ solicitud: Solicitud) {
        let exito = DatabaseManager.shared.aprobarSolicitud(solicitud)

        if exito {
            mensajeAccion = "✅ Solicitud aprobada. El horario quedó confirmado."
        } else {
            mensajeAccion = "❌ No se pudo aprobar. El horario ya fue ocupado o hubo un error."
        }

        mostrarMensajeTemporal()
        cargarSolicitudes()
    }

    private func rechazar(_ solicitud: Solicitud) {
        DatabaseManager.shared.rechazarSolicitud(id: solicitud.id)

        mensajeAccion = "✅ Solicitud rechazada. El horario quedó liberado."
        mostrarMensajeTemporal()
        cargarSolicitudes()
    }

    // MARK: - Estado

    private func estadoView(_ estado: EstadoSolicitud) -> some View {
        let texto: String
        let color: Color

        switch estado {
        case .pendiente:
            texto = "Pendiente"
            color = Color.orange

        case .porConfirmar:
            texto = "Por confirmar"
            color = Color.orange

        case .aprobada:
            texto = "Aprobada"
            color = Color(red: 0.05, green: 0.75, blue: 0.38)

        case .rechazada:
            texto = "Rechazada"
            color = Color(red: 1.00, green: 0.34, blue: 0.34)
        }

        return Text(texto)
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(color)
            .cornerRadius(12)
    }

    // MARK: - Mensaje

    private var mensajeView: some View {
        HStack {
            Image(systemName: mensajeAccion.contains("❌") ? "xmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(mensajeAccion.contains("❌") ? .red : .green)

            Text(mensajeAccion)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(mensajeAccion.contains("❌") ? .red : .green)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            mensajeAccion.contains("❌")
            ? Color.red.opacity(0.10)
            : Color.green.opacity(0.10)
        )
        .cornerRadius(12)
    }

    private func mostrarMensajeTemporal() {
        mostrarMensaje = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mostrarMensaje = false
        }
    }
}

#Preview {
    SolicitudesView(
        usuario: Usuario(
            id: 1,
            nombre: "Admin",
            correo: "admin@tuxtla.tecnm.mx",
            rol: .administrador
        ),
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
