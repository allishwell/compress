# COMPRESS BULK IMAGES #

This is a simple shell script for compress bulk images, which is based on [imagemagick](http://www.imagemagick.org/). 

### How do I get set up? ###

Install [imagemagick](http://www.imagemagick.org/script/install-source.php#unix).
if debian *sudo apt-get -y install imagemagick*

```
git clone https://github.com/allishwell/compress.git ~/compress && cd ~/compress && ln -s ~/compress/compress.sh compress && echo 'export PATH=$PATH:~/compress' >> ~/.bashrc && bash
```
that's it.
```
compress --help
  Usage: compress [-R] [-f] [-d directory-path] [-n name] [-e extention] [-q quality]
    where:
      -d 
        directory path need to be scaned default value .
      -R
        recursivly scan directories
      -n 
        file name default * 
      -e 
        file extention default jpg
      -q 
        quality of image default 50
      -f 
        forcefully compress all
      --size n[cwbkMG]
        File uses n units of space. The following suffixes can be used:
            'b'    for 512-byte blocks (this is the default if no suffix  is used)
            'c'    for bytes
            'w'    for two-byte words
            'k'    for Kilobytes (units of 1024 bytes)
            'M'    for Megabytes (units of 1048576 bytes)
            'G'    for Gigabytes (units of 1073741824 bytes)
    --resize geometry
        Format of geometry: [WIDTHxHEIGHT | PERCENTAGE]
        Resize image based on width/height or percentage
          WIDTH/HEIGHT - positive integer
          PERCENTAGE - Eg. 50%
          
          1024x - will automatically determine height to keep dimension
          x576 - will automatically determine width to keep dimension
      --log filename
        option log file name
```

### some sample commands ###
```
 compress -R
    will recursively scan all jpg file and compress down to 50%
 compress -R -f -e png --size +521k
    will recursively compress all png files which are greater than 512k size
 compress -R -f -e png --size -521k
    will recursively compress all png files which are less than 512k size
 compress -R -f -d "/home/pictures/" -n "nature*" -e "png" -q 70
```
