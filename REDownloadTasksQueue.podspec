Pod::Spec.new do |s|

# Common settings
  s.name         = "REDownloadTasksQueue"
  s.version      = "0.1.3"
  s.summary      = "iOS Objective-C download queue based on NSURLSessionDownloadTask's"
  s.description  = <<-DESC
iOS Objective-C download queue based on NSURLSessionDownloadTask's.
  Main features:
    - Using NSURLSessionDownloadTask, required iOS 7 and up.
    - Using another operation queue for downloading.
    - Controlling concurrent tasks for parallel downloading, can be tuned to quality of the internet connection.
    - Possibility to inform about queue state via delegate, blocks and notifications. Can be selected which method to use.
    - Progress calculating on downloaded data size per each task, not on simple count of tasks, for smoothly progressing.
    - Queue can be serialized/deserialized for future reusing.
    - Required ARC.
                      DESC
  s.homepage     = "https://github.com/OlehKulykov/REDownloadTasksQueue"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Oleh Kulykov" => "<info@resident.name>" }
  s.source       = { :git => 'https://github.com/OlehKulykov/REDownloadTasksQueue.git', :tag => s.version.to_s }

# Platforms
  s.platform     = :ios, "7.0"

# Build  
  s.public_header_files = 'REDownloadTasksQueue.h', 'REDownloadTasksQueue+Serialization.h', 'REMutableNumber.h'
  s.source_files = '*.{h,m}'
  
  s.xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/REDownloadTasksQueue"' }
  s.requires_arc = true

end
