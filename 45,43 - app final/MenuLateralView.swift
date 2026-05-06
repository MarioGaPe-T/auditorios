//
//  MenuLateralView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct MenuLateralView: View {
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

                itemMenu(
                    icono: "house.fill",
                    titulo: "Inicio",
                    accion: accionInicio
                )

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

                itemMenu(
                    icono: "calendar.badge.checkmark",
                    titulo: "Reservaciones",
                    accion: accionReservaciones
                )
                    
                itemMenu(
                    icono: "tray.full.fill",
                    titulo: "Solicitudes",
                    accion: accionSolicitudes
                )

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
        accionInicio: {},
        accionUsuarios: {},
        accionRoles: {},
        accionReservaciones: {},
        accionSolicitudes: {}
    )
}
