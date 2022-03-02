Pod::Spec.new do |s|
	s.name         = "SendBirdUIKit"
	s.version      = "2.1.13"
	s.summary      = "UIKit based on SendBirdSDK"
	s.description  = "SendBird UIKit is a framework composed of basic UI components based on SendBirdSDK."
	s.homepage     = "https://sendbird.com"
	s.documentation_url = 'https://sendbird.com/docs/uikit'
	s.license      = "Commercial"
	s.authors      = {
	"Jaesung Lee" => "jaesung.lee@sendbird.com",
	"Tez" => "tez.park@sendbird.com"
  	}
	s.platform     = :ios, "11.0"
	s.source = { :git => "https://github.com/MojoSport/sendbird-uikit-ios.git", :tag => "v#{s.version}" }
	s.ios.frameworks = ["UIKit", "Foundation", "CoreData", "SendBirdSDK"]
  
  s.ios.source_files = 'Sources/**/*.{h,m,swift}'
  
 	s.ios.resources = ['Sources/Resource/*.*', 'Sources/**/*.xib']
  
	s.requires_arc = true
	s.dependency "SendBirdSDK", "~>3.0.226"
	s.ios.library = "icucore"
  s.pod_target_xcconfig = { 'PRODUCT_BUNDLE_IDENTIFIER': 'com.sendbird.uikit' }
  
end

