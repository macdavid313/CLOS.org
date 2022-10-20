#!/usr/bin/env sh

echo $(pwd) is the current working directory.

emacs -Q --batch --script publish.el
