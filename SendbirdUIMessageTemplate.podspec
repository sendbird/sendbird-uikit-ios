Pod::Spec.new do |s|
	s.name = "SendbirdUIMessageTemplate"
	s.version = "3.31.0"
	s.summary = "SendbirdUIMessageTemplate based on SendbirdChatSDK"
	s.description = "Sendbird UI MessageTemplate is a framework composed of basic Message Template UI components based on SendbirdChatSDK."
	s.homepage = "https://sendbird.com"
	s.documentation_url = 'https://sendbird.com/docs/uikit'
	s.license = { :type => 'Commercial', :file => 'SendbirdUIMessageTemplate/LICENSE.md' }
	s.authors = {
	"Tez" => "tez.park@sendbird.com",
	"Celine" => "celine.moon@senrbid.com",
	"Damon" => "damon.park@sendbird.com",
	"Jed" => "jed.gyeong@sendbird.com",
	"Young" => "young.hwang@sendbird.com",
	"Kai" => "kai.lee@sendbird.com"
  	}
	s.platform = :ios, "13.0"
	s.source = { :http => "https://github.com/sendbird/sendbird-uikit-ios/releases/download/#{s.version}/SendbirdUIMessageTemplate.zip", :sha1 => "ec499384b4fe2b0cc76c369db35fac85d86876dc" }
	s.ios.vendored_frameworks = 'SendbirdUIMessageTemplate/SendbirdUIMessageTemplate.xcframework'
	s.ios.frameworks = ["UIKit", "Foundation", "CoreData", "SendbirdChatSDK"]
	s.requires_arc = true
	s.dependency "SendbirdChatSDK", ">= 4.26.0"
	s.ios.library = "icucore"
end