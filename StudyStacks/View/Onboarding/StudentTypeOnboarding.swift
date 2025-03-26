//
//  StudentTypeOnboarding.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/5/25.
//

import SwiftUI

struct StudentTypeOnboarding: View {
    @Binding var user: User
    @Binding var step: Int
    //    let onComplete: () -> Void
    
    let studentTypes = ["High School", "Undergraduate", "Graduate", "Professional", "Other"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Finally, what kind of learner are you?")
                .font(.headline)
            
            VStack {
                TagLayout(alignment: .center, spacing: 10) {
                    ForEach(studentTypes, id: \.self) { type in
                        TagView(tag: type, backColor: user.studentType == type ? Color.prim : Color.surface, textColor: user.studentType == type ? Color.lod : Color.text)
                                .onTapGesture {
                                    user.studentType = (user.studentType == type)  ? "" : type
                                    print(user.studentType)
                                }
                                .animation(.easeInOut, value: user.studentType)
                    }
                }
            }
            
            NavigationLink {
                SignUpView(tempUser: user)
            } label: {
                GeneralButton(placeholder: "Finish!", backgroundColor: Color.prim, foregroundColor: Color.lod, imageRight: "arrow.right", isSystemImage: true)
            }
            .disabled(user.studentType == "")
            .opacity((user.studentType == "") ? 0.5 : 1)
            .padding(.top, 20)
            
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button() {
                    step -= 1
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.body)
                        Text("Back")
                    }
                    .foregroundStyle(Color.prim)
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
    StudentTypeOnboarding(user: .constant(User(id: "", username: "", displayName: "", email: "", creationDate: Date.now, providerRef: "", selectedSubjects: [], studyReminderTime: Date.now, studentType: "", currentStreak: 0, longestStreak: 0)), step: .constant(4))
}
