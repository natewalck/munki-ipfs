#!/bin/zsh

echo "Validing requirements..."
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
/usr/bin/defaults write com.github.autopkg MUNKI_REPO "$MUNKI_REPO"
/usr/bin/defaults write ~/Library/Preferences/com.googlecode.munki.munkiimport repo_url "file://$MUNKI_REPO"

# Place autopkg runner script
echo "Placing autopkg runner script..."
/bin/cp ./autopkg/autopkg_runner.sh /Users/Shared/autopkg/
/bin/chmod +x /Users/Shared/autopkg/autopkg_runner.sh
/bin/cp ./autopkg/app_list.txt /Users/Shared/autopkg/

# Copy recipe overrides into place
echo "Installing autopkg recipe overrides..."
/bin/cp -r ./autopkg/RecipeOverrides/* ~/Library/AutoPkg/RecipeOverrides/

# Copy ipfs middleware into place 
echo "Installing IPFS middleware..."
/usr/bin/sudo /bin/cp -r ./middleware/middleware_ipfs.py /usr/local/munki/
/usr/bin/sudo /usr/sbin/chown root:wheel /usr/local/munki/middleware_ipfs.py
/usr/bin/sudo /bin/chmod 600 /usr/local/munki/middleware_ipfs.py

# Add a few autopkg recipe repos
echo "Adding natewalck recipes..."
autopkg repo-add https://github.com/natewalck/natewalck-recipes
echo "Adding facebook recipes..."
autopkg repo-add https://github.com/facebook/Recipes-for-AutoPkg
echo "Adding hjuutilainen recipes..."
autopkg repo-add https://github.com/autopkg/hjuutilainen-recipes

# Initialize ipfs
/usr/bin/sudo -H -u ipfs /usr/local/bin/ipfs init

# Good to go
echo "To get started, run /Users/Shared/autopkg/autopkg_runner.sh"