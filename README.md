About
=====

nim-srt is a Nim module for parsing SRT (SubRip) subtitle files.

For the purpose of the examples, assume a file named ``example.srt`` exists
and contains the following data::

    1
    00:02:13,100 --> 00:02:17,950 X1:100 X2:200 Y1:100 Y2: 200
    This is the subtitle text for block 1

    2
    01:52:45,000 --> 01:53:00,400
    Subtitle text can span multiple
    lines if needed, as long as there
    are no blank lines in the middle

Examples:

    # Parse the data.
    var srt : SRTData = readSRT("example.srt")
    # The previous line could also have been done the following ways:
    # var srt : SRTData = parseSRT(readFile("example.srt"))
    # var srt : SRTData = parseSRT(open("example.srt"))

    # Loop through the subtitles and output the subtitle text:
    for subtitle in srt.subtitles:
        echo(subtitle.text)
    # Output:
    # This is the subtitle text for block 1
    # Subtitle text can span multiple
    # lines if needed, as long as there
    # are no blank lines in the middle

    # Output the start and end times of the second subtitle.
    var subtitle : SRTSubtitle = srt.subtitles[1]
    echo(subtitle.startTime) # Output: "01:52:45,000"
    echo(subtitle.endTime) # Output: "01:53:00,400"

    # Output the first coordinates for the first subtitle.
    # Note: if the subtitle doesn't have coordinates (such as the second subtitle
    # example), the coordinate properties are set to the empty string.
    echo("X1: " & srt.subtitles[0].coordinates.x1) # Output: "X1: 100"
    echo("Y1: " & srt.subtitles[0].coordinates.y1) # Output: "Y1: 100"

License
=======

nim-srt is released under the MIT open source license.
