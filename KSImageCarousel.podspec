
Pod::Spec.new do |s|

  s.name         = "KSImageCarousel"
  s.version      = "1.0.4"
  s.summary      = "Lightweight image carousel which can easily adapt to different type of image source."

  s.description  = "KSImageCarousel support both finite and infinite scrolling mode. Just init KSImageCarousel with your desire UIImages or image URLs and it will do all the work for you. KSImageCarousel can also easily adapt to different type of image source other than UIImage and image URL"

  s.homepage     = "https://github.com/LeeKahSeng/KSImageCarousel"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Lee Kah Seng" => "kahseng.lee123@gmail.com" }
 
  s.swift_version = '4.2'
  s.platform     = :ios, "10.3"
  s.source       = { 
    :git => 'https://github.com/LeeKahSeng/KSImageCarousel.git', 
    :tag => s.version.to_s,
    :branch => 'master'
  }

  s.source_files = 'KSImageCarousel/KSImageCarousel/Sources/*.swift'

end
