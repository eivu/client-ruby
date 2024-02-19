ruby client for interacting with eivu server

```
require './lib/eivu'
Eivu::Client.configuration
Eivu::Client.new.upload_file path_to_file: 'spec/fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3'
Eivu::Client.new.upload_file path_to_file: 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3'
Eivu::Client.new.upload_folder path_to_folder: 'spec/fixtures/samples/audio/'
# multithread uploads are not recommended for audio files with cover art
Eivu::Client.new.upload_folder_via_multithread path_to_folder: 'spec/fixtures/samples'
Eivu::Client.new.upload_folder peepy: true, nsfw: true, path_to_folder: 'spec/fixtures/samples'
Eivu::Client.new.upload_folder peepy: true, nsfw: true, path_to_folder: 'spec/fixtures/samples'
Eivu::Client::MetadataExtractor.from_audio_file 'spec/fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3', 
```



Requirements
- node
- python
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- Download the [fpcalc binary](https://acoustid.org/chromaprint)

