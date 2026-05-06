//
//  OlvideContrasenaView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct OlvideContrasenaView: View {
    let accionEnviar: () -> Void
    let accionVolver: () -> Void

    @State private var correo = ""

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

            VStack(spacing: 26) {
                Text("¿Olvidaste tu\ncontraseña?")
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)

                Text("Contraseña nueva")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
        }
        .frame(height: 320)
    }

    private var formulario: some View {
        VStack(spacing: 28) {
            CampoConEtiqueta(
                titulo: "ESCRIBE TU CORREO ELECTRÓNICO",
                placeholder: "l22270445@tuxtla.tecnm.mx",
                texto: $correo
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)

            Button(action: accionEnviar) {
                Text("Enviar")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 62)
                    .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                    .cornerRadius(32)
            }
            .padding(.top, 8)

            Button(action: accionVolver) {
                Text("Volver al inicio de sesiòn")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
            }

            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 38)
    }
}

#Preview {
    OlvideContrasenaView(
        accionEnviar: {},
        accionVolver: {}
    )
}
