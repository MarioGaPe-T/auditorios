//
//  FormularioSolicitudView.swift
//  45,43 - app final
//

import SwiftUI

struct FormularioSolicitudView: View {
    let usuario: Usuario
    let sala: String
    let bloquesSeleccionados: [BloqueHorario]
    let accionCancelar: () -> Void
    let accionEnviar: (String, Bool, Bool, Bool) -> Void

    @State private var motivo = ""
    @State private var necesitaMicrofono = false
    @State private var necesitaBocina = false
    @State private var necesitaProyector = false

    var body: some View {
        NavigationView {
            Form {
                Section("Datos de la solicitud") {
                    Text("Solicitante: \(usuario.nombre)")
                    Text("Correo: \(usuario.correo)")
                    Text("Sala: \(sala)")
                }

                Section("Motivo") {
                    TextEditor(text: $motivo)
                        .frame(height: 120)
                }

                Section("Equipo requerido") {
                    Toggle("Micrófono", isOn: $necesitaMicrofono)
                    Toggle("Bocina", isOn: $necesitaBocina)
                    Toggle("Proyector", isOn: $necesitaProyector)
                }

                Section {
                    Button("Enviar solicitud") {
                        accionEnviar(
                            motivo,
                            necesitaMicrofono,
                            necesitaBocina,
                            necesitaProyector
                        )
                    }
                    .disabled(motivo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Cancelar", role: .cancel) {
                        accionCancelar()
                    }
                }
            }
            .navigationTitle("Solicitud")
        }
    }
}
