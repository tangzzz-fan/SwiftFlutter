//
//  UserProfileView.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import SwiftUI

struct UserProfileView: View {
    var body: some View {
        VStack {
            Text("User Profile")
                .font(.largeTitle)
                .padding()

            // 这里将显示用户信息
            Text("User details would be displayed here")
                .padding()

            Spacer()
        }
        .navigationTitle("Profile")
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
