//
//  FriendRow.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct FriendRow: View {
    var user: User
    var isRequest: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            //USER INFO
            Circle()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(user.displayName)
                    .font(.headline)
                Text("@\(user.username)")
                    .font(.body)
                //TODO: add in friend connection
                Text("friend since XXXX")
                    .font(.caption)
            }
            Spacer()
            
            //IF REQUESTS
            if isRequest {
                Button {
                    //TODO: accept function
                } label: {
                    Text("accept")
                        .font(.callout)
                        .foregroundStyle(Color.surface)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.prim)
                        }
                }
                
                Button {
                    //TODO: deny function
                } label: {
                    Text("deny")
                        .font(.callout)
                        .foregroundStyle(Color.prim)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke()
                        }
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.surface)
        }
    }
}

#Preview {
    FriendRow(user: User(id: "", username: "testName", displayName: "john doe", email: "jdoe@gmail.com", profilePicture: "", creationDate: Date(), lastSignIn: Date(), providerRef: "google", selectedSubjects: ["Chemistry", "Biology"], studyReminderTime: Date(), studentType: "Undergraduate", currentStreak: 4, longestStreak: 10, lastStudyDate: Date()), isRequest: false)
}
