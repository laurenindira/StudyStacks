//
//  UserInfoOverview.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/23/25.
//

import SwiftUI

struct UserInfoOverview: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel

    @State var isEditing: Bool = false

    @State var displayName: String = ""
    @State var studentType: String = ""
    @State var subjectInterests: [String] = []
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    //TITLE
                    Text("User Information")
                        .customHeading(.title)
                                        
                    VStack(alignment: .leading) {
                        Text("Account Information")
                            .font(.headline)
                        
                        VStack (spacing: 15) {
                            ProfileRow(title: "Username", value: auth.user?.username ?? "unknown")
                            ProfileRow(title: "Email", value: auth.user?.email ?? "unknown")
                            ProfileRow(title: "Account made via", value: auth.user?.providerRef ?? "unknown")
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.surface)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("User Preferences")
                            .font(.headline)
                        VStack (spacing: 15) {
                            ProfileRow(title: "Display Name", value: auth.user?.displayName ?? "unknown")
                            ProfileRow(title: "Learner Type", value: auth.user?.studentType ?? "unknown")
                            ProfileRow(title: "Subjects of Interest", value: auth.user?.selectedSubjects.joined(separator: ", ") ?? "unknown")
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.surface)
                        }
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isEditing.toggle()
                    } label: {
                        HStack {
                            Text("Edit")
                            Image(systemName: "pencil")
                        }
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditProfileView(isEditing: $isEditing)
            }
        }
    }
}

#Preview {
    UserInfoOverview()
}
