//
//  ForgotPasswordView.swift
//  SinuS
//
//  Created by Patrick van Broeckhuijsen on 12/01/2023.
//

import SwiftUI

struct ForgotPasswordView: View {
    let manager = DataManager()

    @State private var email: String = UserDefaults.standard.string(forKey: "email") ?? ""
    @State private var showAlert = false
    @State private var nextView: Bool? = false

    var body: some View {
        VStack {
            // Email
            HStack {
                Text("Email")
                Spacer()
                TextField("", text: self.$email)
                    .disableAutocorrection(true)
                    .border(Color.white, width: 0.5)
                    .frame(width: 220)
            }.padding(.horizontal).padding(.top)

            NavigationLink(destination: ClickResetPasswordLinkView(), tag: true, selection: self.$nextView) { EmptyView() }

            Button("Submit") {
                let authenticationResult = self.manager.forgotPassword(email: self.email)

                if authenticationResult == nil {
                    self.showAlert.toggle()
                } else {
                    UserDefaults.standard.set(self.email, forKey: "forgotPasswordEmail")
                    self.nextView = true
                }

            }
            .alert(isPresented: $showAlert) {
                return Alert(title: Text("Error"), message: Text("Failed to request forgot password link for \(self.email)"), dismissButton: .default(Text("OK")))
            }
            .padding()
        }
        .background(Style.AppColor)
        .cornerRadius(5)
        .shadow(radius: 5)
        .padding()
        .foregroundColor(.white)
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

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
