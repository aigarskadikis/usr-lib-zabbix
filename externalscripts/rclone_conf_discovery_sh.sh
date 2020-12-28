#!/bin/sh

home_dir_of_users=$(cut -d: -f6 /etc/passwd|sort|uniq|sed "s|$|\/.config\/rclone\/rclone.conf|")

echo "$home_dir_of_users" | while IFS= read -r file; do { if [ -f $file ] ; then echo "$file exist"; fi; } done



