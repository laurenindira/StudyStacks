//
//  FriendRow.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct FriendRow: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    var friend: Friend
    var isRequest: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            //USER INFO
            Circle()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                Text(friend.displayName)
                    .font(.headline)
                Text("@\(friend.username)")
                    .font(.body)
            }
            Spacer()
            
            //IF REQUESTS
            if isRequest {
                Button {
                    Task {
                        await friendVM.acceptFriendRequest(senderID: friend.id)
                    }
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
                    Task {
                        await friendVM.rejectFriendRequest(senderID: friend.id)
                    }
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
    FriendRow(friend: Friend(id: "", username: "johndoe", displayName: "john doe", email: "johndoe@jdoe.com", creationDate: Date(), currentStreak: 5), isRequest: false)
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
