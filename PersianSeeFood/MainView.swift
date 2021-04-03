//
//  ContentView.swift
//  PersianSeeFood
//
//  Created by armin on 4/3/21.
//

import SwiftUI
import CoreML

struct MainView: View {
    
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    @State private var analyzeResult: String = "Tap on the camera to add image"
    @State private var otherResult: String = ""
    
    let model: PersianFood = {
        do {
            let config = MLModelConfiguration()
            return try PersianFood(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create PersoanFood model")
        }
    }()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
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
                Spacer()
            }
            .frame(maxHeight: 250)
            
            /// ML Image Classification result
            Text(analyzeResult)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Color.accentColor)
                .multilineTextAlignment(.center)
                .padding()
            
            /// ML other results
            Text(otherResult)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
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
        guard let inputImage = inputImage, let bufferImage = inputImage.toCVPixelBuffer() else { return }
        image = Image(uiImage: inputImage)
        let output = try? self.model.prediction(image: bufferImage)
        
        if let output = output {
            /// Food name result
            analyzeResult = output.classLabel
            
            /// Food name other results
            let predictions = output.classLabelProbs.sorted { $0.1 > $1.1}
            let prediction = predictions.compactMap { (key, value) in
                return value * 100 > 10 ? "\(key) = \(String(format: "%.2f",value * 100))%" : nil
            }.joined(separator: "\n")
            otherResult = prediction
        } else {
            analyzeResult = "Failed to recognize the photo"
            otherResult = ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
