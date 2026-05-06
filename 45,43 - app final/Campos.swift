//
//  Campos.swift
//  45,43 - app final
//
//  Created by Alumno on 15/04/26.
//

import SwiftUI

struct CampoConEtiqueta: View {
    let titulo: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titulo)
                .font(.system(size: 14, weight: .medium))
                .tracking(3)
                .foregroundColor(.gray)

            TextField(placeholder, text: $texto)
                .font(.system(size: 18))
                .padding(.horizontal, 18)
                .frame(height: 58)
                .background(Color(red: 0.88, green: 0.88, blue: 0.89))
                .cornerRadius(24)
                .autocorrectionDisabled()
        }
    }
}

struct CampoSeguroConEtiqueta: View {
    let titulo: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(titulo)
                .font(.system(size: 14, weight: .medium))
                .tracking(3)
                .foregroundColor(.gray)

            SecureField(placeholder, text: $texto)
                .font(.system(size: 18))
                .padding(.horizontal, 18)
                .frame(height: 58)
                .background(Color(red: 0.88, green: 0.88, blue: 0.89))
                .cornerRadius(24)
        }
    }
}
