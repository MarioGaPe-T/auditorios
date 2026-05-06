//
//  SolicitudesView.swift
//  45,43 - app final
//
//  Created by Alumno on 21/04/26.
//

import SwiftUI

struct Solicitud: Identifiable {
    let id = UUID()
    let usuario: String
    let sala: String
    let fecha: String
    let hora: String
    let estado: EstadoSolicitud
}

enum EstadoSolicitud {
    case pendiente
    case aprobada
    case rechazada
}

struct SolicitudesView: View {
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    @State private var solicitudes: [Solicitud] = [
        Solicitud(usuario: "Juan Pérez", sala: "Sala Audiovisual A", fecha: "21 Abril 2026", hora: "08:00 - 09:00", estado: .pendiente),
        Solicitud(usuario: "María López", sala: "Sala Audiovisual B", fecha: "22 Abril 2026", hora: "10:00 - 11:00", estado: .pendiente),
        Solicitud(usuario: "Carlos Ruiz", sala: "Sala Audiovisual E", fecha: "20 Abril 2026", hora: "12:00 - 13:00", estado: .aprobada)
    ] 

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

                        ForEach(solicitudes.indices, id: \.self) { index in
                            tarjetaSolicitud(index: index)
                        }

                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 24)
                }
            }
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

            Text("\(solicitud.fecha) • \(solicitud.hora)")
                .font(.system(size: 14))
                .foregroundColor(.gray)

            estadoView(solicitud.estado)

            if solicitud.estado == .pendiente {
                HStack(spacing: 12) {

                    Button(action: {
                        solicitudes[index] = Solicitud(
                            usuario: solicitud.usuario,
                            sala: solicitud.sala,
                            fecha: solicitud.fecha,
                            hora: solicitud.hora,
                            estado: .aprobada
                        )
                    }) {
                        Text("Aprobar")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(red: 0.05, green: 0.75, blue: 0.38))
                            .cornerRadius(12)
                    }

                    Button(action: {
                        solicitudes[index] = Solicitud(
                            usuario: solicitud.usuario,
                            sala: solicitud.sala,
                            fecha: solicitud.fecha,
                            hora: solicitud.hora,
                            estado: .rechazada
                        )
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
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
