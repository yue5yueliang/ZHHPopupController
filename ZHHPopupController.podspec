#
# Be sure to run `pod lib lint ZHHPopupController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZHHPopupController'
  s.version          = '0.0.4'
  s.summary          = '一个轻量、易用的弹窗控制器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
ZHHPopupController 一个轻量、易用的弹窗控制器，支持弹出/消失动画、布局位置、遮罩（透明/半透明/模糊）、键盘联动、点击/滑动关闭、windowLevel 分层与多弹窗管理等
                       DESC

  s.homepage         = 'https://github.com/yue5yueliang/ZHHPopupController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '桃色三岁' => '136769890@qq.com' }
  s.source           = { :git => 'https://github.com/yue5yueliang/ZHHPopupController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'

  s.source_files = 'ZHHPopupController/Classes/**/*.{swift,h,m}'
  
  # s.resource_bundles = {
  #   'ZHHPopupController' => ['ZHHPopupController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
