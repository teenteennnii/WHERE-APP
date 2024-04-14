//
//  NavigationView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 14/4/2567 BE.
//

import SwiftUI

struct NavigateView: View {
    var body: some View {
        VStack {
            Image(systemName: "location")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    NavigateView()
}
