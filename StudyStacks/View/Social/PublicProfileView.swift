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
    
    var user: User
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack (alignment: .leading, spacing: 20) {
                    //HEADER
                    HStack (alignment: .center, spacing: 15) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 90))
                        
                        VStack (alignment: .leading) {
                            Text(user.displayName)
                                .customHeading(.title)
                            Text("@\(user.username)")
                                .font(.headline)
                            Text("Member since \(user.creationDate.formatted(Date.FormatStyle().year(.defaultDigits)))")
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
                            Text("\(String(user.currentStreak)) days")
                                .font(.body)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                        
                        //STACKS
                        VStack (alignment: .center, spacing: 2) {
                            Image(systemName: "square.stack")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.sec)
                            //TODO: add in count for how many stacks... figure out a way to do this without making a million and one calls. search public stacks if user.id == creator id?
                            Text("XX stacks")
                                .font(.body)
                        }
                        .frame(width: UIScreen.main.bounds.width * 0.25)
                        
                        //BADGES
                        VStack (alignment: .center, spacing: 2) {
                            Image(systemName: "medal")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.sec)
                            Text("XX badges")
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
                    Text("\(user.displayName)'s Stacks")
                        .customHeading(.title2)
                    VStack {
                        //TODO: forEach with each user stack. again, add these in once functions are written
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    PublicProfileView(user: User(id: "", username: "testName", displayName: "john doe", email: "jdoe@gmail.com", profilePicture: "", creationDate: Date(), lastSignIn: Date(), providerRef: "google", selectedSubjects: ["Chemistry", "Biology"], studyReminderTime: Date(), studentType: "Undergraduate", currentStreak: 4, longestStreak: 10, lastStudyDate: Date()))
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
