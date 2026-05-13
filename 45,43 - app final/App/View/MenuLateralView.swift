//
//  MenuLateralView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct MenuLateralView: View {
    let usuario: Usuario?
    let accionInicio: () -> Void
    let accionUsuarios: () -> Void
    let accionRoles: () -> Void
    let accionReservaciones: () -> Void
    let accionSolicitudes: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.09, green: 0.12, blue: 0.25)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 46) {
                Spacer().frame(height: 28)

                // Info del usuario
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

                // Solo administrador ve Usuarios y Roles
                if usuario?.rol == .administrador {
                    itemMenu(
                        icono: "person.2.fill",
                        titulo: "Usuarios",
                        accion: accionUsuarios
                    )

                    itemMenu(
                        icono: "person.crop.circle.badge.plus",
                        titulo: "Roles",
                        accion: accionRoles
                    )
                }

                itemMenu(
                    icono: "calendar.badge.checkmark",
                    titulo: "Reservaciones",
                    accion: accionReservaciones
                )

                // Solo administrador ve Solicitudes
                if usuario?.rol == .administrador {
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
                    .font(.system(size: 42))
                    .foregroundColor(.white)

                Text(titulo)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    MenuLateralView(
        usuario: Usuario(id: 1, nombre: "Admin", correo: "admin@test.com", rol: .administrador),
        accionInicio: {},
        accionUsuarios: {},
        accionRoles: {},
        accionReservaciones: {},
        accionSolicitudes: {}
    )
}
