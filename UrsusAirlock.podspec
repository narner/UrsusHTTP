Pod::Spec.new do |s|
  s.name = "UrsusAirlock"
  s.version = "1.4.0"
  s.summary = "An Urbit HTTP/`%eyre` client for iOS/macOS."
  s.homepage = "https://github.com/dclelland/UrsusAirlock"
  s.license = { type: 'MIT' }
  s.author = { "Daniel Clelland" => "daniel.clelland@gmail.com" }
  s.source = { git: "https://github.com/dclelland/UrsusAirlock.git", tag: "1.4.0" }
  s.swift_versions = ['5.1', '5.2']
  
  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15'
  
  s.source_files = 'Ursus/**/*.swift'
  
  s.dependency 'Alamofire', '~> 5.2'
  s.dependency 'UrsusAtom', '~> 1.0'
  
  s.subspec 'EventSource' do |ss|
    ss.source_files = 'Ursus Event Source/**/*.swift'
  end
end
