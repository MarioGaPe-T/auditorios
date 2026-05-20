//
//  EstadoSolicitudesView.swift
//  45,43 - app final
//

import SwiftUI

struct EstadoSolicitudesView: View {
    let usuario: Usuario
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    @State private var solicitudes: [Solicitud] = []

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                barraSuperior

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("Estado de solicitud")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                            .padding(.top, 10)

                        Text("Aquí puedes consultar el estado de las solicitudes que has enviado.")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        if solicitudes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.5))

                                Text("No has enviado solicitudes.")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(solicitudes) { solicitud in
                                tarjetaSolicitud(solicitud)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 28)
                }
            }
        }
        .onAppear {
            cargarSolicitudes()
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

                Text("Estado")
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

    private func tarjetaSolicitud(_ solicitud: Solicitud) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(solicitud.sala)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    Text("\(solicitud.fecha) • \(solicitud.horaInicio) - \(solicitud.horaFin)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                estadoView(solicitud.estado)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                filaInfo(icono: "person.fill", titulo: "Solicitante", valor: solicitud.usuario)
                filaInfo(icono: "text.alignleft", titulo: "Motivo", valor: solicitud.motivo)
            }

            equiposSolicitados(solicitud)
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
            Text("Equipo solicitado")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                etiquetaEquipo("Micrófono", solicitud.necesitaMicrofono)
                etiquetaEquipo("Bocina", solicitud.necesitaBocina)
                etiquetaEquipo("Proyector", solicitud.necesitaProyector)
            }
        }
    }

    private func etiquetaEquipo(_ texto: String, _ activo: Bool) -> some View {
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

    private func estadoView(_ estado: EstadoSolicitud) -> some View {
        let texto: String
        let color: Color

        switch estado {
        case .pendiente:
            texto = "Pendiente"
            color = .orange

        case .porConfirmar:
            texto = "Pendiente"
            color = .orange

        case .aprobada:
            texto = "Aprobada"
            color = Color(red: 0.05, green: 0.75, blue: 0.38)

        case .rechazada:
            texto = "Cancelada"
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

    private func cargarSolicitudes() {
        solicitudes = DatabaseManager.shared.obtenerSolicitudesPorUsuario(usuarioId: usuario.id)
    }
}

#Preview {
    EstadoSolicitudesView(
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
