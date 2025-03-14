//
//  SignUpView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 2/9/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(AuthViewModel.self) private var auth
    @Environment(\.dismiss) private var dismiss
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State var username: String = ""
    @State var displayName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var showPassword: Bool = false
    @State var showConfirmPassword: Bool = false
    
    var tempUser: User
    
    var showPasswordToggle: Bool {
        get { showPassword }
        set { showPassword = newValue }
    }
    
    var showConfirmPasswordToggle: Bool {
        get { showPassword }
        set { showPassword = newValue }
    }
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 10) {
                
                //LOGO
                VStack (spacing: 5) {
                    Image("logo_prim")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.4)
                        
                    Text("create an account")
                        .font(.customHeading(.title3))
                }
                
                //FIELDS
                VStack (alignment: .leading, spacing: 10) {
                    VStack (alignment: .leading, spacing: 5) {
                        Text("username")
                            .font(.headline)
                            .foregroundStyle(Color.secondaryText)
                        GeneralTextField(placeholder: "username", text: $username)
                    }
//                    VStack (alignment: .leading, spacing: 5) {
//                        Text("display name")
//                            .font(.headline)
//                            .foregroundStyle(Color.secondaryText)
//                        GeneralTextField(placeholder: "display name", text: $displayName)
//                    }
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
                    VStack (alignment: .leading, spacing: 5) {
                        Text("confirm password")
                            .font(.headline)
                            .foregroundStyle(Color.secondaryText)
                        SecureTextField(placeholder: "confirm password", showPassword: showConfirmPasswordToggle, text: $confirmPassword)
                    }
                }
                .padding(.bottom, 25)
                
                VStack {
                    //SIGN UP BUTTON
                    Button {
                        emailSignUp()
                    } label: {
                        GeneralButton(placeholder: "sign up", backgroundColor: formIsValid ? Color.prim : Color.disabled, foregroundColor: Color.white, isSystemImage: false)
                    }
                    .disabled(!formIsValid)
                    
                    Text("or")
                    
                    Button {
                        googleSignUp()
                    } label: {
                        GeneralButton(placeholder: "sign up with Google", backgroundColor: Color.prim, foregroundColor: Color.white, imageRight: "google_logo", isSystemImage: false)
                    }
                    
                    HStack {
                        Text("already have an account?")
                        NavigationLink("Sign In") {
                            SignInView()
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
                    LoadingView(description: "creating account...")
                }
            }
            
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error making account"), message: Text(auth.errorMessage ?? ""), primaryButton: .default(Text("Try again")), secondaryButton: .cancel(Text("Go back")) { dismiss() })
        }
    }
        
    
    func emailSignUp() {
        Task {
            do {
                print(tempUser)
                try await auth.signUpWithEmail(email: email, password: password, username: username, displayName: tempUser.displayName, selectedSubjects: tempUser.selectedSubjects, studyReminderTime: tempUser.studyReminderTime, studentType: tempUser.studentType)
            } catch {
                showAlert = true
            }
            
        }
    }
    
    func googleSignUp() {
        auth.signInWithGoogle(tempUser: tempUser, presenting: getRootViewController()) { error in
            if error != nil {
                showAlert = true
            }
        }
    }
}

extension SignUpView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty && email.contains("@") && email.contains(".") && !password.isEmpty && password.count >= 6 && !username.isEmpty && password == confirmPassword
    }
}

#Preview {
    SignUpView(tempUser: User(id: "", username: "", displayName: "", email: "", creationDate: Date(), providerRef: "", selectedSubjects: [], studyReminderTime: Date(), studentType: ""))
        .environmentObject(AuthViewModel())
}

