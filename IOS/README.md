# iOS CaloAI(FoodLens2) SDK Manual
## [ReleaseNote](ReleaseNote.md)
FoodLens functionality is available using the CaloAI(FoodLens2) SDK for iOS.

## Requirements

- iOS Version 13.0 or higher
- Swift Version 4.2 or higher


## 1. iOS project setting

### 1.1 CocoaPods
Please add below line into your `Podfile`:  

```
pod 'FoodLens2'
```

If `pod install` is not searched for `Foodlens2`:

```
pod install --repo-update
```


### 1.2 Swift Package Manager(SPM)
1. Select `File` -> `AddPackage` or `ProjectSetting` -> `AddPackage`  
<center><img src="Images/spm1.png" width="65%" height="65%"></center>

2. Search [https://bitbucket.org/doing-lab/ios_foodlens2sdk.git](https://bitbucket.org/doing-lab/ios_foodlens2sdk.git)
<center><img src="Images/spm2.png" width="70%" height="70%"></center>


## 2. Resources and info.plist setting

### 2.1 AppToken, CompanyToken setting
Add your AppToken, CompanyToken on info.plist 

<img src="./Images/infoplist_token.png">

### 2.2 Permission Setting
Please add below lines on your info.plist
- Privacy - Camera Usage Description
- Privacy - Photo Library Additions Usage Description
- Privacy - Photo Library Usage Description


## 3. Set address of independent CaloAI server
If you want to use independent CaloAI server instead of FoodLens2 Server.
Please add below informatiotn on your info.plist
 
```swift
//Please add only domain name or ip address instead of URL e.g) www.foodlens.com, 123.222.100.10
```
<img src="./Images/infoplist_addr.png">

## 4. How to use SDK
FoodLens API works based on the images that contain foods.

### 4.1 Get prediction result
1. Create FoodlensService
2. Call the predict method with an image.

#### 4.1.1 Library import
```swift
import FoodLens2
```

#### 4.1.2 Create FoodLens service
```swift
// create an instance
let foodlens = FoodLens()
```

#### 4.1.3 Predict images
There are several ways to use CaloAI. We provide three ways of concurrency.

### NOTE THAT, please use ORIGINAL IMAGE, if resolution of image is low, the recognition result can be impact.

##### 4.1.3.1 Closure
```swift
func predict(image: UIImage, completion: @escaping (Result<RecognitionResult, Error>) -> Void)
```

```swift
foodLens.predict(image: image) { result in
    switch result {
    case .success(let response):
        print(response)
    case .failure(let error):
        // Handle error.
        print(error.localizedDescription)
    }
}
```

##### 4.1.3.2 Combine
```swift
func predictPublisher(image: UIImage) -> AnyPublisher<RecognitionResult, Error>
```

```swift
foodlens.predictPublisher(image: image)
    .sink(receiveCompletion: { output in
        switch output {
        case .finished:
            print("Publisher finished")
        case .failure(let error):
            // Handle error.
            print(error.localizedDescription)
        }
    }, receiveValue: { response in
        print(response)
    })
    .store(in: &self.cancellable)
```

##### 4.1.3.2 async/await
```swift
func predict(image: UIImage) async -> Result<RecognitionResult, Error>
```

```swift
Task {
    let result = await foodLens.predict(image: image)
    switch result {
    case .success(let response):
        print(response)
    case .failure(let error):
        // Handle error.
        print(error.localizedDescription)
    }
}
```


### 4.2 CaloAI Options

#### 4.2.1 Auto image rotation based on EXIF orientation information
```swift
// You can use image rotation based on EXIF information, if you set true, food coordinate can be rotated based EXIF information.
// Default value is true
foodLens.setAutoRotate(true)
```


#### 4.2.2 Language setting
```swfit
// There are two options, English, Korea. Default is English
foodLens.setLanguage(.en)      // English(default)
foodLens.setLanguage(.ko)      // Korean
```


## 5. SDK detail specification
[API Documents](https://doinglab.github.io/foodlens2sdk/ios/index.html)

## 6. SDK Example
[Sample Code](https://github.com/doinglab/FoodLens2SDK/tree/main/IOS/SampleCode/)

## 7. JSON Format
[JSON Format](../JSON%20Format)

[JSON Sample](../JSON%20Sample)


## 8. License
FoodLens is available under the MIT license. See the LICENSE file for more info.
