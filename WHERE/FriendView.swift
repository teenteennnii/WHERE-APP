//
//  FriendView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 14/4/2567 BE.
//

import SwiftUI

struct FriendView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.2")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    FriendView()
}
