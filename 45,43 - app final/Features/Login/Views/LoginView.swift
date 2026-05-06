//
//  LoginView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct LoginView: View {
    let accionOlvideContrasena: () -> Void
    let accionIngresar: () -> Void

    @State private var correo = ""
    @State private var contrasena = ""

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

            Button(action: accionOlvideContrasena) {
                Text("¿Olvidaste tu contraseña?")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
            }

            Button(action: accionIngresar) {
                Text("Ingresa")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                    .cornerRadius(32)
            }
            .padding(.top, 6)

            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 34)
    }
}

#Preview {
    LoginView(
        accionOlvideContrasena: {},
        accionIngresar: {}
    )
}


