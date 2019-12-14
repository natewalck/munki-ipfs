import subprocess
import os

IPFS_REPO = "/var/ipfs/.ipfs"


def process_request_options(options):
    """Process request options passed by munki"""
    if not is_pkg_url(options.get("url")) or not is_ipfs_healthy():
        return options
    else:
        print("    IPFS Middleware: Processing request for: {}".format(options.get("url")))
        pkginfo = options.get("pkginfo")
        if "ipfs_cid" in pkginfo.keys():
            cid = pkginfo["ipfs_cid"]
            item_name = os.path.basename(pkginfo["installer_item_location"])
            if exists_in_ipfs(cid):
                ## Get it from ipfs
                print(
                    "    IPFS Middleware: Found item {} with CID {}".format(item_name, cid)
                )
                options["url"] = "http://127.0.0.1:8080/ipfs/{}/{}".format(
                    cid, item_name
                )
                print("    IPFS Middleware: New url is: {}".format(options.get("url")))
                return options
            else:
                return options
        else:
            print(
                "    IPFS Middleware: Not found in IPFS, falling back to {}...".format(
                    options.get("url")
                )
            )
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
        print(
            "    IPFS Middleware: ipfs file stat failed with error code {}: {}".format(
                err.errno, err.strerror
            )
        )
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
        print(
            "    IPFS Middleware: IPFS service check failed with error code {}: {}".format(
                err.errno, err.strerror
            )
        )

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
