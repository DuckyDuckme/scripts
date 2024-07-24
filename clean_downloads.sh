#!/bin/bash
#
# a small script to remove anything in $HOME/Downloads that is older than 30 days

clean_downloads() {
    # exclude any subdirectories with -maxdepth 1
    # find 
    find . -maxdepth 1 -used +30 -print0 | xargs -0 /bin/rm -rf
}
