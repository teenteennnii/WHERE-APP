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
            NavigationView()
                .tabItem {
                    Label("Navigation", systemImage: "location")
                }
            FriendView()
                .tabItem {
                    Label("Friend", systemImage: "person.2")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}

#Preview {
    MainView()
}
