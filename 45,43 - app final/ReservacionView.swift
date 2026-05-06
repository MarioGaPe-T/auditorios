//
//  ReservacionView.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct BloqueHorario: Identifiable {
    let id = UUID()
    let etiquetaDia: String?
    let horaInicio: String
    let horaFin: String
    let disponible: Bool
}

struct ReservacionView: View {
    let accionAbrirMenu: () -> Void
    let accionCerrarSesion: () -> Void

    private let dias = ["LUNES", "MARTES", "MIERCOLES", "JUEVES", "VIERNES"]

    private let bloques: [BloqueHorario] = [
        BloqueHorario(etiquetaDia: "DIA 2", horaInicio: "07:00", horaFin: "08:00", disponible: false),
        BloqueHorario(etiquetaDia: "DIA 3", horaInicio: "07:00", horaFin: "08:00", disponible: true),
        BloqueHorario(etiquetaDia: "DIA 4", horaInicio: "07:00", horaFin: "08:00", disponible: false),
        BloqueHorario(etiquetaDia: "DIA 5", horaInicio: "07:00", horaFin: "08:00", disponible: false),
        BloqueHorario(etiquetaDia: "DIA 6", horaInicio: "07:00", horaFin: "08:00", disponible: false),

        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "08:00", horaFin: "09:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "09:00", horaFin: "10:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "10:00", horaFin: "11:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: false),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "11:00", horaFin: "12:00", disponible: true),

        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true),
        BloqueHorario(etiquetaDia: nil, horaInicio: "12:00", horaFin: "13:00", disponible: true)
    ]

    private let columnas = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.93, blue: 0.94)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                barraSuperior

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text("“Sala Audiovisual E”")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.10, green: 0.45, blue: 0.67))
                            .padding(.top, 10)

                        HStack {
                            Text("Marzo de 2026")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.gray)

                            Spacer()

                            Button(action: {}) {
                                Text("Filtrar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(width: 120, height: 52)
                                    .background(Color(red: 0.84, green: 0.84, blue: 0.84))
                                    .cornerRadius(25)
                            }
                        }

                        LazyVGrid(columns: columnas, spacing: 10) {
                            ForEach(dias, id: \.self) { dia in
                                Text(dia)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(Color.gray)
                            }
                        }

                        LazyVGrid(columns: columnas, spacing: 12) {
                            ForEach(bloques) { bloque in
                                tarjetaHorario(bloque)
                            }
                        }

                        HStack(spacing: 18) {
                            Button(action: {}) {
                                Text("Generar Reservación")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(red: 0.10, green: 0.45, blue: 0.67))
                                    .cornerRadius(28)
                            }

                            Button(action: {}) {
                                Text("Limpiar")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(red: 1.00, green: 0.34, blue: 0.34))
                                    .cornerRadius(28)
                            }
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 18)
                }
            }
        }
    }

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

                Text("Reservación")
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

    private func tarjetaHorario(_ bloque: BloqueHorario) -> some View {
        VStack(spacing: 6) {
            if let etiqueta = bloque.etiquetaDia {
                Text(etiqueta)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }

            Text(bloque.horaInicio)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            Text("–")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)

            Text(bloque.horaFin)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            bloque.disponible
            ? Color(red: 0.05, green: 0.75, blue: 0.38)
            : Color(red: 1.00, green: 0.34, blue: 0.34)
        )
    }
}

#Preview {
    ReservacionView(
        accionAbrirMenu: {},
        accionCerrarSesion: {}
    )
}
