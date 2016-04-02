#!/bin/bash

while :
do
    TRACK=`qdbus org.mpris.clementine /TrackList \
        org.freedesktop.MediaPlayer.GetCurrentTrack`
    NOWPLAYING=`qdbus org.mpris.clementine /TrackList \
        org.freedesktop.MediaPlayer.GetMetadata $TRACK \
        | sort -r | egrep "^(title:|artist:)" | sed -e "s/^.*: //g" \
        | sed -e ':a;N;$!ba;s/\n/ - /g'`
    echo $NOWPLAYING > nowplaying.txt
    sleep 2
done

