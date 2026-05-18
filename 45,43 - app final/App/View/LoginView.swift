//
//  LoginView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct LoginView: View {
    let accionOlvideContrasena: () -> Void
    let accionIngresar: (Usuario) -> Void

    @State private var correo = ""
    @State private var contrasena = ""
    @State private var mostrarError = false
    @State private var mensajeError = ""
    @State private var cargando = false

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                encabezado
                formulario
            }
        }
    }

    private var encabezado: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.11, green: 0.46, blue: 0.68),
                    Color(red: 0.07, green: 0.39, blue: 0.60)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 150, height: 150)

                    Image("logo_tecnologico")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 125, height: 125)
                }
                .padding(.top, 20)

                Text("Inicia sesión")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)

                Text("para continuar")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 320)
    }

    private var formulario: some View {
        VStack(spacing: 24) {
            CampoConEtiqueta(
                titulo: "ESCRIBE TU CORREO ELECTRÓNICO",
                placeholder: "LXXXXXXXX@TUXTLA.TECNM.MX",
                texto: $correo
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)

            CampoSeguroConEtiqueta(
                titulo: "ESCRIBE TU CONTRASEÑA",
                placeholder: "******",
                texto: $contrasena
            )

            // Mensaje de error
            if mostrarError {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                    Text(mensajeError)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.10))
                .cornerRadius(12)
            }

            Button(action: accionOlvideContrasena) {
                Text("¿Olvidaste tu contraseña?")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
            }

            Button(action: iniciarSesion) {
                ZStack {
                    Text("Ingresa")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(cargando ? 0 : 1)

                    if cargando {
                        ProgressView()
                            .tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                .cornerRadius(32)
            }
            .disabled(cargando)
            .padding(.top, 6)

            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 34)
    }

    // MARK: - Lógica de login
    private func iniciarSesion() {
        mostrarError = false
        mensajeError = ""

        let correoLimpio = correo
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        guard !correoLimpio.isEmpty else {
            mensajeError = "Ingresa tu correo electrónico."
            mostrarError = true
            return
        }

        guard !contrasena.isEmpty else {
            mensajeError = "Ingresa tu contraseña."
            mostrarError = true
            return
        }

        cargando = true

        let resultado = AuthManager.shared.iniciarSesion(
            correo: correoLimpio,
            contrasena: contrasena
        )

        cargando = false

        switch resultado {
        case .success(let usuario):
            print("✅ Login exitoso: \(usuario.nombre) - \(usuario.rol.descripcion)")
            accionIngresar(usuario)

        case .failure(let error):
            print("❌ Error login: \(error.descripcion)")
            mensajeError = error.descripcion
            mostrarError = true
        }
    }
}

#Preview {
    LoginView(
        accionOlvideContrasena: {},
        accionIngresar: { _ in }
    )
}
