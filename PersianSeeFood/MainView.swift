//
//  ContentView.swift
//  PersianSeeFood
//
//  Created by armin on 4/3/21.
//

import SwiftUI

struct MainView: View {
    
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var analyzeResult: String = "Tap on the camera to add image"
    
    var body: some View {
        VStack {
            HStack {
                Image("spoon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical)
                    .frame(maxHeight: 180)
                Button(action: showImagePicker) {
                    ZStack {
                        Image("dishBackground")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                        /// Plate Background
                        Circle()
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.5), radius: 10, x: -5, y: -5)
                            .padding(.all, 35)
                        
                        /// Food image
                        if image != nil {
                            image?
                                .resizable()
                                .scaledToFill()
                                .clipShape(Circle())
                                .padding(.all, 50)
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 38))
                                .opacity(0.5)
                        }
                        
                        /// Plate shadows
                        Circle()
                            .stroke(Color(red: 236/255, green: 234/255, blue: 235/255),lineWidth: 4)
                            .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),radius: 3, x: 2, y: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(color: Color.white, radius: 2, x: -2, y: -2)
                            .clipShape(Circle())
                            .padding(.all, 35)
                        
                        Circle()
                            .stroke(Color(red: 236/255, green: 234/255, blue: 235/255),lineWidth: 4)
                            .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),radius: 3, x: 2, y: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(color: Color.white, radius: 2, x: -2, y: -2)
                            .clipShape(Circle())
                            .padding(.all, 50)
                    }
                }
                Image("fork")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical)
                    .frame(maxHeight: 180)
            }
            .frame(maxHeight: 250)
            Text(analyzeResult)
                .padding()
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: self.$inputImage)
        }
    }
    
    func showImagePicker() {
        self.showingImagePicker = true
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
