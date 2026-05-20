//
//  MenuLateralView.swift
//  45,43 - app final
//

import SwiftUI

struct MenuLateralView: View {
    let usuario: Usuario?
    let accionInicio: () -> Void
    let accionUsuarios: () -> Void
    let accionSalas: () -> Void
    let accionReservaciones: () -> Void
    let accionEstadoSolicitudes: () -> Void
    let accionSolicitudes: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.12, blue: 0.25)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 42) {
                Spacer().frame(height: 28)

                if let usuario = usuario {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(usuario.nombre)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text(usuario.rol.descripcion)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.65))
                    }
                    .padding(.bottom, 8)
                }

                itemMenu(
                    icono: "house.fill",
                    titulo: "Inicio",
                    accion: accionInicio
                )

                itemMenu(
                    icono: "calendar.badge.checkmark",
                    titulo: "Reservaciones",
                    accion: accionReservaciones
                )

                itemMenu(
                    icono: "doc.text.magnifyingglass",
                    titulo: "Estado solicitud",
                    accion: accionEstadoSolicitudes
                )

                if usuario?.rol == .administrador {
                    itemMenu(
                        icono: "person.2.fill",
                        titulo: "Usuarios",
                        accion: accionUsuarios
                    )

                    itemMenu(
                        icono: "building.2.fill",
                        titulo: "Salas",
                        accion: accionSalas
                    )

                    itemMenu(
                        icono: "tray.full.fill",
                        titulo: "Solicitudes",
                        accion: accionSolicitudes
                    )
                }

                Spacer()

                HStack {
                    Spacer()

                    Image("logo_tecnologico")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .opacity(0.95)

                    Spacer()
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 26)
        }
    }

    private func itemMenu(icono: String, titulo: String, accion: @escaping () -> Void) -> some View {
        Button(action: accion) {
            HStack(spacing: 22) {
                Image(systemName: icono)
                    .font(.system(size: 38))
                    .foregroundColor(.white)

                Text(titulo)
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    MenuLateralView(
        usuario: Usuario(
            id: 1,
            nombre: "Admin",
            correo: "admin@test.com",
            rol: .administrador
        ),
        accionInicio: {},
        accionUsuarios: {},
        accionSalas: {},
        accionReservaciones: {},
        accionEstadoSolicitudes: {},
        accionSolicitudes: {}
    )
}
