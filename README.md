ruby client for interacting with eivu server

```
require './lib/eivu'
Eivu::Client.configuration
Eivu::Client.upload_file path_to_file: 'spec/fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3'
Eivu::Client.upload_file path_to_file: 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3', nsfw: false
Eivu::Client.upload_file path_to_file: 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3', nsfw: true
Eivu::Client.upload_folder path_to_folder: 'spec/fixtures/samples/audio/'

# Use generic upload tool
Eivu::Client.upload 'spec/fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3'
Eivu::Client.upload 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph1.mp3', nsfw: false
Eivu::Client.upload 'spec/fixtures/samples/audio/brothers_grimm/the_frog_prince/paragraph2.mp3', nsfw: true
Eivu::Client.upload 'spec/fixtures/samples/'
Eivu::Client.upload 'spec/fixtures/secured/', peepy: true, nsfw: true,

# Multithread upload is on by default, but can be turned off
Eivu::Client.upload 'spec/fixtures/samples', multithread: false

# Extract metadata from audio file
Eivu::Client::MetadataExtractor.from_audio_file 'spec/fixtures/samples/Piano_brokencrash-Brandondorf-1164520478.mp3',
```

Requirements

- node
- python
  remote file download
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)

audio uploads

- Download the [fpcalc binary](https://acoustid.org/chromaprint)

comic uploads

- [the unarchiver](https://theunarchiver.com/command-line)
- Imagemagick
- (Un)Rar
- (Un)Zip

## Installation

### fpcalc binary

Download the [fpcalc binary](https://acoustid.org/chromaprint)

chmod +x fpcalc

(mac/linux) move the binary to `/usr/local/bin`

### The Unarchiver

Download the [the unarchiver](https://theunarchiver.com/command-line)

chmod +x the binaries

(mac/linux) move the binary to `/usr/local/bin`

### (Un)Zip

included with MacOs

### (Un)Rar

brew install rar

### Imagemagick

brew install Imagemagick

### Mime Magic Support

(mac) run `brew install shared-mime-info` before you run `bundle install`
