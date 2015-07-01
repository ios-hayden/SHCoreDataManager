Pod::Spec.new do |s|

  s.name         = "SHCoreDataManager"
  s.version      = "1.0.0"
  s.summary      = "A lightweight and thread-safe core data framework"

  s.description  = <<-DESC
                   A lightweight and thread-safe core data framework.
                   DESC

  s.homepage     = "https://github.com/superhayden/SHCoreDataManager"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"


  s.license      = "MIT"
  s.author             = { "SuperHayden" => "admin@yardlan.com" }
  
  s.platform     = :ios, "5.0"

  s.source       = { :git => "ssh://gitolite@wccios.alpha.wochacha.com:65522/SHCoreDataManager.git", :tag => "1.0.0" }


  s.source_files  = "SHCoreDataManager", "SHCoreDataManager/**/*.{h,m}"
  #s.exclude_files = "Classes/Exclude"
  s.public_header_files = "SHCoreDataManager/SHCoreDataManager.h"


  s.framework  = "CoreData"
  
  s.requires_arc = true

end
