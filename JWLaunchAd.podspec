Pod::Spec.new do |s|
  s.name         = "JWLaunchAd"
  s.version      = "1.3.1"
  s.summary      = "一行代码集成启动页广告,同时支持Storyboard和LaunchImage,支持Gif,自带图片下载缓冲,无负担集成."
  s.homepage     = "https://github.com/JWXIAN/JWLaunchAd"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "JWXIAN" => "bjsgjw@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/JWXIAN/JWLaunchAd.git", :tag => s.version.to_s }
  s.requires_arc = true
  s.source_files = "JWLaunchAd/JWLaunchAd", "*.{h,m}"
end