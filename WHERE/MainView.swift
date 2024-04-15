//
//  ContentView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 18/3/2567 BE.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            NavigateView()
                .tabItem {
                    Label("Navigation", systemImage: "location")
                }
            MainMessagesView()
                .tabItem {
                    Label("Messages", systemImage: "person.2")
                }
            AccountView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainView()
}
