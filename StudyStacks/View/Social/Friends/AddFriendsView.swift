//
//  AddFriendsView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct AddFriendsView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading, spacing: 20) {
                    
                    //HEADING
                    VStack(alignment: .leading) {
                        Text("Add Friend")
                            .customHeading(.title)
                        Text("Add your friends via email")
                    }
                    
                    //SEARCH
                    VStack(alignment: .leading) {
                        TextField("Enter your friend's email", text: $email)
                            .padding()
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .background {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.surface)
                            }
                            .padding(.bottom, 20)
                        
                        Button {
                            Task {
                                await sendFriendRequest()
                            }
                        } label: {
                            GeneralButton(placeholder: "send request!", backgroundColor: Color.prim, foregroundColor: Color.white, isSystemImage: false)
                        }
                        .disabled(email.isEmpty)
                    }
                    
                    //TODO: show recommended friends
                }
                .padding()
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Friend Request"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    private func sendFriendRequest() async {
        guard !email.isEmpty else {
            alertMessage = "Please enter an email"
            showAlert = true
            return
        }
        if let currentUserID = auth.user?.id {
            if let currentUserEmail = auth.user?.email {
                let (success, errorMessage) = await friendVM.sendFriendRequest(toEmail: email, senderID: currentUserID, senderEmail: currentUserEmail)
                
                if success {
                    alertMessage = errorMessage
                    showAlert = true
                    dismiss()
                } else {
                    alertMessage = errorMessage
                    showAlert = true
                }
            }
        }
    }
    
}

#Preview {
    AddFriendsView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
