Pod::Spec.new do |s|
  s.name             = "FOSFoundation"
  s.module_name      = "FOSFoundation"
  s.version          = "0.1.0"
  s.summary          = "A group of classes for connecting CoreData to REST services."
  s.homepage         = "http://fosmain.foscomputerservices.com:7990/projects/FF"
  s.license          = 'Private'
  s.author           = { "David Hunt" => "david@foscomputerservices.com" }
  s.source           = { :git => "ssh://git@fosmain.foscomputerservices.com:7999/ff/fosfoundation.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/foscompsvcs'

  s.platform     = :ios, '8.1'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*.{h,m,lm,ym}'

  s.public_header_files = 'Pod/Classes/Public/**/*.h'
  s.private_header_files = 'Pod/Classes/Private/**/*.h'

  s.resources = 'Pod/Assets/*.{xcdatamodeld,xcdatamodel,adaptermap}'
  s.preserve_paths = 'Pod/Classes/Private/*'

  s.frameworks = 'Foundation', 'CoreData'
end
