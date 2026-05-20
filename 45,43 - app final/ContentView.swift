//
//  ContentView.swift
//  45,43 - app final
//

import SwiftUI

enum PantallaActual {
    case login
    case olvideContrasena
    case reservacion
    case solicitudes
    case usuarios
    case salas
    case estadoSolicitudes
}

struct ContentView: View {
    @State private var pantallaActual: PantallaActual = .login
    @State private var mostrarMenu = false
    @State private var usuarioActual: Usuario? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            contenidoPrincipal

            if debeMostrarMenu && mostrarMenu {
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

    private var debeMostrarMenu: Bool {
        switch pantallaActual {
        case .reservacion, .solicitudes, .usuarios, .salas, .estadoSolicitudes:
            return true

        case .login, .olvideContrasena:
            return false
        }
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
                        withAnimation {
                            mostrarMenu = true
                        }
                    },
                    accionCerrarSesion: {
                        cerrarSesion()
                    }
                )
            } else {
                LoginView(
                    accionOlvideContrasena: {
                        pantallaActual = .olvideContrasena
                    },
                    accionIngresar: { usuario in
                        usuarioActual = usuario
                        pantallaActual = .reservacion
                    }
                )
            }

        case .solicitudes:
            if let usuario = usuarioActual,
               usuario.rol == .administrador {
                SolicitudesView(
                    usuario: usuario,
                    accionAbrirMenu: {
                        withAnimation {
                            mostrarMenu = true
                        }
                    },
                    accionCerrarSesion: {
                        cerrarSesion()
                    }
                )
            } else {
                pantallaNoAutorizada
            }

        case .usuarios:
            if usuarioActual?.rol == .administrador {
                UsuariosAdminView(
                    accionAbrirMenu: {
                        withAnimation {
                            mostrarMenu = true
                        }
                    },
                    accionCerrarSesion: {
                        cerrarSesion()
                    }
                )
            } else {
                pantallaNoAutorizada
            }

        case .salas:
            if usuarioActual?.rol == .administrador {
                SalasAdminView(
                    accionAbrirMenu: {
                        withAnimation {
                            mostrarMenu = true
                        }
                    },
                    accionCerrarSesion: {
                        cerrarSesion()
                    }
                )
            } else {
                pantallaNoAutorizada
            }
        case .estadoSolicitudes:
            if let usuario = usuarioActual {
                EstadoSolicitudesView(
                    usuario: usuario,
                    accionAbrirMenu: {
                        withAnimation {
                            mostrarMenu = true
                        }
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
                    withAnimation {
                        mostrarMenu = false
                    }

                    pantallaActual = .reservacion
                },
                accionUsuarios: {
                    withAnimation {
                        mostrarMenu = false
                    }

                    if usuarioActual?.rol == .administrador {
                        pantallaActual = .usuarios
                    }
                },
                accionSalas: {
                    withAnimation {
                        mostrarMenu = false
                    }

                    if usuarioActual?.rol == .administrador {
                        pantallaActual = .salas
                    }
                },
                accionReservaciones: {
                    withAnimation {
                        mostrarMenu = false
                    }

                    pantallaActual = .reservacion
                },
                accionEstadoSolicitudes: {
                    withAnimation {
                        mostrarMenu = false
                    }

                    pantallaActual = .estadoSolicitudes
                },
                accionSolicitudes: {
                    withAnimation {
                        mostrarMenu = false
                    }

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

    private var pantallaNoAutorizada: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 54))
                    .foregroundColor(Color(red: 1.00, green: 0.34, blue: 0.34))

                Text("Acceso no autorizado")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                Text("Esta sección solo está disponible para administradores.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Button(action: {
                    pantallaActual = .reservacion
                }) {
                    Text("Volver a reservaciones")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 230, height: 52)
                        .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                        .cornerRadius(18)
                }
            }
            .padding()
        }
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
