//
//  SolicitudesView.swift
//  45,43 - app final
//
//  Created by Alumno on 21/04/26.
//

import SwiftUI

struct SolicitudesView: View {
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

                        Text("Solicitudes de Reservación")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                            .padding(.top, 10)

                        if solicitudes.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("Sin solicitudes pendientes")
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

    // MARK: - Cargar solicitudes desde SQLite
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

        return VStack(alignment: .leading, spacing: 10) {

            Text(solicitud.usuario)
                .font(.system(size: 18, weight: .bold))

            Text(solicitud.sala)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)

            Text("\(solicitud.fecha) • \(solicitud.horaInicio) - \(solicitud.horaFin)")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            estadoView(solicitud.estado)

            if solicitud.estado == .pendiente {
                HStack(spacing: 12) {

                    Button(action: {
                        DatabaseManager.shared.actualizarEstadoSolicitud(
                            id: solicitud.id,
                            nuevoEstado: .aprobada
                        )
                        cargarSolicitudes()
                    }) {
                        Text("Aprobar")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(red: 0.05, green: 0.75, blue: 0.38))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        DatabaseManager.shared.actualizarEstadoSolicitud(
                            id: solicitud.id,
                            nuevoEstado: .rechazada
                        )
                        cargarSolicitudes()
                    }) {
                        Text("Rechazar")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(red: 1.00, green: 0.34, blue: 0.34))
                            .cornerRadius(12)
                    }
                }
            }

        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    
    // MARK: - Estado
    private func estadoView(_ estado: EstadoSolicitud) -> some View {
        let texto: String
        let color: Color
        

        switch estado {
        case .pendiente:
            texto = "Pendiente"
            color = Color.orange

        case .aprobada:
            texto = "Aprobada"
            color = Color(red: 0.05, green: 0.75, blue: 0.38)

        case .rechazada:
            texto = "Rechazada"
            color = Color(red: 1.00, green: 0.34, blue: 0.34)

        case .porConfirmar:
            texto = "Por confirmar"
            color = Color(red: 0.10, green: 0.45, blue: 0.67)
        }

        return Text(texto)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(10)
    }
}

#Preview {
    SolicitudesView(
        usuario: Usuario(id: 1, nombre: "Admin", correo: "admin@test.com", rol: .administrador),
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
