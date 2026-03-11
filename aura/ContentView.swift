//
//  ContentView.swift
//  aura
//
//  Created by Sukhman Singh on 3/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showMain = false

    var body: some View {
        Group {
            if showMain {
                MainTabView()
                    .transition(.opacity)
            } else {
                LaunchScreenView(showMain: $showMain)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showMain)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
