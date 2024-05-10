//
//  ContentView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 18/3/2567 BE.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var vm = MainMessagesViewModel()
    var body: some View {
        MainMessagesView()
//        TabView{
//            MainMessagesView()
//                .tabItem {
//                    Label("Messages", systemImage: "person.2")
//                }
//            MapView()
//                .tabItem {
//                    Label("Map", systemImage: "map")
//                }
////            AccountView()
////                .tabItem {
////                    Label("Profile", systemImage: "person")
////                }
//        }
    }
}

#Preview {
    MainView()
//        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}
