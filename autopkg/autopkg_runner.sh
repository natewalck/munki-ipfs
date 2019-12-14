#!/bin/zsh

# Run autopkg with the app list and use IPFSadd post processor
/usr/local/bin/autopkg run -v -l /Users/Shared/autopkg/app_list.txt --post com.github.natewalck.autopkg.shared/IPFSAdd
# If we don't makecatalogs, it'll import duplicates next run
/usr/local/munki/makecatalogs
# Make sure we have icons for everything
/usr/local/munki/iconimporter