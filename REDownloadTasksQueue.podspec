Pod::Spec.new do |s|

# Common settings
  s.name         = "REDownloadTasksQueue"
  s.version      = "0.1.0"
  s.summary      = "iOS Objective-C download queue based on NSURLSessionDownloadTask's"
  s.description  = <<-DESC
iOS Objective-C download queue based on NSURLSessionDownloadTask's.
                      DESC
  s.homepage     = "https://github.com/OlehKulykov/REDownloadTasksQueue"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Oleh Kulykov" => "info@resident.name" }
  s.source       = { :git => 'https://github.com/OlehKulykov/REDownloadTasksQueue.git', :tag => s.version.to_s }

# Platforms
  s.platform     = :ios, "7.0"

# Build  
  s.public_header_files = 'REDownloadTasksQueue.h', 'REDownloadTasksQueue+Serialization.h'
  s.source_files = '*.{h,m}'
  
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/REDownloadTasksQueue"' }
  s.requires_arc = true

end
