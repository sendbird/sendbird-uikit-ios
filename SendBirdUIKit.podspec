Pod::Spec.new do |s|
	s.name = "SendBirdUIKit"
	s.version = "3.24.4"
	s.summary = "UIKit based on SendbirdChatSDK"
	s.description = "Sendbird UIKit is a framework composed of basic UI components based on SendbirdChatSDK."
	s.homepage = "https://sendbird.com"
	s.documentation_url = 'https://sendbird.com/docs/uikit'
	s.license = "Commercial"
	s.authors = {
	"Tez" => "tez.park@sendbird.com",
	"Celine" => "celine.moon@senrbid.com",
	"Damon" => "damon.park@sendbird.com",
	"Jed" => "jed.gyeong@sendbird.com",
	"Minhyuk" => "minhyuk.kim@sendbird.com", 
	"Young" => "young.hwang@sendbird.com",
	"Kai" => "kai.lee@sendbird.com"
  	}
	s.platform = :ios, "12.0"
	s.source = { :git => "https://github.com/sendbird/sendbird-uikit-ios.git", :tag => "#{s.version}" }
	s.ios.vendored_frameworks = 'Framework/SendbirdUIKit.xcframework'
	s.ios.frameworks = ["UIKit", "Foundation", "CoreData", "SendbirdChatSDK"]
	s.requires_arc = true
	s.dependency "SendbirdChatSDK", ">= 4.19.9"
	s.ios.library = "icucore"
end
