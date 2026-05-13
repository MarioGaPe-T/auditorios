import SwiftUI

struct CampoSeguroConEtiqueta: View {
    let titulo: String
    let placeholder: String
    @Binding var texto: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)

            SecureField(placeholder, text: $texto)
                .font(.system(size: 17))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding(.horizontal, 18)
                .frame(height: 58)
                .background(Color.white)
                .cornerRadius(16)
        }
    }
}
