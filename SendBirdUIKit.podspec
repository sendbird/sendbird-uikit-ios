Pod::Spec.new do |s|
	s.name = "SendBirdUIKit"
	s.version = "3.30.2"
	s.summary = "UIKit based on SendbirdChatSDK"
	s.description = "Sendbird UIKit is a framework composed of basic UI components based on SendbirdChatSDK."
	s.homepage = "https://sendbird.com"
	s.documentation_url = 'https://sendbird.com/docs/uikit'
	s.license = { :type => 'Commercial', :file => 'SendBirdUIKit/LICENSE.md' }
	s.authors = {
	"Tez" => "tez.park@sendbird.com",
	"Celine" => "celine.moon@senrbid.com",
	"Damon" => "damon.park@sendbird.com",
	"Jed" => "jed.gyeong@sendbird.com",
	"Minhyuk" => "minhyuk.kim@sendbird.com", 
	"Young" => "young.hwang@sendbird.com",
	"Kai" => "kai.lee@sendbird.com"
  	}
	s.platform = :ios, "13.0"
	s.source = { :http => "https://github.com/sendbird/sendbird-uikit-ios/releases/download/#{s.version}/SendBirdUIKit.zip", :sha1 => "208946e42c9dc9509edaf4ed66878a6f5fed5c62" }
	s.ios.vendored_frameworks = 'SendBirdUIKit/SendbirdUIKit.xcframework'
	s.ios.frameworks = ["UIKit", "Foundation", "CoreData", "SendbirdChatSDK"]
	s.requires_arc = true
	s.dependency "SendbirdChatSDK", ">= 4.26.0"
	s.dependency "SendbirdUIMessageTemplate", ">= 3.30.2"
	s.ios.library = "icucore"
end
