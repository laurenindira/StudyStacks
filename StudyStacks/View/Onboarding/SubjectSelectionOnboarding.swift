//
//  SubjectSelectionOnboarding.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/5/25.
//

import SwiftUI

struct SubjectSelectionOnboarding: View {
    @Binding var user: User
    @Binding var step: Int
    @Namespace private var animation
    
    //TODO: determine what subjects our pre-loading stacks will be based on
    let subjectOptions = ["Math","Chemistry", "Biology", "Physics",  "Computer Science", "Political Science", "Law", "Electrical Engineering", "Medicine", "None of these tbh..."]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Cool! Now, tell us what subjects you're interested in!")
                .font(.headline)
            Text("(It's how we give you relevant stack recommendations)")
                .font(.footnote)
            
            //SELECTED SUBJECTS
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(user.selectedSubjects, id: \.self) { subject in
                        TagView(tag: subject, backColor: Color.prim, textColor: Color.lod, icon: "checkmark")
                            .matchedGeometryEffect(id: subject, in: animation)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    user.selectedSubjects.removeAll(where: { $0 == subject } )
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding()
            }
            .scrollClipDisabled(true)
            .scrollIndicators(.hidden)
            .padding(.top, 20)
            .overlay(content: {
                if user.selectedSubjects.isEmpty {
                    Text("You gotta pick at least one subject!")
                        .font(.callout)
                        .padding(10)
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.prim.opacity(0.25))
                                .stroke(Color.prim, style: StrokeStyle(lineWidth: 2))
                        }
                }
            })
            
            //TAG LIST
            VStack {
                TagLayout(alignment: .center, spacing: 10) {
                    ForEach(subjectOptions.filter { !user.selectedSubjects.contains($0) }, id: \.self) { subject in
                        TagView(tag: subject, backColor: Color.surface, textColor: Color.text, icon: "plus")
                            .matchedGeometryEffect(id: subject, in: animation)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    user.selectedSubjects.insert(subject, at: 0)
                                }
                            }
                    }
                }
                .padding()
            }
    
            Button {
                if !user.selectedSubjects.isEmpty { step += 1 }
            } label: {
                GeneralButton(placeholder: "Next", backgroundColor: Color.prim, foregroundColor: Color.lod, imageRight: "arrow.right", isSystemImage: true)
            }
            .disabled(user.selectedSubjects.count < 1)
            .opacity(user.selectedSubjects.count < 1 ? 0.5 : 1)
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
    func TagView(tag: String, backColor: Color, textColor: Color, icon: String) -> some View {
        HStack(spacing: 5) {
            Text(tag)
                .font(.callout)
            Image(systemName: icon)
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
    SubjectSelectionOnboarding(user: .constant(User(id: "", username: "", displayName: "", email: "", creationDate: Date.now, providerRef: "", selectedSubjects: [], studyReminderTime: Date.now, studentType: "", currentStreak: 0, longestStreak: 0, favoriteStackIDs: [])), step: .constant(2))
}
