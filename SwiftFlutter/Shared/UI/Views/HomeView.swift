//
//  HomeView.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to SwiftFlutter Demo")
                    .font(.largeTitle)
                    .padding()

                Text(
                    "This demo showcases a Clean Architecture implementation using Swinject, MVVM-C, POP, and Combine."
                )
                .padding()

                NavigationLink("User Profile") {
                    UserProfileView()
                }

                NavigationLink("Settings") {
                    SettingsView()
                }

                Button("Open Flutter Module") {
                    // 这里将调用Flutter模块
                    print("Opening Flutter Module")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
