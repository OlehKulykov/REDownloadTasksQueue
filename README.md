# REDownloadTasksQueue

iOS Objective-C download queue based on NSURLSessionDownloadTask's. 

Main features:
- Using NSURLSessionDownloadTask, required iOS 7 and up.
- Using another operation queue for downloading.
- Controlling concurrent tasks for parallel downloading, can be tuned to quality of the internet connection.
- Progress calculating on downloaded data size per each task, not on simple count of tasks, for smoothly progressing.
- Queue can serialized/deserialized 

[![Total views](https://sourcegraph.com/api/repos/github.com/OlehKulykov/REDownloadTasksQueue/counters/views.png)](https://sourcegraph.com/github.com/OlehKulykov/REDownloadTasksQueue)
[![Views in the last 24 hours](https://sourcegraph.com/api/repos/github.com/OlehKulykov/REDownloadTasksQueue/counters/views-24h.png)](https://sourcegraph.com/github.com/OlehKulykov/REDownloadTasksQueue)
