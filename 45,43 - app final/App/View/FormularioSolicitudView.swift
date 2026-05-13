//
//  FormularioSolicitudView.swift
//  45,43 - app final
//
//  Created by Alumno on 13/05/26.
//

import SwiftUI

struct FormularioSolicitudView: View {
    let usuario: Usuario
    let sala: String
    let bloquesSeleccionados: [BloqueHorario]
    let accionCancelar: () -> Void
    let accionEnviar: (
        String,
        Bool,
        Bool,
        Bool
    ) -> Void

    @State private var motivo = ""
    @State private var necesitaMicrofono = false
    @State private var necesitaBocina = false
    @State private var necesitaProyector = false

    private var fecha: String {
        bloquesSeleccionados.first?.fecha ?? ""
    }

    private var horaInicio: String {
        bloquesSeleccionados.first?.horaInicio ?? ""
    }

    private var horaFin: String {
        bloquesSeleccionados.last?.horaFin ?? ""
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Datos de la solicitud") {
                    Text("Solicitante: \(usuario.nombre)")
                    Text("Correo: \(usuario.correo)")
                    Text("Sala: \(sala)")
                    Text("Fecha: \(fecha)")
                    Text("Horario: \(horaInicio) - \(horaFin)")
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
