//
//  SignInView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State var email: String = ""
    @State var password: String = ""
    @State var showPassword: Bool = false
    
    @State private var tempUser = User(id: "", username: "", displayName: "", email: "", creationDate: Date(), providerRef: "", selectedSubjects: [], studyReminderTime: Date(), studentType: "")
    
    var showPasswordToggle: Bool {
        get { showPassword }
        set { showPassword = newValue }
    }
        
    var body: some View {
        NavigationStack {
            VStack (spacing: 10) {
                
                Spacer()
                
                //LOGO
                VStack (spacing: 5) {
                    Image("logo_prim")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.5)
                        
                    Text("sign into your account")
                        .font(.customHeading(.title3))
                }
                
                //FIELDS
                VStack (alignment: .leading, spacing: 10) {
                    VStack (alignment: .leading, spacing: 5) {
                        Text("email")
                            .font(.headline)
                            .foregroundStyle(Color.secondaryText)
                        GeneralTextField(placeholder: "email", text: $email)
                    }
                    VStack (alignment: .leading, spacing: 5) {
                        Text("password")
                            .font(.headline)
                            .foregroundStyle(Color.secondaryText)
                        SecureTextField(placeholder: "password", showPassword: showPasswordToggle, text: $password)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                VStack {
                    //SIGN UP BUTTON
                    Button {
                        emailSignIn()
                    } label: {
                        GeneralButton(placeholder: "sign in", backgroundColor: formIsValid ? Color.prim : Color.disabled, foregroundColor: Color.white, isSystemImage: false)
                    }
                    .disabled(!formIsValid)
                    
                    Text("or")
                    
                    Button {
                        googleSignIn()
                    } label: {
                        GeneralButton(placeholder: "sign in with Google", backgroundColor: Color.prim, foregroundColor: Color.white, imageRight: "google_logo", isSystemImage: false)
                    }
                    
                    HStack {
                        Text("don't have an account?")
                        NavigationLink("Sign Up") {
                            OnboardingControl(user: $tempUser)
                        }
                        .foregroundStyle(Color.prim)
                        .bold()
                    }
                    .font(.callout)
                    .padding(.top, 10)
                }
        
            }
            .frame(maxHeight: UIScreen.main.bounds.height)
            .padding(.horizontal, 20)
            .padding(.vertical)
            .background(Color.background)
            .overlay{
                //adding loading screen
                if auth.isLoading {
                    LoadingView(description: "signing back in...")
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error signing in"), message: Text(auth.errorMessage ?? ""), primaryButton: .default(Text("Try again")), secondaryButton: .cancel(Text("Go back")) { dismiss() })
        }
    }
    
    func emailSignIn() {
        Task {
            do {
                try await auth.signInWithEmail(email: email, password: password)
            } catch {
                showAlert = true
            }
        }
    }
    
    func googleSignIn() {
        auth.signInWithGoogle(tempUser: tempUser, presenting: getRootViewController()) { error in
            if error != nil {
                showAlert = true
            }
        }
    }
}

extension SignInView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && email.contains(".") && !password.isEmpty && password.count >= 6
    }
}

#Preview {
    SignInView()
        .environment(AuthViewModel())
}
