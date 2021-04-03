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
    
    @State private var imagePredictions = [ImagePredictions]()
    
    @State private var allowAnimations : Bool = false
    
    let model: PersianFood = {
        do {
            let config = MLModelConfiguration()
            return try PersianFood(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create PersianFood model")
        }
    }()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                plateImageView
                    .frame(maxHeight: 250)
                    .padding(.vertical)
                
                if imagePredictions.isEmpty {
                    Text("Tap on the camera to add image")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.accentColor)
                        .multilineTextAlignment(.center)
                } else {
                    predictionsListView
                }
                
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .animation(self.allowAnimations ? .default : nil)
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.allowAnimations = true
                }
            }
        }
    }
    
    var plateImageView: some View {
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
    }
    
    var predictionsListView: some View {
        List {
            ForEach(0 ..< imagePredictions.count, id: \.self) { index in
                VStack(alignment: index == 0 ? .center : .leading) {
                    Text(imagePredictions[index].category)
                        .font(index == 0 ? .title2 : .title3)
                        .fontWeight(index == 0 ? .semibold : .regular)
                        .foregroundColor(index == 0 ? Color("IdentifierColor") : .primary)
                        .multilineTextAlignment(index == 0 ? .center : .leading)
                        .frame(maxWidth: .infinity, alignment: index == 0 ? .center : .leading)
                    
                    Text("\(imagePredictions[index].confidence)% confidence")
                        .font(index == 0 ? .title3 : .body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(index == 0 ? .center : .leading)
                        .frame(maxWidth: .infinity, alignment: index == 0 ? .center : .leading)
                }
                
                .padding()
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    func showImagePicker() {
        self.showingImagePicker = true
    }
    
    func loadImage() {
        guard let inputImage = inputImage, let bufferImage = inputImage.toCVPixelBuffer() else { return }
        image = Image(uiImage: inputImage)
        let output = try? self.model.prediction(image: bufferImage)
        
        /// Waiting for image to load because of animation of list and moving dishImage to top
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let output = output {
                imagePredictions.removeAll()
                let predictions = output.classLabelProbs.sorted { $0.1 > $1.1}
                imagePredictions = predictions.compactMap { (key, value) in
                    /// Adding predictions which are higher than 10% confidence
                    return value * 100 > 10 ? ImagePredictions(category: key, confidence: (String(format: "%.2f",value * 100))) : nil
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
