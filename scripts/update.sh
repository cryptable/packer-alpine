#!/bin/sh

# Update the box
echo http://dl-cdn.alpinelinux.org/alpine/v3.16/community >> /etc/apk/repositories
apk update
