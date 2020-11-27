Pod::Spec.new do |s|
  s.name = "UrsusHTTP"
  s.version = "1.10.1"
  s.summary = "An Urbit HTTP/`%eyre` client for iOS/macOS."
  s.homepage = "https://github.com/dclelland/UrsusHTTP"
  s.license = { type: 'MIT' }
  s.author = { "Daniel Clelland" => "daniel.clelland@gmail.com" }
  s.source = { git: "https://github.com/dclelland/UrsusHTTP.git", tag: "1.10.1" }
  s.swift_versions = ['5.1', '5.2']
  
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  
  s.source_files = 'Sources/UrsusHTTP/**/*.swift'
  
  s.dependency 'Alamofire', '~> 5.2'
  s.dependency 'AlamofireEventSource', '~> 1.2'
  s.dependency 'UrsusAtom', '~> 1.2'
end
