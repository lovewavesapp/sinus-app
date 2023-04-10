//
//  PreAuthenticationView.swift
//  SinuS
//
//  Created by Loe Hendriks on 04/02/2023.
//

import SwiftUI

struct PreAuthenticationView: View {
    @State private var selection = Tab.feed

    private enum Tab: Hashable {
        case feed
        case login
    }

    init() {
        
    }

    var body: some View {
        VStack {
            TabView(selection: self.$selection) {
                Group {
                    FeedView(onlyFollowing: false)
                        .tabItem {
                            Label("Explore", systemImage: "network")
                        }
                        .tag(Tab.feed)
                    LoginView()
                        .tabItem {
                            Label("Login", systemImage: "person.badge.key.fill")
                        }
                        .tag(Tab.login)
                }
                .toolbar(.visible, for: .tabBar)
                .toolbarBackground(Style.AppColor, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Style.AppColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    HStack {
                        Image("Logo_cropped")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 30)
                            .foregroundColor(.white)
                            .padding(.bottom)
                    }
                }
            }
        }
    }
}

struct PreAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        PreAuthenticationView()
    }
}