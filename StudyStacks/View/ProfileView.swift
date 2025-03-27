import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var stackVM: StackViewModel

    var formattedDate: String {
        guard let date = auth.user?.creationDate else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Top Bar with Settings
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

            // Profile Section
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
                    Text(auth.user?.displayName ?? "Display Name")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("@\(auth.user?.username ?? "username")")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)

                    Text("Member since \(formattedDate)")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.leading, 30)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Stats
            HStack {
                VStack {
                    Image(systemName: "doc.on.doc.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(red: 134/255, green: 157/255, blue: 234/255))
                    Text("\(stackVM.stacks.count) stacks")
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(red: 134/255, green: 157/255, blue: 234/255))
                    Text("Reminder: \(auth.user?.studyReminderTime.formatted(date: .omitted, time: .shortened) ?? "None")")
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)

                VStack {
                    Image(systemName: "graduationcap")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color(red: 134/255, green: 157/255, blue: 234/255))
                    Text(auth.user?.studentType ?? "Unknown")
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

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
        .environmentObject(StackViewModel())
}
