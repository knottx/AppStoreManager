Pod::Spec.new do |spec|

  spec.name         = "AppStoreManager"
  spec.version      = "0.0.1"
  spec.summary      = "AppStoreManager, An AppStore version checking in Swift. "
  spec.homepage     = "https://visarut-tippun.firebaseapp.com/"
  spec.license      = "MIT"
  spec.author       = { "Visarut Tippun (Knot)" => "knotto.vt@gmail.com" }
  spec.source       = { :git => "https://github.com/knottovt/AppStoreManager.git", :tag => "#{spec.version}" }
  
  s.swift_version   = '5.0'
  spec.ios.deployment_target = '11.0'
  spec.source_files  = "AppStoreManager", "AppStoreManager/**/*.{h,swift}"
  spec.exclude_files = "AppStoreManager/**/*.plist"

  spec.dependency "RxSwift"
  spec.dependency "RxCocoa"
  spec.dependency "RxAlamofire"
  spec.dependency "Alamofire"

end
