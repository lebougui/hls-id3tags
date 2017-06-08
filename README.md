## MPEG2 TS Timed metadata 

This tools allows to add timed metadata into transport stream.
Metadata are inserted through ID3v2 tags.

Tools based on https://github.com/dusterio/hlsinjector project and MPEG::ID3v2Tag perl package.

## How To

To insert timed ID3v2 tags use the mpeg_id3v2_injector.sh scrit.
Script will insert Id3v2 TXXX and/or TIT2 tags into the given TS.

```

# ./mpeg_id3v2_injector.sh -h                                                         
Usage : ./mpeg_id3v2_injector.sh -s <transport stream name> -i <ID3v2 file:time> -p <providerID> -a <assetID> -t <time> -d

MPEG2-TS ID3 timed metadata injector.

OPTIONS :
        -h              displays this help
        -s              transport stream name
        -i              ID3v2 filename and time to insert. Several entry can be given separator is ",".
        -p              provider ID
        -a              asset ID
        -t              time in second
        -d              to enable debug mode

        Examples : 
        #To insert title with an existing ID3 file
        ./mpeg_id3v2_injector.sh -s test.ts            -i test.id3:0 
        #To insert several titles with an existing ID3 files
        ./mpeg_id3v2_injector.sh -s test.ts            -i test.id3:0,test2.id3:10 
        #To insert several title without an ID3 file.
        ./mpeg_id3v2_injector.sh -s test.ts            -p test.com            -a ad0
           -t 0

Version       : ./mpeg_id3v2_injector.sh 1.0 (2016/06/10) 
Maintainer(s) : Lebougui 

```

Given a transportream fileSequence0.ts to add TXXX ID3v2 tag with string "test.com/ad0" use this command :

```

# ./mpeg_id3v2_injector.sh -p test.com -a ad0 -t 0 -s fileSequence0.ts -d  
00000000  49 44 33 03 00 40 00 00  00 24 00 00 00 06 00 01  |ID3..@...$......|
00000010  00 00 00 00 54 58 58 58  00 00 00 0f 00 00 00 00  |....TXXX........|
00000020  74 65 73 74 2e 63 6f 6d  2f 61 64 30 00 00 00 00  |test.com/ad0.|
0000002e
** Imported 1 metadata tags
Inserting ID3 frame after frame 5 (len=188)
Parsed 6440 MPEG TS frames with 0 errors
Total of 1 programs and 2 streams
Injected 1 frames
Finished in 22.464ms


```

Script can be executed in a loop mode.
To insert ID3v2 tags in several transport streams :

```

for entry in `find /home/nginx/html/cdn/testad -name "*.ts"`; do ./mpeg_id3v2_injector.sh -s $entry -p test.com -a ad0 -t 0 ; done

```



