# Uncomment the next line to define a global platform for your project
platform :ios, '10.3'

workspace 'KSImageCarouselExample.xcworkspace'

target 'KSImageCarouselExample' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
end

target 'KSImageCarousel' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  # workspace 'KSImageCarousel.xcworkspace'
  project 'KSImageCarousel/KSImageCarousel'
  pod 'PINRemoteImage'

  # Add '' target here to silence off warning message below when run 'pod install'
  # [!] The Podfile contains framework targets, for which the Podfile does not contain host targets (targets which embed the framework).
  # If this project is for doing framework development, you can ignore this message. Otherwise, add a target to the Podfile that embeds these frameworks to make this message go away (e.g. a test target).
  target 'KSImageCarouselTests' do 
  end
end