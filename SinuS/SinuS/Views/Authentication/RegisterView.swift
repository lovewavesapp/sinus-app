//
//  RegisterView.swift
//  SinuS
//
//  Created by Loe Hendriks on 06/11/2022.
//

import SwiftUI
import SwiftKeychainWrapper

struct RegisterView: View {
    let manager = DataManager()

    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert = false
    @State private var showMenu: Bool? = false

    var body: some View {
        VStack {

            // Name
            HStack {
                Text("Name")
                Spacer()
                TextField("", text: self.$name)
                    .disableAutocorrection(true)
                    .frame(width: 220)
                    .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 1.0)
                    )
            }.padding(.horizontal).padding(.top)

            // Email
            HStack {
                Text("Email")
                Spacer()
                TextField("", text: self.$email)
                    .disableAutocorrection(true)
                    .frame(width: 220)
                    .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 1.0)
                    )
            }.padding(.horizontal).padding(.top)

            // Password
            HStack {
                Text("Password")
                Spacer()
                TextField("", text: self.$password)
                    .disableAutocorrection(true)
                    .frame(width: 220)
                    .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 1.0)
                    )
            }.padding(.horizontal).padding(.top)

            // Confirm password
            HStack {
                Text("Confirm password")
                Spacer()
                TextField("", text: self.$confirmPassword)
                    .disableAutocorrection(true)
                    .frame(width: 220)
                    .padding(EdgeInsets(top: 3, leading: 6, bottom: 3, trailing: 6))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(lineWidth: 1.0)
                    )
            }.padding(.horizontal).padding(.top)

            NavigationLink(destination: VerifyEmailView(), tag: true, selection: self.$showMenu) { EmptyView() }

            // Register button
            Button("Register") {
                let authenticationResult = self.manager.register(
                    name: self.name,
                    email: self.email,
                    password: self.password,
                    confirmPassword: self.confirmPassword)

                if authenticationResult == nil {
                    self.showAlert.toggle()
                } else {
                    // Set global authentication token.
                    ContentView.AuthenticationToken = authenticationResult!.success
                    let saveSuccessful: Bool = KeychainWrapper.standard.set(ContentView.AuthenticationToken, forKey: "bearerToken")
                    if !saveSuccessful {
                        print("Could not save bearerToken")
                    }

                    self.showMenu = true
                }

            }
            .alert(isPresented: $showAlert) {
                return Alert(title: Text("Failed to register"), message: Text("Unable to register user: \(self.email)"), dismissButton: .default(Text("OK")))
            }
            .padding()
        }
        .background(Style.AppBackground)
        .foregroundColor(Style.TextOnColoredBackground)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Style.AppColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    HStack {
                        Image(systemName: "water.waves")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.white)
                            .padding(.bottom)
                        Text("Love Waves")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                            .padding(.bottom)
                    }
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
