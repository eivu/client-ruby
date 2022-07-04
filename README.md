ruby client for interacting with eivu server

```
require './lib/eivu'
Eivu::Client.new.upload_folder path_to_folder: "/Users/jinx/Downloads/xfer", peepy: true, nsfw: true
Eivu::Client.new.upload_folder path_to_folder: "/Users/jinx/Downloads/demo"

```