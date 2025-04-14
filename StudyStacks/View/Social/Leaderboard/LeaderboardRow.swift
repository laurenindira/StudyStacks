//
//  LeaderboardRow.swift
//  StudyStacks
//
//  Created by Lauren Indira on 4/12/25.
//

import SwiftUI

struct LeaderboardRow: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    var friend: Friend
    var placement: Int
    
    @AppStorage("userPoints") var currentPoints: Int = 0
    
    var body: some View {
        HStack(spacing: 15) {
            //PLACEMENT
            Text(String(describing: placement))
                .foregroundStyle(Color.secondaryText)
                .font(.callout)
                .padding(10)
                .background {
                    Circle()
                        .fill(Color.white.opacity(0.5))
                        .stroke(Color.secondaryText, lineWidth: 2)
                }
                
            //USER INFO
            //TODO: make this a profile picture
            Circle()
                .frame(width: 50, height: 50)
            
            VStack(alignment: .leading) {
                if let user = AuthViewModel.shared.user {
                    if friend.id == user.id {
                        Text("Me")
                            .font(.headline)
                        
                        Text("\(currentPoints) points")
                            .font(.body)
                        
                    } else {
                        Text(friend.displayName)
                            .font(.headline)
                        Text("\(friend.points) points")
                            .font(.body)
                    }
                }
            }
            Spacer()
            
            //MEDAL
            if placement == 1 {
                Image("gold-medal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            } else if placement == 2 {
                Image("silver-medal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            } else if placement == 3 {
                Image("bronze-medal")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50)
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(friend.id == auth.user?.id ? Color.prim.opacity(0.3) : Color.surface)
        }
    }
}

#Preview {
    LeaderboardRow(friend: Friend(id: "", username: "johndoe", displayName: "john doe", email: "johndoe@jdoe.com", creationDate: Date(), currentStreak: 5, points: 35), placement: 10)
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
