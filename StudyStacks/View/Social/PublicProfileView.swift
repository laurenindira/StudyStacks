//
//  PublicProfileView.swift
//  StudyStacks
//
//  Created by Lauren Indira on 3/26/25.
//

import SwiftUI

struct PublicProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel
    @EnvironmentObject var friendVM: FriendsViewModel
    
    var friend: Friend
    @State var friendCount: Int = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading, spacing: 20) {
                    //HEADER
                    HStack (alignment: .center, spacing: 15) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 90))
                        
                        VStack (alignment: .leading) {
                            Text(friend.displayName)
                                .customHeading(.title)
                            Text("@\(friend.username)")
                                .font(.headline)
                            Text("Member since \(friend.creationDate.formatted(Date.FormatStyle().year(.defaultDigits)))")
                        }
                        Spacer()
                    }
                    
                    //INFO BAR
                    HStack (alignment: .center, spacing: 20) {
                        //STREAKS
                        VStack (alignment: .center, spacing: 2) {
                            Image(systemName: "fireworks")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.sec)
                            Text("\(String(friend.currentStreak)) days")
                                .font(.body)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                        
                        //STACKS
                        VStack (alignment: .center, spacing: 2) {
                            Image(systemName: "square.stack")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.sec)
                            Text("\(friendStacks.count) stacks")
                                .font(.body)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                        
                        //FRIENDS
                        VStack (alignment: .center, spacing: 2) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.sec)
                                .padding(.vertical, 5)
                            Text("\(friendCount) friends")
                                .font(.body)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.surface)
                    }
                    
                    //STACKS
                    Text("\(friend.displayName)'s Stacks")
                        .customHeading(.title2)
                    VStack {
                        if friendStacks.isEmpty {
                            ErrorView(errorMessage: "Womp womp... Looks like there aren't any stacks here right now :/", imageName: "empty-box", isSystemImage: false)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(friendStacks, id: \.self) { stack in
                                // TODO: add in check for if card is favorite
                                NavigationLink {
                                    StackDetailView(stack: stack)
                                } label: {
                                    StackCardView(stack: stack, isFavorite: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    Task {
                        
                        friendCount = await friendVM.getFriendCount(userID: friend.id)
                    }
                }
            }
        }
    }
    
    
    var friendStacks: [Stack] {
        return stackVM.publicStacks.filter { $0.creatorID == friend.id }
    }
    
}

#Preview {
    PublicProfileView(friend: Friend(id: "", username: "johndoe", displayName: "john doe", email: "johndoe@jdoe.com", creationDate: Date(), currentStreak: 5))
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
        .environmentObject(FriendsViewModel())
}
