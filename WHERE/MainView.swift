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
//            AccountView()
//                .tabItem {
//                    Label("Profile", systemImage: "person")
//                }
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil, content: {
            AccountView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        })
    }
}

#Preview {
    MainView()
//        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}
