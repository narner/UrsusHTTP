Pod::Spec.new do |s|
  s.name                    = "Ursus"
  s.version                 = "0.2.1"
  s.summary                 = "An Urbit client for iOS in Swift."
  s.homepage                = "https://github.com/dclelland/Ursus"
  s.license                 = { :type => 'MIT' }
  s.author                  = { "Daniel Clelland" => "daniel.clelland@gmail.com" }
  s.source                  = { :git => "https://github.com/dclelland/Ursus.git", :tag => "0.2.1" }
  s.platform                = :ios, '9.0'
  s.ios.deployment_target   = '9.0'
  s.ios.source_files        = 'Ursus/**/*.swift'
  s.requires_arc            = true
  s.dependency 'Alamofire', '~> 3.4'
  s.dependency 'AlamofireObjectMapper', '~> 3.0'
  s.dependency 'ObjectMapper', '~> 1.4'
  s.dependency 'PromiseKit', '~> 3.4'
end
