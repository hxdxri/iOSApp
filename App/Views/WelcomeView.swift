import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var dataStore: MockDataStore
    @State private var email = ""
    @State private var userType: UserType = .consumer
    @State private var isLoggedIn = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                Text("LocalMeat")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Connect with local farmers and buy quality meat in bulk")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Image(systemName: "leaf")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .foregroundColor(.green)
                    .padding()
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Picker("I am a", selection: $userType) {
                        ForEach(UserType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    Button(action: login) {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(email.isEmpty)
                    .opacity(email.isEmpty ? 0.6 : 1)
                }
                
                Spacer()
                
                NavigationLink(destination: MainTabView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func login() {
        guard !email.isEmpty else { return }
        
        if dataStore.login(email: email, userType: userType) {
            isLoggedIn = true
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(MockDataStore())
} 