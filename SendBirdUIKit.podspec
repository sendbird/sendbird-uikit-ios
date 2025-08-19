Pod::Spec.new do |s|
	s.name = "SendBirdUIKit"
	s.version = "3.32.2"
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
	s.source = { :http => "https://github.com/sendbird/sendbird-uikit-ios/releases/download/#{s.version}/SendBirdUIKit.zip", :sha1 => "ba9646278f198e8ae13e50db903431ba595a313f" }
	s.ios.vendored_frameworks = 'SendBirdUIKit/SendbirdUIKit.xcframework'
	s.ios.frameworks = ["UIKit", "Foundation", "CoreData", "SendbirdChatSDK"]
	s.requires_arc = true
	s.dependency "SendbirdChatSDK", ">= 4.29.2"
	s.dependency "SendbirdUIMessageTemplate", ">= 3.32.2"
	s.ios.library = "icucore"
end
