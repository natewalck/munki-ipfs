import subprocess
import os

IPFS_REPO = "/var/ipfs/.ipfs"

def process_request_options(options):
    """Process request options passed by munki"""
    print("***Requesting: {}".format(options.get("url")))
    if not is_pkg_url(options.get("url")) or not is_ipfs_healthy():
        return options
    else:
        print("***Do IPFS stuff")
        pkginfo = options.get("pkginfo")
        cid = pkginfo["ipfs_cid"]
        item_name = os.path.basename(pkginfo["installer_item_location"])
        if exists_in_ipfs(cid):
            ## Get it from ipfs
            # Mutate options to use IPFS wrapper url
            print("***It exists in IPFS!!!")
            print(item_name)
            return options
        else:
            return options


def exists_in_ipfs(cid):
    # Tries to stat the file with a 1s timeout
    args = [
        "sudo",
        "-H",
        "-u",
        "ipfs",
        "ipfs",
        "--timeout",
        "1s",
        "files",
        "stat",
        "/ipfs/{}".format(cid),
    ]
    try:
        proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (_, _) = proc.communicate()
    except OSError as err:
        print("ipfs add failed with error code {}: {}".format(err.errno, err.strerror))
        return False
    # If we get anything other than 0, it wasn't a successful stat
    if proc.returncode == 0:
        return True
    else:
        return False


def is_pkg_url(munki_url):
    """Check to see if the url is for a pkg file"""
    return "pkgs" in munki_url


def is_ipfs_installed():
    return os.path.exists("/usr/local/bin/ipfs")


def is_ipfs_repo_present():
    return os.path.exists(os.path.join(IPFS_REPO))


def is_ipfs_running():
    args = ["/bin/launchctl", "list"]
    try:
        proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (output, err_out) = proc.communicate()
    except OSError as err:
        print("ipfs add failed with error code {}: {}".format(err.errno, err.strerror))

    if b"ai.protocol.ipfs" in output:
        return True
    else:
        return False


def is_ipfs_healthy():
    """Checks to see if ipfs is present on the system and working"""
    if not is_ipfs_installed() or not is_ipfs_repo_present() or not is_ipfs_running():
        return False
    else:
        return True
