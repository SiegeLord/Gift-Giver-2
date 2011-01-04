#!/bin/sh
ldc main.d giftgiver2/*.d -oq -O5 -of="gg2" -L-lallegro_ttf -L-lallegro_font -L-lallegro_image -L-lallegro_primitives -L-lallegro_audio  -L-lallegro_acodec  -L-lallegro -L-ldallegro5
rm *.o
