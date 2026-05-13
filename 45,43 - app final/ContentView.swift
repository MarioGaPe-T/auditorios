//
//  ContentView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

enum PantallaActual {
    case login
    case olvideContrasena
    case reservacion
    case solicitudes
}

struct ContentView: View {
    @State private var pantallaActual: PantallaActual = .login
    @State private var mostrarMenu = false
    @State private var usuarioActual: Usuario? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            contenidoPrincipal

            if (pantallaActual == .reservacion || pantallaActual == .solicitudes) && mostrarMenu {
                Color.black.opacity(0.20)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            mostrarMenu = false
                        }
                    }

                menuDesplegable
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: mostrarMenu)
    }

    @ViewBuilder
    private var contenidoPrincipal: some View {
        switch pantallaActual {
        case .login:
            LoginView(
                accionOlvideContrasena: {
                    pantallaActual = .olvideContrasena
                },
                accionIngresar: { usuario in
                    usuarioActual = usuario
                    pantallaActual = .reservacion
                }
            )

        case .olvideContrasena:
            OlvideContrasenaView(
                accionEnviar: {
                    pantallaActual = .login
                },
                accionVolver: {
                    pantallaActual = .login
                }
            )

        case .reservacion:
            if let usuario = usuarioActual {
                ReservacionView(
                    usuario: usuario,
                    accionAbrirMenu: {
                        withAnimation { mostrarMenu = true }
                    },
                    accionCerrarSesion: {
                        cerrarSesion()
                    }
                )
            }

        case .solicitudes:
            if let usuario = usuarioActual {
                SolicitudesView(
                    usuario: usuario,
                    accionAbrirMenu: {
                        withAnimation { mostrarMenu = true }
                    },
                    accionCerrarSesion: {
                        cerrarSesion()
                    }
                )
            }
        }
    }

    private var menuDesplegable: some View {
        HStack(spacing: 0) {
            MenuLateralView(
                usuario: usuarioActual,
                accionInicio: {
                    withAnimation { mostrarMenu = false }
                    pantallaActual = .reservacion
                },
                accionUsuarios: {},
                accionRoles: {},
                accionReservaciones: {
                    withAnimation { mostrarMenu = false }
                    pantallaActual = .reservacion
                },
                accionSolicitudes: {
                    withAnimation { mostrarMenu = false }
                    // Solo el administrador puede ir a Solicitudes
                    if usuarioActual?.rol == .administrador {
                        pantallaActual = .solicitudes
                    }
                }
            )
            .frame(width: min(320, UIScreen.main.bounds.width * 0.68))

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: {
                        cerrarSesion()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 110, height: 95)
                            .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.93, green: 0.93, blue: 0.94))
        }
        .ignoresSafeArea()
    }

    private func cerrarSesion() {
        AuthManager.shared.cerrarSesion()
        mostrarMenu = false
        usuarioActual = nil
        pantallaActual = .login
    }
}

#Preview {
    ContentView()
}
