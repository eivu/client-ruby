ruby client for interacting with eivu server

```
require './lib/eivu'
Eivu::Client.new.upload_file path_to_file: "/Users/jinx/Downloads/PXL_20230124_162634633.jpg"
Eivu::Client.new.upload_folder path_to_folder: "/Users/jinx/Downloads/xfer", peepy: true, nsfw: true
Eivu::Client.new.upload_folder path_to_folder: "/Users/jinx/Downloads/demo"

```