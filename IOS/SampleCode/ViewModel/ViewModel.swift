//
//  ViewModel.swift
//  ExampleFoodLens
//
//  Created by 박병호 on 2023/01/11.
//

import UIKit
import FoodLens2
import Combine

enum SheetContentMode: Identifiable {
    case camera
    case gallery
    
    var id: Int {
        hashValue
    }
}

class ViewModel: ObservableObject {
    @Published var selectedImage: UIImage = .init()
    @Published var predictResponses: RecognitionResult = .init()

    @Published var isLoading: Bool = false
    
    @Published var selectedLanguage: LanguageConfig = .en
    @Published var isAutoRotate: Bool = true
    
    @Published var sheetContentMode: SheetContentMode?
    
    @Published var isShowAlert: Bool = false
    @Published var alertMessage: String = ""
    
    var isImageRotate: Bool = true
    
    let userId: String = "Doinglab_iOS"
    let foodlens: FoodLens = .init()
    
    private var cancellable: Set<AnyCancellable> = .init()

    init() {
        setupImageBinding()
        setLanguage()
        setAutoRotate()
    }
    
    // MARK: - Predict Method
    func asyncPredict(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        
        self.startLoading()
        Task {
            let result = await foodlens.predict(image: image, userId: self.userId)
            switch result {
            case .success(let response):
                self.stopLoading()
                if response.foodInfoList.isEmpty {
                    self.showAelrt(message: "No predict results")
                    return
                }
                DispatchQueue.main.async {
                    self.predictResponses = response
                }
            case .failure(let error):
                self.stopLoading()
                self.showAelrt(message: error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
    
    func combinePredeict(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        
        self.startLoading()
        foodlens.predictPublisher(image: image, userId: self.userId)
            .sink(receiveCompletion: { output in
                switch output {
                case .finished:
                    print("Publisher finished")
                case .failure(let error):
                    self.stopLoading()
                    self.showAelrt(message: error.localizedDescription)
                    print(error.localizedDescription)
                }
            }, receiveValue: { response in
                self.stopLoading()
                if response.foodInfoList.isEmpty {
                    self.showAelrt(message: "No predict results")
                    return
                }
                DispatchQueue.main.async {
                    self.predictResponses = response
                }
            })
            .store(in: &self.cancellable)
    }
    
    func closurePredict(_ image: UIImage?) {
        guard let image = image else {
            return
        }
        
        self.startLoading()
        foodlens.predict(image: image, userId: self.userId) { result in
            switch result {
            case .success(let response):
                self.stopLoading()
                if response.foodInfoList.isEmpty {
                    self.showAelrt(message: "No predict results")
                    return
                }
                DispatchQueue.main.async {
                    self.predictResponses = response
                }
            case .failure(let error):
                self.stopLoading()
                self.showAelrt(message: error.localizedDescription)
                print(error.localizedDescription)
            }
        }
    }
    
    private func showAelrt(message: String) {
        DispatchQueue.main.async {
            self.isShowAlert = true
            self.alertMessage = message
        }
    }
    
    // MARK: - Publisher
    private var selectedImagePublisher: AnyPublisher<UIImage, Never> {
        self.$selectedImage
            .dropFirst()
            .eraseToAnyPublisher()
    }
    
    private func setupImageBinding() {
        self.selectedImagePublisher
            .sink { image in
                self.predictResponses.foodInfoList.removeAll()
                self.asyncPredict(image)
//                self.combinePredeict(image)
//                self.closurePredict(image)
                self.isImageRotate = self.isAutoRotate
            }
            .store(in: &self.cancellable)
    }
    
    private var selectedLanguagePublisher: AnyPublisher<LanguageConfig, Never> {
        self.$selectedLanguage
            .dropFirst()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private func setLanguage() {
        self.selectedLanguagePublisher
            .sink { language in
                self.foodlens.setLanguage(language)
            }
            .store(in: &self.cancellable)
    }
    
    private var isAutoRotatePublisher: AnyPublisher<Bool, Never> {
        self.$isAutoRotate
            .dropFirst()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private func setAutoRotate() {
        self.isAutoRotatePublisher
            .sink { isAutoRotate in
                self.foodlens.setAutoRotate(isAutoRotate)
            }
            .store(in: &self.cancellable)
    }
    
    private func startLoading() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }
    
    private func stopLoading() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}
