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
import parseutils
import strformat
import strscans


type
    SRTData* = ref object
        subtitles*: seq[SRTSubtitle]
    
    SRTSubtitle* = ref object
        number* : int
        startTime* : TimeInterval
        endTime* : TimeInterval
        startTimeString* : string
        endTimeString* : string
        coordinates* : SRTCoordinates
        text* : string
    
    SRTCoordinates* = ref object
        x1* : int
        y1* : int
        x2* : int
        y2* : int
proc parseCoords(s:string): SRTCoordinates =
    ## Parses X1:<int> X2:<int> Y1:<int> Y2:<int> into SRTCoordinates
    result = SRTCoordinates()
    let start = find(s," X1:")
    if start >= 0 and scanf(s[start..^1]," X1:$i X2:$i Y1:$i Y2:$i",
        result.x1,result.x2,result.y1,result.y2):
        return result
    return result


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
        
        sub.startTime = initTimeInterval(milliseconds = parseInt(sub.startTimeString[9..11]), seconds = parseInt(sub.startTimeString[6..7]),
                                     minutes = parseInt(sub.startTimeString[3..4]), hours = parseInt(sub.startTimeString[0..1]))
        sub.endTime = initTimeInterval(milliseconds = parseInt(sub.endTimeString[9..11]), seconds = parseInt(sub.endTimeString[6..7]),
                                     minutes = parseInt(sub.endTimeString[3..4]), hours = parseInt(sub.endTimeString[0..1]))
        
        sub.coordinates = parseCoords(lines[1])
        
        sub.text = lines[2..high(lines)].join("\n")
        
        srt.subtitles.add(sub)
    
    return srt


proc parseSRT*(srtData : File): SRTData = 
    ## Parses a file containing SRT data into an ``SRTData`` object.
    
    return parseSRT(readAll(srtData))


proc readSRT*(filename : string): SRTData = 
    ## Reads and parses a file containing SRT data into an ``SRTData`` object.
    
    return parseSRT(readFile(filename))

proc hasCoords(c: SRTCoordinates): bool =
    if (c.x1 == 0 and c.x2 == 0 and
        c.y1 == 0 and c.y2 == 0):
        return false
    return true

proc `$`*(c: SRTCoordinates): string =
    ## Returns string of coordinates
    result = fmt"X1:{c.x1} X2:{c.x2} Y1:{c.y1} Y2:{c.y2}"


