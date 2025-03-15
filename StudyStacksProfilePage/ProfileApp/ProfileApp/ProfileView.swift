import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthManager // Authentication reference

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Top Bar with Outlined Settings Button
            HStack {
                Spacer()
                NavigationLink(destination: Text("Settings")) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)

            // Profile Section (Using User Model)
            HStack {
                ZStack {
                    Circle()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.white)
                    
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.black)
                }
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 4)
                )
                .padding(.leading, 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(auth.user.name)  // Dynamically pulled from `user`
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text(auth.user.username)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text(auth.user.memberSince)
                        .font(.footnote)
                        .foregroundColor(.gray) // Not bold
                }
                .padding(.leading, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Stats Section (Using User Model)
            HStack {
                VStack {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(red: 134/255, green: 157/255, blue: 234/255))
                    Text("\(auth.user.streak) days") // Uses User model
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Image(systemName: "doc.on.doc.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(red: 134/255, green: 157/255, blue: 234/255))
                    Text("\(auth.user.stacks) stacks") // Uses User model
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Image(systemName: "medal")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(red: 134/255, green: 157/255, blue: 234/255))
                    Text("\(auth.user.badges) badges") // Uses User model
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .background(Color(red: 225/255, green: 238/255, blue: 244/255))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 4)

            Spacer()
        }
        .padding(.top, 16)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(AuthManager()) // Injecting the auth object
    }
}
