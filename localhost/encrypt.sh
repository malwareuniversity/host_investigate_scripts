#!/bin/bash
# (@) Encrypt -- Bypass GMail limits based on filetype.  Stomps 'AA' over the file format header.

which 7z 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    echo "Please install 7zip"
    exit 1
fi

if [ $# -ne 3 ]; then
    echo "Usage:  $0 <Password> <file_name_without_extension> <target_file_or_folder>"
    exit 1
fi

if [ ! -e $3 ]; then
    echo "File or directory \"$2\" does not exist"
    exit 1
fi

7z a -p$1 -mhe=on $2.7z $3
mv $2.7z $2.nz
printf 'AA' | dd conv=notrunc of=$2.nz bs=1

echo "Done, bytes were modified, safe to send."
