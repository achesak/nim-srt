# Nim module for parsing SRT subtitle files.

# Written by Adam Chesak.
# Released under the MIT open source license.


## srt is a Nim module for parsing SRT (SubRip) subtitle files.
## 
## For the purpose of the examples, assume a file named ``example.srt`` exists
## and contains the following data::
##     
##     1
##     00:02:13,100 --> 00:02:17,950 X1:100 X2:200 Y1:100 Y2: 200
##     This is the subtitle text for block 1
##     
##     2
##     01:52:45,000 --> 01:53:00,400
##     Subtitle text can span multiple
##     lines if needed, as long as there
##     are no blank lines in the middle
## 
## Examples:
## 
## .. code-block:: nimrod
##     
##     # Parse the data.
##     var srt : SRTData = readSRT("example.srt")
##     # The previous line could also have been done the following ways:
##     # var srt : SRTData = parseSRT(readFile("example.srt"))
##     # var srt : SRTData = parseSRT(open("example.srt"))
##     
##     # Loop through the subtitles and output the subtitle text:
##     for subtitle in srt.subtitles:
##         echo(subtitle.text)
##     # Output:
##     # This is the subtitle text for block 1
##     # Subtitle text can span multiple
##     # lines if needed, as long as there
##     # are no blank lines in the middle
##     
##     # Output the start and end times of the second subtitle.
##     var subtitle : SRTSubtitle = srt.subtitles[1]
##     echo(subtitle.startTime) # Output: "01:52:45,000"
##     echo(subtitle.endTime) # Output: "01:53:00,400"
##     
##     # Output the first coordinates for the first subtitle.
##     # Note: if the subtitle doesn't have coordinates (such as the second subtitle
##     # example), the coordinate properties are set to the empty string.
##     echo("X1: " & srt.subtitles[0].coordinates.x1) # Output: "X1: 100"
##     echo("Y1: " & srt.subtitles[0].coordinates.y1) # Output: "Y1: 100"


import times
import strutils


type
    SRTData* = ref SRTDataInternal
    SRTDataInternal* = object
        subtitles*: seq[SRTSubtitle]
    
    SRTSubtitle* = ref SRTSubtitleInternal
    SRTSubtitleInternal* = object
        number* : int
        startTime* : TimeInterval
        endTime* : TimeInterval
        startTimeString* : string
        endTimeString* : string
        coordinates* : SRTCoordinates
        text* : string
    
    SRTCoordinates* = ref SRTCoordinatesInternal
    SRTCoordinatesInternal* = object
        x1* : string
        y1* : string
        x2* : string
        y2* : string


proc parseSRT*(srtData : string): SRTData = 
    ## Parses a string containing SRT data into an ``SRTData`` object.
    
    var data : seq[string] = srtData.replace("\r\n", "\n").replace("\r", "\n").strip(leading = true, trailing = true).split("\n\n")
    var srt : SRTData = SRTData(subtitles: @[])
    
    for i in data:
        var sub : SRTSubtitle = SRTSubtitle()
        var lines : seq[string] = i.strip(leading = true, trailing = true).split("\n")
        
        sub.number = parseInt(lines[0])
        sub.startTimeString = lines[1][0..11]
        sub.endTimeString = lines[1][17..28]
        
        sub.startTime = initInterval(milliseconds = parseInt(sub.startTimeString[9..11]), seconds = parseInt(sub.startTimeString[6..7]),
                                     minutes = parseInt(sub.startTimeString[3..4]), hours = parseInt(sub.startTimeString[0..1]))
        sub.endTime = initInterval(milliseconds = parseInt(sub.endTimeString[9..11]), seconds = parseInt(sub.endTimeString[6..7]),
                                     minutes = parseInt(sub.endTimeString[3..4]), hours = parseInt(sub.endTimeString[0..1]))
        
        var coords : SRTCoordinates = SRTCoordinates()
        if len(lines[1]) > 29:
            coords.x1 = lines[1][33..35]
            coords.x2 = lines[1][40..42]
            coords.y1 = lines[1][47..49]
            coords.y2 = lines[1][54..56]
        else:
            coords.x1 = ""
            coords.x2 = ""
            coords.y1 = ""
            coords.y2 = ""
        sub.coordinates = coords
        
        sub.text = lines[2..high(lines)].join("\n")
        
        srt.subtitles.add(sub)
    
    return srt


proc parseSRT*(srtData : File): SRTData = 
    ## Parses a file containing SRT data into an ``SRTData`` object.
    
    return parseSRT(readAll(srtData))


proc readSRT*(filename : string): SRTData = 
    ## Reads and parses a file containing SRT data into an ``SRTData`` object.
    
    return parseSRT(readFile(filename))
