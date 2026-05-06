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
}

struct ContentView: View {
    @State private var pantallaActual: PantallaActual = .login
    @State private var mostrarMenu = false

    var body: some View {
        ZStack(alignment: .leading) {
            contenidoPrincipal

            if pantallaActual == .reservacion && mostrarMenu {
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
                accionIngresar: {
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
            ReservacionView(
                accionAbrirMenu: {
                    withAnimation {
                        mostrarMenu = true
                    }
                },
                accionCerrarSesion: {
                    mostrarMenu = false
                    pantallaActual = .login
                }
            )
        }
    }

    private var menuDesplegable: some View {
        HStack(spacing: 0) {
            MenuLateralView(
                accionInicio: {
                    withAnimation {
                        mostrarMenu = false
                    }
                },
                accionUsuarios: {},
                accionRoles: {},
                accionReservaciones: {
                    withAnimation {
                        mostrarMenu = false
                    }
                },
                accionSolicitudes: {
                    // Puedes agregar lógica aquí si lo necesitas
                }
            )
            .frame(width: min(320, UIScreen.main.bounds.width * 0.68))

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    Button(action: {
                        mostrarMenu = false
                        pantallaActual = .login
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
}

#Preview {
    ContentView()
}
