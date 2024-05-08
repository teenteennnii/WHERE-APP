//
//  ChatLogView.swift
//  WHERE
//
//  Created by Jitpanu Nopwijit on 20/4/2567 BE.
//

import SwiftUI
import Firebase

struct FirebaseConstants {
    static let uid = "uid"
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "text"
    static let timestamp = "timestamp"
    static let profileImageUrl = "profileImageUrl"
    static let email = "email"
    static let messages = "messages"
    static let recentMessages = "recent_messages"
}

struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text:String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
}

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
        fetchMessages()
    }
    
    var firestoreListener: ListenerRegistration?
    
    func fetchMessages() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
        chatMessages.removeAll()
         firestoreListener = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for messages \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data))
//                        print("Appending message in chat log view")
                    }
                })
                
                DispatchQueue.main.async {
                    self.count += 1
                }
            }
    }
    
    func handleSend() {
//        print(chatText)
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document = FirebaseManager.shared.firestore
            .collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, FirebaseConstants.timestamp: Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in FireStore: \(error)"
            }
            
            print("Successfully saved current user sending message")
            
            self.persistRecentMessage()
            
            self.chatText = ""
            self.count += 1
        }
        
        let recipientMessageDocument = FirebaseManager.shared.firestore
            .collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        recipientMessageDocument.setData(messageData) { error in
            if let error = error {
                self.errorMessage = "Failed to save message in FireStore: \(error)"
            }
            
            print("Recipient saved message as well")
        }
    }
    
    private func persistRecentMessage() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        guard let toId = self.chatUser?.uid else { return }
        var chat = self.chatText
                
        let senderDocument = FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(uid)
                .collection("messages")
                .document(toId)

        let recipientDocument = FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(toId)
                .collection("messages")
                .document(uid)

        let timestamp = Timestamp()
                
        let senderData = [
                FirebaseConstants.timestamp: timestamp,
                FirebaseConstants.text: self.chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: chatUser?.profileImageUrl ?? "",
                FirebaseConstants.email: chatUser!.email
            ] as [String : Any]

        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }
            
            guard let userData = document?.data() else {
                print("User document not found")
                return
            }
            let image = userData[FirebaseConstants.profileImageUrl] as? String ?? ""
            
            let recipientData = [
                FirebaseConstants.timestamp: timestamp,
                FirebaseConstants.text: chat,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: image,
                FirebaseConstants.email: FirebaseManager.shared.auth.currentUser?.email ?? ""
            ] as [String : Any]
            
            senderDocument.setData(senderData) { error in
                if let error = error {
                    self.errorMessage = "Failed to save recent message: \(error)"
                    print(error)
                    return
                }
            }
            
            recipientDocument.setData(recipientData) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
        }
        
//        let document = FirebaseManager.shared.firestore
//            .collection("recent_messages")
//            .document(uid)
//            .collection("messages")
//            .document(toId)
//                
//        let data = [
//            FirebaseConstants.timestamp: Timestamp(),
//            FirebaseConstants.text: self.chatText,
//            FirebaseConstants.fromId: uid,
//            FirebaseConstants.toId: toId,
//            FirebaseConstants.profileImageUrl: chatUser?.profileImageUrl ?? "",
//            FirebaseConstants.email: chatUser!.email
//        ] as [String : Any]
//        
//        document.setData(data) { error in
//            if let error = error {
//                self.errorMessage = "Failed to save recent message: \(error)"
//                print(error)
//                return
//            }
//        }
//        
//        guard let currentUser = FirebaseManager.shared.currentUser else { return }
//                let recipientRecentMessageDictionary = [
//                    FirebaseConstants.timestamp: Timestamp(),
//                    FirebaseConstants.text: self.chatText,
//                    FirebaseConstants.fromId: uid,
//                    FirebaseConstants.toId: toId,
//                    FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
//                    FirebaseConstants.email: currentUser.email
//                ] as [String : Any]
//                
//                FirebaseManager.shared.firestore
//                    .collection(FirebaseConstants.recentMessages)
//                    .document(toId)
//                    .collection(FirebaseConstants.messages)
//                    .document(currentUser.uid)
//                    .setData(recipientRecentMessageDictionary) { error in
//                        if let error = error {
//                            print("Failed to save recipient recent message: \(error)")
//                            return
//                        }
//                    }
    }
    
    @Published var count = 0
}

struct ChatLogView: View {
        
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        self.vm = .init(chatUser: chatUser)
    }
    
    @ObservedObject var vm: ChatLogViewModel
        
    var body: some View {
        VStack {
            ZStack {
                messagesView
                Text(vm.errorMessage)
            }
            chatBottomBar
        }
        .navigationTitle(chatUser?.email ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            vm.firestoreListener?.remove()
        }
        }
    
    static let emptyScrollToString = "Empty"
    
    private var messagesView: some View {
        ScrollView {
            ScrollViewReader { ScrollViewProxy in
                VStack {
                    ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                    }
                    
                    HStack { Spacer() }
                        .id(Self.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        ScrollViewProxy.scrollTo(Self.emptyScrollToString, anchor: .bottom)
                    }
                }
            }
            
        }
        .background(Color(.secondarySystemBackground))
    }
    
    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                vm.handleSend()
            } label: {
                Text("Send")
                    .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue)
            .cornerRadius(4)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Type Here")
                .foregroundColor(.gray)
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct MessageView: View {
    
    let message: ChatMessage
    
    var body: some View {
        VStack {
            if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
                HStack {
                    Spacer()
                    HStack {
                        Text(message.text)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                }
            } else {
                HStack {
                    HStack {
                        Text(message.text)
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
//    NavigationView {
//        ChatLogView(chatUser: .init(data: ["uid": "DQ7ty8TJuYeI1JSXk0OvXG0EJ3A2", "email": "test7@gmail.com"]))
//    }
    MainMessagesView()
}
