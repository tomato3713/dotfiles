#! /bin/sh
#
# ./jtalk.sh {string} {output-fname}
#

# Instruct the voice file
VOICE=/usr/share/hts-voice/mei_normal.htsvoice
# Instruct the dictionary file
DICT=/var/lib/mecab/dic/open-jtalk/naist-jdic/

echo $1 | open_jtalk \
    -m $VOICE \
    -x $DICT \
    -ow $2 \
