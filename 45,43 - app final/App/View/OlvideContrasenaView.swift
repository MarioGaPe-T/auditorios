import SwiftUI

struct OlvideContrasenaView: View {
    let accionEnviar: () -> Void
    let accionVolver: () -> Void

    @State private var correo = ""
    @State private var mensaje = ""

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Button(action: accionVolver) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer().frame(height: 30)

                Image(systemName: "lock.rotation")
                    .font(.system(size: 64))
                    .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))

                Text("Recuperar contraseña")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))

                Text("Ingresa tu correo institucional para continuar.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                CampoConEtiqueta(
                    titulo: "CORREO ELECTRÓNICO",
                    placeholder: "correo@tuxtla.tecnm.mx",
                    texto: $correo
                )
                .keyboardType(.emailAddress)
                .padding(.horizontal, 34)

                if !mensaje.isEmpty {
                    Text(mensaje)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.horizontal, 24)
                }

                Button(action: enviar) {
                    Text("Enviar")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                        .cornerRadius(29)
                }
                .padding(.horizontal, 34)

                Spacer()
            }
        }
    }

    private func enviar() {
        mensaje = "Solicitud enviada."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            accionEnviar()
        }
    }
}
