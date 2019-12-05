#!/bin/zsh

# Make sure requirements are installed before running setup
command -v autopkg >/dev/null 2>&1 || { echo >&2 "Install autopkg before continuing"; exit 1; }
command -v ipfs >/dev/null 2>&1 || { echo >&2 "Install ipfs before continuing"; exit 1; }
command -v makecatalogs >/dev/null 2>&1 || { echo >&2 "Install munki admin tools before continuing"; exit 1; }

# Make sure the directories we need exist
[ ! -d /Users/Shared ] && mkdir /Users/Shared/munki_repo
[ ! -d /Users/Shared/munki_repo ] && mkdir /Users/Shared/munki_repo
[ ! -d /Users/Shared/autopkg ] && mkdir /Users/Shared/autopkg
[ ! -d ~/Library/AutoPkg/RecipeOverrides ] && mkdir ~/Library/AutoPkg/RecipeOverrides

# Configure munki repo setting for autopkg
MUNKI_REPO="/Users/Shared/munki_repo"
defaults write com.github.autopkg MUNKI_REPO "$MUNKI_REPO"
defaults write ~/Library/Preferences/com.googlecode.munki.munkiimport repo_url "file://$MUNKI_REPO"

# Place autopkg runner script
/bin/cp ./autopkg/autopkg_runner.sh /Users/Shared/autopkg/
/bin/chmod +x /Users/Shared/autopkg/autopkg_runner.sh
/bin/cp ./autopkg/app_list.txt /Users/Shared/autopkg/

# Move recipe overrides into place
/bin/cp -r ./autopkg/RecipeOverrides/* ~/Library/AutoPkg/RecipeOverrides/

# Add a few autopkg recipe repos
echo "Adding natewalck recipes..."
autopkg repo-add https://github.com/natewalck/natewalck-recipes
echo "Adding facebook recipes..."
autopkg repo-add https://github.com/facebook/Recipes-for-AutoPkg

# Initialize ipfs
ipfs init

# Good to go
echo "To get started, run /Users/Shared/autopkg/autopkg_runner.sh"