Pod::Spec.new do |spec|

  spec.name         = "AppStoreManager"
  spec.version      = "0.0.1"
  spec.summary      = "A short description of AppStoreManager."
  spec.homepage     = "http://EXAMPLE/AppStoreManager"
  spec.license      = "MIT (example)"
  spec.author       = { "Visarut Tippun (Knot)" => "knotto.vt@gmail.com" }
  spec.source       = { :git => "https://github.com/knottovt/AppStoreManager.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = '11.0'
  spec.source_files  = "AppStoreManager", "AppStoreManager/**/*.{h,m}"
  spec.exclude_files = "AppStoreManager/**/*.plist"

  spec.dependency "RxSwift"
  spec.dependency "RxCocoa"
  spec.dependency "RxAlamofire"
  spec.dependency "Alamofire"

end
