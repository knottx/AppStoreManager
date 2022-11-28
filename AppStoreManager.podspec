Pod::Spec.new do |spec|

  spec.name         = "AppStoreManager"
  spec.version      = "1.3.4"
  spec.summary      = "A new version checking framework in Swift."

  spec.homepage     = "https://knottx.github.io"
  spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author       = { "Visarut Tippun" => "knotto.vt@gmail.com" }
  spec.source       = { :git => "https://github.com/knottx/AppStoreManager.git", :tag => "#{spec.version}" }
  
  spec.swift_version   = "5.1"
  spec.ios.deployment_target = "10.0"
  spec.source_files  = "Sources/AppStoreManager/**/*.swift"
  spec.requires_arc  = true

end
