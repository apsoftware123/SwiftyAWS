# SwiftyAWS
A swifty wrapper around the AWS S3 framework that will make storing files (images, videos, etc) easier.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Support](#support)
- [Contributing](#contributing)

## Installation

Using Cocoapods:

```ruby
pod 'SwiftyAWS', :git => 'https://github.com/apeguero24/SwiftyAWS.git'
```

## Usage

SwiftyAWS is a simple to use wrapper library around the iOS native AWS SDK. One of the main issues found when using the AWS SDK out of the box is the obvious divergence from modern swift best practices and conventions.

### Upload

***Singleton Usage:***

```swift
SwiftyAWS.main.upload(image: image, type: .png, name: .efficient, permission: .publicReadWrite) { (path, error) in
    if error != nil {
        print(error!)
        return
    }
}
```
***UIImage Extension Usage:***

```swift
let image = UIImage(named: "lion.jpg")
image?.s3.upload(type: .png, name: .efficient, permission: .publicReadWrite, completionHandler: { (path, error) in
    if error != nil {
        print(error!)
        return
    }
})
```

### Download

***Singleton Usage:***

```swift
SwiftyAWS.main.download(imageName: "d133eb68a94328d5f56febe461663b8b642970e5c38fb71385fc88118ce3efd9", imageExtension: .png) { (image, path, error) in
    if error != nil {
        print(error!)
        return image
    }
}
```

***UIImage Extension Usage:***

```swift
"d133eb68a94328d5f56febe461663b8b642970e5c38fb71385fc88118ce3efd9".s3.download(imageExtension: .png) { (image, path, error) in
  if error != nil {
    print(error!)
    return image
  }
}
```

***File Types:***
At the moment SwiftyAWS only supports PNGs and JPEGs, adding more file formats in the near future (pull requests would be appreciated):
```swift
.png
.jpeg

```

***File Naming:***
When using SwiftyAWS you can choose between `.custom(String)` and `.efficient` when naming your files. When using `.efficient` the name of the file becomes the `SHA256` of the base64 encoded data. What does that mean? It means that if a file has an identical hash, then it will be same file therefore it shouldn't be stored as a duplicate in your bucket.
```swift
.custom("lion") // ex: lion.png
.efficient // ex: FC59487712BBE89B488847B77B5744FB6B815B8FC65EF2AB18149958EDB61464.png
```

## Support

Please [open an issue](https://github.com/apeguero24/SwiftyAWS/issues/new) for support.

## Contributing

Please contribute using [Github Flow](https://guides.github.com/introduction/flow/). Create a branch, add commits, and [open a pull request](https://github.com/apeguero24/SwiftyAWS/compare/).
