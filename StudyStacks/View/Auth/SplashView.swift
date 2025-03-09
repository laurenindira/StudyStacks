//
//  SplashView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/7/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var auth: AuthViewModel
    
    @State private var tempUser = User(id: "", username: "", displayName: "", email: "", creationDate: Date(), providerRef: "", selectedSubjects: [], studyReminderTime: Date(), studentType: "")
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack {
                    Image("logo_vertical")
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.5)
                    Text("cause no other app stacks up")
                }
                
                Spacer()
                
                VStack(spacing: 10) {
                    NavigationLink {
                        OnboardingControl(user: $tempUser)
                    } label: {
                        GeneralButton(placeholder: "get started", backgroundColor: Color.prim, foregroundColor: Color.lod, isSystemImage: false)
                    }
                    
                    HStack {
                        Text("already have an account?")
                        NavigationLink("Sign in", destination: SignInView())
                            .foregroundStyle(Color.prim)
                    }
                }
            }
            .padding()
            .background(Color.background)
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AuthViewModel())
}
