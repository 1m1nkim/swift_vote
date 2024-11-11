import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isConfirmed: Bool = false
    @State private var errorMessage: String = ""
    @State private var isButtonEnabled: Bool = false

    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color(.secondarySystemBackground))

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))

            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))

            Toggle("Agree to terms", isOn: $isConfirmed)
                .onChange(of: isConfirmed) { value in
                    isButtonEnabled = value
                }
                .padding()

            Button(action: signUp) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isButtonEnabled ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!isButtonEnabled)
            
            Text(errorMessage)
                .foregroundColor(.red)
                .padding()
        }
        .padding()
    }

    func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                let firebaseDB = Database.database().reference()
                firebaseDB.child("memberJoin").childByAutoId().setValue(["email": self.email, "password": self.password])
                errorMessage = "Successfully signed up!"
            }
        }
    }
}
