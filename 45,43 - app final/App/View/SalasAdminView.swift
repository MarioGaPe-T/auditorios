//
//  SalasAdminView.swift
//  45,43 - app final
//

import SwiftUI

struct SalasAdminView: View {
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    @State private var salas: [Sala] = []

    @State private var salaEditando: Sala? = nil
    @State private var nombre = ""
    @State private var descripcion = ""
    @State private var capacidad = ""
    @State private var activa = true

    @State private var mensaje = ""
    @State private var mostrarMensaje = false

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                barraSuperior

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        formularioSala

                        if mostrarMensaje {
                            mensajeView
                        }

                        listaSalas
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 28)
                }
            }
        }
        .onAppear {
            cargarSalas()
        }
    }

    // MARK: - Barra superior

    private var barraSuperior: some View {
        ZStack {
            Color(red: 0.10, green: 0.45, blue: 0.67)
                .ignoresSafeArea(edges: .top)

            HStack {
                Button(action: accionAbrirMenu) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Text("Salas")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Button(action: accionCerrarSesion) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .frame(height: 110)
    }

    // MARK: - Formulario

    private var formularioSala: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(salaEditando == nil ? "Agregar sala" : "Editar sala")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))

            TextField("Nombre de la sala", text: $nombre)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)

            TextField("Descripción", text: $descripcion)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)

            TextField("Capacidad", text: $capacidad)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)

            if salaEditando != nil {
                Toggle("Sala activa", isOn: $activa)
            }

            HStack(spacing: 12) {
                Button(action: guardarSala) {
                    Text(salaEditando == nil ? "Agregar" : "Guardar cambios")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                        .cornerRadius(16)
                }

                if salaEditando != nil {
                    Button(action: limpiarFormulario) {
                        Text("Cancelar")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.gray)
                            .cornerRadius(16)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .padding(.top, 12)
    }

    // MARK: - Lista

    private var listaSalas: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Salas registradas")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.black)

            if salas.isEmpty {
                Text("No hay salas registradas.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(14)
            } else {
                ForEach(salas) { sala in
                    tarjetaSala(sala)
                }
            }
        }
    }

    private func tarjetaSala(_ sala: Sala) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(sala.nombre)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                    Text(sala.descripcion)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    Text("Capacidad: \(sala.capacidad)")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(sala.activa ? "Activa" : "Inactiva")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(sala.activa ? Color.green : Color.gray)
                    .cornerRadius(12)
            }

            HStack(spacing: 10) {
                Button(action: {
                    cargarParaEditar(sala)
                }) {
                    Text("Editar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                        .cornerRadius(12)
                }

                Button(action: {
                    eliminarOReactivar(sala)
                }) {
                    Text(sala.activa ? "Eliminar" : "Reactivar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(sala.activa ? Color(red: 1.00, green: 0.34, blue: 0.34) : Color.green)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Acciones

    private func guardarSala() {
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let descripcionLimpia = descripcion.trimmingCharacters(in: .whitespacesAndNewlines)
        let capacidadNumero = Int(capacidad.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        guard !nombreLimpio.isEmpty else {
            mostrar("❌ Ingresa el nombre de la sala.")
            return
        }

        guard !descripcionLimpia.isEmpty else {
            mostrar("❌ Ingresa una descripción.")
            return
        }

        guard capacidadNumero > 0 else {
            mostrar("❌ Ingresa una capacidad válida.")
            return
        }

        let exito: Bool

        if let salaEditando = salaEditando {
            exito = DatabaseManager.shared.actualizarSala(
                id: salaEditando.id,
                nombre: nombreLimpio,
                descripcion: descripcionLimpia,
                capacidad: capacidadNumero,
                tieneMicrofono: false,
                tieneBocina: false,
                tieneProyector: false,
                activa: activa
            )
        } else {
            exito = DatabaseManager.shared.insertarSala(
                nombre: nombreLimpio,
                descripcion: descripcionLimpia,
                capacidad: capacidadNumero,
                tieneMicrofono: false,
                tieneBocina: false,
                tieneProyector: false,
                activa: true
            )
        }

        if exito {
            mostrar(salaEditando == nil ? "✅ Sala agregada." : "✅ Sala actualizada.")
            limpiarFormulario()
            cargarSalas()
        } else {
            mostrar("❌ No se pudo guardar. Puede que la sala ya exista.")
        }
    }

    private func cargarParaEditar(_ sala: Sala) {
        salaEditando = sala
        nombre = sala.nombre
        descripcion = sala.descripcion
        capacidad = "\(sala.capacidad)"
        activa = sala.activa
    }

    private func eliminarOReactivar(_ sala: Sala) {
        let exito: Bool

        if sala.activa {
            exito = DatabaseManager.shared.eliminarSala(id: sala.id)
        } else {
            exito = DatabaseManager.shared.reactivarSala(id: sala.id)
        }

        if exito {
            mostrar(sala.activa ? "✅ Sala eliminada." : "✅ Sala reactivada.")
            cargarSalas()
        } else {
            mostrar("❌ No se pudo actualizar la sala.")
        }
    }

    private func cargarSalas() {
        salas = DatabaseManager.shared.obtenerSalas(incluirInactivas: true)
    }

    private func limpiarFormulario() {
        salaEditando = nil
        nombre = ""
        descripcion = ""
        capacidad = ""
        activa = true
    }

    private func mostrar(_ texto: String) {
        mensaje = texto
        mostrarMensaje = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mostrarMensaje = false
        }
    }

    private var mensajeView: some View {
        Text(mensaje)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(mensaje.contains("❌") ? .red : .green)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                mensaje.contains("❌")
                ? Color.red.opacity(0.10)
                : Color.green.opacity(0.10)
            )
            .cornerRadius(12)
    }
}

#Preview {
    SalasAdminView(
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
