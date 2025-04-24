//
//  EditProfileView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/23/25.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel

    @Binding var isEditing: Bool

    @State var displayName: String = ""
    @State var studentType: String = "Undergraduate"
    @State var selectedSubjects: Set<String> = []
    
    let studentTypes = ["High School", "Undergraduate", "Graduate", "Professional", "Other"]
    let subjectOptions = ["Math","Chemistry", "Biology", "Physics", "Medicine", "Law", "Electrical Engineering", "Computer Science", "Political Science"]
    
    let columns = [GridItem(.adaptive(minimum: 120), spacing: 5)]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    //TITLE
                    Text("Edit Preferences")
                        .customHeading(.title)
                        .padding(.bottom, 20)
                    
                    VStack (alignment: .leading, spacing: 10) {
                        Text("New Display Name")
                            .font(.headline)
                        GeneralTextField(placeholder: "display name", text: $displayName)
                        
                        HStack {
                            Text("Learner Type")
                                .font(.headline)
                            Spacer()
                            Picker("Learner Type", selection: $studentType) {
                                ForEach(studentTypes, id: \.self) { type in
                                    Text(type).tag(type)
                                }
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Subjects of Interest")
                                .font(.headline)
                            
                            TagLayout(alignment: .center, spacing: 10) {
                                ForEach(subjectOptions, id: \.self) { subject in
                                    TagView(tag: subject, backColor: selectedSubjects.contains(subject) ? Color.prim : Color.surface, textColor: selectedSubjects.contains(subject) ? Color.lod : Color.text)
                                            .onTapGesture {
                                                if selectedSubjects.contains(subject) {
                                                    selectedSubjects.remove(subject)
                                                } else {
                                                    selectedSubjects.insert(subject)
                                                }
                                            }
                                            .animation(.easeInOut, value: selectedSubjects)
                                }
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    displayName = auth.user?.displayName ?? "unknown"
                    studentType = auth.user?.studentType ?? "unknown"
                    selectedSubjects = Set(auth.user?.selectedSubjects ?? [])
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        let subjectArray = Array(selectedSubjects)
                        guard let currentUser = auth.user else { return }
                        Task {
                            try await auth.updateUserData(updatedUser: User(id: currentUser.id, username: currentUser.username, displayName: displayName, email: currentUser.email, profilePicture: currentUser.profilePicture ?? nil, creationDate: currentUser.creationDate, lastSignIn: currentUser.lastSignIn, providerRef: currentUser.providerRef, selectedSubjects: subjectArray, studyReminderTime: currentUser.studyReminderTime, studentType: studentType, currentStreak: currentUser.currentStreak, longestStreak: currentUser.longestStreak, lastStudyDate: currentUser.lastStudyDate, points: currentUser.points, favoriteStackIDs: currentUser.favoriteStackIDs))
                        }
                        isEditing.toggle()
                    } label: {
                        Text("Save Changes")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func TagView(tag: String, backColor: Color, textColor: Color) -> some View {
        HStack(spacing: 5) {
            Text(tag)
                .font(.callout)
        }
        .foregroundStyle(textColor)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(backColor)
        }
    }
}

#Preview {
    EditProfileView(isEditing: .constant(true))
}
