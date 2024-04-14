//
//  ProfileView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 14/4/2567 BE.
//

import SwiftUI

struct ProfileView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                
                VStack {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    if !isLoginMode {
                        Button {
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
                        }
                    }
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .padding(12)
                        .background(.white)
                        
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(.white)
                    
                    Button {
                        handleAction()
                    } label: {
                        HStack{
                            Spacer()
                            Text(isLoginMode ? "Login" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(Color.blue)
                    }
                }
                .padding()
            }
            
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(UIColor(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
    }
    
    private func handleAction() {
        if isLoginMode {
            print("Login to fire base")
        } else {
            print("Register new account to firebase")
        }
    }
}

#Preview {
    ProfileView()
}
