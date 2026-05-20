//
//  UsuariosAdminView.swift
//  45,43 - app final
//
//  Created by Alumno on 20/05/26.
//

//
//  UsuariosAdminView.swift
//  45,43 - app final
//

import SwiftUI

struct UsuariosAdminView: View {
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    @State private var usuarios: [Usuario] = []

    @State private var usuarioEditando: Usuario? = nil
    @State private var nombre = ""
    @State private var correo = ""
    @State private var contrasena = ""
    @State private var rolSeleccionado: RolUsuario = .jefatura

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
                        formularioUsuario

                        if mostrarMensaje {
                            mensajeView
                        }

                        listaUsuarios
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 28)
                }
            }
        }
        .onAppear {
            cargarUsuarios()
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

                Text("Usuarios")
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

    private var formularioUsuario: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(usuarioEditando == nil ? "Agregar usuario" : "Editar usuario")
                .font(.system(size: 23, weight: .bold))
                .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))

            TextField("Nombre completo", text: $nombre)
                .textInputAutocapitalization(.words)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)

            TextField("Correo electrónico", text: $correo)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)

            SecureField(usuarioEditando == nil ? "Contraseña" : "Nueva contraseña opcional", text: $contrasena)
                .padding()
                .background(Color.gray.opacity(0.12))
                .cornerRadius(12)

            Text("Tipo de usuario")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)

            Picker("Rol", selection: $rolSeleccionado) {
                Text("Administrador").tag(RolUsuario.administrador)
                Text("Directivo").tag(RolUsuario.directivo)
                Text("Jefatura").tag(RolUsuario.jefatura)
            }
            .pickerStyle(.segmented)

            HStack(spacing: 12) {
                Button(action: guardarUsuario) {
                    Text(usuarioEditando == nil ? "Agregar" : "Guardar cambios")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                        .cornerRadius(16)
                }

                if usuarioEditando != nil {
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

    private var listaUsuarios: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Usuarios registrados")
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.black)

            if usuarios.isEmpty {
                Text("No hay usuarios registrados.")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(14)
            } else {
                ForEach(usuarios) { usuario in
                    tarjetaUsuario(usuario)
                }
            }
        }
    }

    private func tarjetaUsuario(_ usuario: Usuario) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(usuario.nombre)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)

                    Text(usuario.correo)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                Text(usuario.rol.descripcion)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(colorRol(usuario.rol))
                    .cornerRadius(12)
            }

            HStack(spacing: 10) {
                Button(action: {
                    cargarParaEditar(usuario)
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
                    eliminar(usuario)
                }) {
                    Text("Eliminar")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .background(Color(red: 1.00, green: 0.34, blue: 0.34))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }

    // MARK: - Acciones

    private func guardarUsuario() {
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        let correoLimpio = correo.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let contrasenaLimpia = contrasena.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !nombreLimpio.isEmpty, !correoLimpio.isEmpty else {
            mostrar("❌ Ingresa nombre y correo.")
            return
        }

        if usuarioEditando == nil && contrasenaLimpia.isEmpty {
            mostrar("❌ Ingresa una contraseña.")
            return
        }

        let exito: Bool

        if let usuarioEditando = usuarioEditando {
            exito = DatabaseManager.shared.actualizarUsuario(
                id: usuarioEditando.id,
                nombre: nombreLimpio,
                correo: correoLimpio,
                rol: rolSeleccionado,
                contrasena: contrasenaLimpia.isEmpty ? nil : contrasenaLimpia
            )
        } else {
            exito = DatabaseManager.shared.insertarUsuario(
                nombre: nombreLimpio,
                correo: correoLimpio,
                contrasena: contrasenaLimpia,
                rol: rolSeleccionado
            )
        }

        if exito {
            mostrar(usuarioEditando == nil ? "✅ Usuario agregado." : "✅ Usuario actualizado.")
            limpiarFormulario()
            cargarUsuarios()
        } else {
            mostrar("❌ No se pudo guardar. Revisa si el correo ya existe.")
        }
    }

    private func cargarParaEditar(_ usuario: Usuario) {
        usuarioEditando = usuario
        nombre = usuario.nombre
        correo = usuario.correo
        contrasena = ""
        rolSeleccionado = usuario.rol
    }

    private func eliminar(_ usuario: Usuario) {
        let exito = DatabaseManager.shared.eliminarUsuario(id: usuario.id)

        if exito {
            mostrar("✅ Usuario eliminado.")
            cargarUsuarios()
        } else {
            mostrar("❌ No se pudo eliminar. No puedes eliminar el último administrador.")
        }
    }

    private func cargarUsuarios() {
        usuarios = DatabaseManager.shared.obtenerUsuarios()
    }

    private func limpiarFormulario() {
        usuarioEditando = nil
        nombre = ""
        correo = ""
        contrasena = ""
        rolSeleccionado = .jefatura
    }

    private func mostrar(_ texto: String) {
        mensaje = texto
        mostrarMensaje = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mostrarMensaje = false
        }
    }

    private func colorRol(_ rol: RolUsuario) -> Color {
        switch rol {
        case .administrador:
            return Color(red: 0.10, green: 0.45, blue: 0.67)
        case .directivo:
            return Color(red: 0.55, green: 0.20, blue: 0.70)
        case .jefatura:
            return Color(red: 0.05, green: 0.55, blue: 0.35)
        }
    }

    private var mensajeView: some View {
        Text(mensaje)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(mensaje.contains("❌") ? .red : .green)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(mensaje.contains("❌") ? Color.red.opacity(0.10) : Color.green.opacity(0.10))
            .cornerRadius(12)
    }
}

#Preview {
    UsuariosAdminView(
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
