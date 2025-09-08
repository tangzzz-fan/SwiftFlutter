//
//  SettingsView.swift
//  SwiftFlutter
//
//  Created by 小苹果 on 2025/3/15.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()

            // 这里将显示设置选项
            Text("Settings options would be displayed here")
                .padding()

            Spacer()
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
