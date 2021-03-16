Pod::Spec.new do |spec|

  spec.name         = "AppStoreManager"
  spec.version      = "1.1.0"
  spec.summary      = "A new version checking framework in Swift."

  spec.homepage     = "https://knottovt.github.io"
  spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.author       = { "Visarut Tippun" => "knotto.vt@gmail.com" }
  spec.source       = { :git => "https://github.com/knottovt/AppStoreManager.git", :tag => "#{spec.version}" }
  
  spec.swift_version   = "5.1"
  spec.ios.deployment_target = "10.0"
  spec.source_files  = "AppStoreManager/**/*.swift"
  spec.requires_arc  = true

end
