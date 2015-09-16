Pod::Spec.new do |s|
  s.name             = "fosrest"
  s.module_name      = "FOSRest"
  s.version          = "0.3.2"
  s.summary          = "A group of classes for connecting CoreData to REST services."
  s.homepage         = "https://github.com/foscomputerservices/fosrest"
  s.license          = 'MIT'
  s.author           = { "David Hunt" => "fosrest@foscomputerservices.com" }
  s.source           = { :git => "https://github.com/foscomputerservices/fosrest.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/foscompsvcs'

  s.platform     = :ios, '7.1'
  s.requires_arc = true

# TODO: Restore lm,ym to this list when CocoaPods issue
#      (https://github.com/CocoaPods/CocoaPods/issues/3127) is resolved.
#  s.source_files = 'Pod/Classes/**/*.{h,m,lm,ym}'
  s.source_files = 'Pod/Classes/**/*.{h,m}'

  s.public_header_files = 'Pod/Classes/Public/**/*.h'
  s.private_header_files = 'Pod/Classes/Private/**/*.h'

  s.resources = 'Pod/Assets/*.{xcdatamodeld,xcdatamodel,adaptermap}'
  s.preserve_paths = 'Pod/Classes/Private/*'

  s.frameworks = 'Foundation', 'CoreData'
end
