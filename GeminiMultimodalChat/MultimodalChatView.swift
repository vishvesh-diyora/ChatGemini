//
//  MultimodalChatView.swift
//  GeminiMultimodalChat
//
//  Created by Diyora Vishvesh
//

import SwiftUI
import PhotosUI

struct MultimodalChatView: View {
    @State private var textInput = ""
    @State private var chatService = ChatService()
    @State private var photoPickerItems = [PhotosPickerItem]()
    @State private var selectedPhotoData = [Data]()
    
    var body: some View {
        VStack {
            // MARK: Logo
            Image("app-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
            
            // MARK: Chat message list
            ScrollViewReader(content: { proxy in
                if chatService.messages.count > 0  {
                    ScrollView {
                        ForEach(chatService.messages) { chatMessage in
                            // MARK: Chat message view
                            chatMessageView(chatMessage)
                        }
                    } 
                    .onChange(of: chatService.messages) {
                        guard let recentMessage = chatService.messages.last else { return }
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo(recentMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                } else {
                    VStack {
                        Spacer()
                        Text("Ask me anything with images.....")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        Spacer()
                    }
                }
            })
            
            // MARK: Image preview
            if selectedPhotoData.count > 0 {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 10, content: {
                        ForEach(0..<selectedPhotoData.count, id: \.self) { index in
                            Image(uiImage: UIImage(data: selectedPhotoData[index])!)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                    })
                }
                .frame(height: 50)
            }
            
            // MARK: Input fields
            ZStack {
                Color.white.frame(height: 60).overlay(RoundedRectangle(cornerRadius: 30)
                    .stroke(LinearGradient(colors: [.green,.blue], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2))
                HStack {
                    PhotosPicker(selection: $photoPickerItems, maxSelectionCount: 3, matching: .images) {
                        Image("addImageicon")
                    }
                    .onChange(of: photoPickerItems) {
                        Task {
                            selectedPhotoData.removeAll()
                            for item in photoPickerItems {
                                if let imageData = try await item.loadTransferable(type: Data.self) {
                                    selectedPhotoData.append(imageData)
                                }
                            }
                        }
                    }
                    
                    TextField("", text: $textInput, prompt: Text("Enter a message...")
                        .foregroundColor(.gray))
                        .font(.subheadline)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.black)
                        .background(.clear)
                        .frame(height: 40)
                    
                    
                    if chatService.loadingResponse {
                        // MARK: Loading indicator
                        ProgressView()
                            .tint(Color.black)
                            .frame(width: 40, height: 40)
                    } else {
                        // MARK: Send button
                        Button(action: sendMessage, label: {
                            Image("sendicon")
                        })
                        .frame(width: 40, height: 40)
                    }
                }.padding(.all,10)
            }.cornerRadius(30).padding(.bottom, 10)
        }
        .foregroundStyle(.white)
        .padding([.leading,.trailing], 10)
        .background {
            // MARK: Background
            ZStack {
                Color.white
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: Chat message view
    @ViewBuilder private func chatMessageView(_ message: ChatMessage) -> some View {
        // MARK: Chat image dislay
        if let images = message.images, images.isEmpty == false {
            ChatBubble(direction: message.role == .model ? .left : .right) {
                VStack(alignment: .leading,content: {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0, content: {
                            ForEach(0..<images.count, id: \.self) { index in
                                Image(uiImage: UIImage(data: images[index])!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
                                    .containerRelativeFrame(.horizontal)
                            }
                        })
                        .scrollTargetLayout()
                    }
                    .background(.gray)
                    .frame(height: 150)
                    if message.message.isEmpty {
                        ProgressView()
                            .tint(Color.white)
                            .frame(width: 40)
                            .padding([.leading,.trailing], 20)
                            .padding([.top,.bottom], 10)
                            .foregroundStyle(.white)
                            .background(message.role == .model ? Color.blue : Color.green)
                    } else {
                        Text(message.message)
                            .font(.subheadline)
                            .padding([.leading,.trailing], 20)
                            .padding([.top,.bottom], 10)
                            .foregroundStyle(.white)
                            .background(message.role == .model ? Color.blue : Color.green)
                    }
                }).background(message.role == .model ? Color.blue : Color.green)
            }
        } else {
            ChatBubble(direction: message.role == .model ? .left : .right) {
                if message.message.isEmpty {
                    ProgressView()
                        .tint(Color.white)
                        .frame(width: 40)
                        .padding([.leading,.trailing], 20)
                        .padding([.top,.bottom], 10)
                        .foregroundStyle(.white)
                        .background(message.role == .model ? Color.blue : Color.green)
                } else {
                    Text(message.message)
                        .font(.subheadline)
                        .padding([.leading,.trailing], 20)
                        .padding([.top,.bottom], 10)
                        .foregroundStyle(.white)
                        .background(message.role == .model ? Color.blue : Color.green)
                }
            }
        }
    }
    
    // MARK: Fetch response
    private func sendMessage() {
        if !textInput.isEmpty {
            Task {
                await chatService.sendMessage(message: textInput, imageData: selectedPhotoData)
                selectedPhotoData.removeAll()
                textInput = ""
            }
        }
    }
}

#Preview {
    MultimodalChatView()
}
