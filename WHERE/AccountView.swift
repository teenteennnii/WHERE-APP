//
//  ProfileView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 14/4/2567 BE.
//

import SwiftUI

struct AccountView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    
    @State private var shouldShowImagePicker = false
    
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
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width:128, height:128)
                                        .scaledToFill()
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color(.label), lineWidth: 3))
                            
                        }
                    }
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .padding(12)
                        .background(Color(.systemGray5))
                        
                    SecureField("Password", text: $password)
                        .padding(12)
                        .background(Color(.systemGray5))
                    
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
                    Text(self.loginStatusMessage)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            .navigationTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(UIColor(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil, content: {
            ImagePicker(image: $image)
        })
    }
    
    @State var image: UIImage?
    
    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"
            
            self.didCompleteLoginProcess()
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        
        if self.image == nil {
            self.loginStatusMessage = "You must select an profile image"
            return
        }
        
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persitImageToStorage()
        }
    }
    
    private func persitImageToStorage() {
        _ = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
            else { return }
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil, completion: {
            metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL(completion: {
                url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve dowloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                
                guard let url = url else {return }
                storeUserInformation(imageProfileUrl: url)
            })
        })
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            return
        }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) {
                err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                
                self.didCompleteLoginProcess()
            }
    }
}

#Preview {
    AccountView(didCompleteLoginProcess: {})
//        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
}
