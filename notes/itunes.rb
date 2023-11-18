 require 'cgi'
 ip = ItunesParser.new(file: "/Users/jinx/Library/CloudStorage/Dropbox/eivu/libraries/Huey\ Library.xml");:done
ip.doc['Library Persistent ID'] # "E37B10CB2E6C0187"
ip.doc["Music Folder"] # "file:///Users/jinx/Music/Music/Media.localized/"

lib_path = ip.doc["Music Folder"] # "file:///Users/jinx/Music/Music/Media.localized/"
music_path = lib_path + "Music/" # "file:///Users/jinx/Music/Music/Media.localized/Music/
track =  ip.tracks.values.first


ip.tracks.values.last['Location']


/Users/jinx/Music/Amazon%20Music/Curtis%20Mayfield/Future%20Shock/02%20-%20Move%20on%20Up%20(ReMastered)_ffe88051-df14-4639-852b-09e1327e08f3.mp3
# [9] pry(main)> ip.playlists.last
# => {"Name"=>"Storybook",
#  "Description"=>"Frog Prince in ascending order",
#  "Playlist ID"=>6179,
#  "Playlist Persistent ID"=>"FD85FEE1A260FD7F",
#  "All Items"=>true,
#  "Playlist Items"=>[{"Track ID"=>1634}, {"Track ID"=>1630}, {"Track ID"=>1632}, {"Track ID"=>1628}, {"Track ID"=>1626}]}


# {
#   "Track ID"=>7905,
#   "Name"=>"Move on Up (ReMastered)",
#   "Artist"=>"Curtis Mayfield",
#   "Album Artist"=>"Curtis Mayfield",
#   "Album"=>"Future Shock",
#   "Genre"=>"R&B",
#   "Kind"=>"MPEG audio file",
#   "Size"=>5653035,
#   "Total Time"=>221779,
#   "Disc Number"=>1,
#   "Disc Count"=>1,
#   "Track Number"=>2,
#   "Track Count"=>14,
#   "Year"=>2006,
#   "Date Modified"=>#<DateTime: 2021-06-28T20:53:39+00:00 ((2459394j,75219s,0n),+0s,2299161j)>,
#   "Date Added"=>#<DateTime: 2023-11-13T03:48:32+00:00 ((2460262j,13712s,0n),+0s,2299161j)>,
#   "Bit Rate"=>202,
#   "Sample Rate"=>44100,
#   "Comments"=>"Amazon.com Song ID: 201458569",
#   "Artwork Count"=>1,
#   "Persistent ID"=>"876F5BB7682433F1",
#   "Track Type"=>"File",
#   "Location"=>
#   "file:///Users/jinx/Music/Amazon%20Music/Curtis%20Mayfield/Future%20Shock/02%20-%20Move%20on%20Up%20(ReMastered)_ffe88051-df14-4639-852b-09e1327e08f3.mp3",
#   "File Folder Count"=>-1,
#   "Library Folder Count"=>-1
# }
#  CGI.unescape ip.tracks.values.last['Location']
#        /Users/jinx/Music/Amazon Music/Curtis Mayfield/Future Shock/02 - Move on Up (ReMastered)_ffe88051-df14-4639-852b-09e1327e08f3.mp3
# file:///Users/jinx/Music/Amazon Music/Curtis Mayfield/Future Shock/02 - Move on Up (ReMastered)_ffe88051-df14-4639-852b-09e1327e08f3.mp3