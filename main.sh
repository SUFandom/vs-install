#!/bin/bash


ID=$(< files/vid.tag)
SHA256=$(< files/sha256.dig)
LINK_AMD_DESKTOP64="https://update.code.visualstudio.com/$ID/linux-deb-x64/stable"
LINK_ARM32="https://update.code.visualstudio.com/$ID/linux-deb-armhf/stable"
LINK_ARM64="https://update.code.visualstudio.com/$ID/linux-deb-arm64/stable"
BACK_T="VS Code Installer/Updater for Debian AMD64 and/or ARM(32/64) - Version 2"
MAIN_T="VS Code Installer/Updater v2"

if [ "$1" == "--autoremove" ] ; then
    AR="true"
else
    AR="false"
fi

# Arch checking
case $(uname -m) in 
    "x86_64")
        echo "Arch is x64"
        ;;
    "armhf")
        echo "Arch is armhf"
        ;;
    "aarch64")
        echo "Arch is aarch64"
        ;;
    *)
        echo "Arch is $(uname -m), which is not supported..."
        exit 1
        ;;
esac

# ExecID Check

if [ "$(/usr/bin/id -u)" -ne 0 ]; then
    dialog --backtitle "Error!" --title "Cannot continue without superuser privileges..." --msgbox "The script can't run under userspace session \n\nThis script requires root access to continue..." 0 0
    pass=$(dialog --backtitle "Enter Password" \
                    --title "Enter Superuser password" \
                    --clear \
                    --passwordbox "Enter Superuser password, all input texts are invisible for security purposes.\n\nSee Security.md for more info, if it's wrong, then the script wont launch again.\n\nWARNING: If you are done installing or removing vs code via this script, do exit by pressing Ctrl+C since you are running this on userspace, jic." 0 0 \
                    2>&1 >/dev/tty)
    exstats=$?
    case $exstats in
        1)
            unset pass
            exit 1
            ;;
    esac
    echo "$pass" | sudo -S "$0" "$@"
    status=$?
    case $status in
        1)
            clear
            unset pass # Unset Pass jic
            echo "Wrong Password, please launch the code again with superuser privileges again to never get the issue..."
            echo "ONLY if the script really stopped without going to main menu." 
            echo "because sometimes sudo sends code 1 even tho its now running on sudo mode"
            echo "Unless if you actually ran the script and installed or uninstalled vs code fine then"
            echo "that means this error is a fallback and just disregard it"
            ;;
    esac
fi

# JUST TO MAKE SUUUURE
unset pass

# Functions
# function msgbx () {
#     dialog --backtitle "$BACK_T" --title "$1" --msgbox "$2" 0 0
# }

function msg () {
    echo "$1"
}

function dt() {
    MDY=$(date +%m-%d-%y)
    TC=$(date +%T)
    msg "$MDY - $TC"
}

function check_src_dep() {
    clear
    if [ -e /usr/bin/aria2c ] ; then
        msg "$(dt) : Aria2 Found"
    else
        msg "$(dt) : Aria2c not found"
    fi
}

function check_vs() {
    if [ -e /usr/bin/code ] && [ -e /usr/share/code ]; then
        echo "$(dt) : VS Code installed"
    else 
        echo "$(dt) : VS Code not installed..."
    fi
}

function welcome() {
    dialog --backtitle "Microsoft Software License Terms" --title "Read Microsoft Software License Terms" --yes-label "Accept" --no-label "Decline and exit" --yesno "$(cat lc/MS.txt)" 0 0
    li=$?
    case $li in
        0)
            menu
            ;;
        1)
            exit 1
            ;;
    esac
}

function install_vs() {
    clear
    case $(uname -m) in
        "x86_64")
            if [ -e /usr/bin/aria2c ]; then 
                msg "$(dt) : Aria2 Found, downloading and installing VS Code"
                mkdir -p file-opt
                aria2c --out=code.deb -j 15 --checksum=sha-256=$SHA256 "$LINK_AMD_DESKTOP64"
                sudo apt install ./code.deb -y
                rm -rf code.deb
                rm -rf code.deb.aria2
                msg "$(dt) : Task Done"
                sleep 1
                menu
            else
                msg "$(dt) : Aria2c not found"
                msg "$(dt) : Aborting"
                sleep 1
                menu
            fi
            ;;
        "armhf")
            if [ -e /usr/bin/aria2c ]; then 
                msg "$(dt) : Aria2 Found, downloading and installing VS Code"
                mkdir -p file-opt
                aria2c --out=code.deb -j 15 --checksum=sha-256=$SHA256 "$LINK_ARM32"
                sudo apt install ./code.deb -y
                rm -rf code.deb
                rm -rf code.deb.aria2
                msg "$(dt) : Task Done"
                sleep 1
                menu
            else
                msg "$(dt) : Aria2c not found"
                msg "$(dt) : Aborting"
                sleep 1
                menu
            fi
            ;;
        "aarch64")
            if [ -e /usr/bin/aria2c ]; then 
                msg "$(dt) : Aria2 Found, downloading and installing VS Code"
                mkdir -p file-opt
                aria2c --out=code.deb -j 15 --checksum=sha-256=$SHA256 "$LINK_ARM64"
                sudo apt install ./code.deb -y
                rm -rf code.deb
                rm -rf code.deb.aria2
                msg "$(dt) : Task Done"
                sleep 1
                menu
            else
                msg "$(dt) : Aria2c not found"
                msg "$(dt) : Aborting"
                sleep 1
                menu
            fi
            ;;
        *)
            msg "$(dt) : Arch is $(uname -m), which is not supported..."
            msg "$(dt) : Aborting"
            sleep 5
            menu
            ;;
    esac
}         

function uninstall_vs() {
    clear
    case $(uname -m) in
        "x86_64")
            if [ -e /usr/bin/code ]; then
                msg "$(dt) : Removing VS Code..."
                sudo apt remove code -y
                if [ "$AR" == "true" ]; then
                    msg "$(dt) : Flag Autoremove provoked, attempting to autoremove packages..."
                    sudo apt autoremove -y
                fi
                msg "$(dt) : Task Done"
                sleep 1
                menu
            else
                msg "$(dt) : VS Code is not installed"
                msg "$(dt) : Aborting"
                menu
            fi
            ;;
        "armhf")
            if [ -e /usr/bin/code ]; then
                msg "$(dt) : Removing VS Code..."
                sudo apt remove code -y
                if [ "$AR" == "true" ]; then
                    msg "$(dt) : Flag Autoremove provoked, attempting to autoremove packages..."
                    sudo apt autoremove -y
                fi
                msg "$(dt) : Task Done"
                menu
            else
                msg "$(dt) : VS Code is not installed"
                msg "$(dt) : Aborting"
                menu
            fi
            ;;
        "aarch64")
            if [ -e /usr/bin/code ]; then
                msg "$(dt) : Removing VS Code..."
                sudo apt remove code -y
                if [ "$AR" == "true" ]; then
                    msg "$(dt) : Flag Autoremove provoked, attempting to autoremove packages..."
                    sudo apt autoremove -y
                fi
                msg "$(dt) : Task Done"
            else
                msg "$(dt) : VS Code is not installed"
                msg "$(dt) : Aborting"
                menu
            fi
            ;;
    esac
}

function about() {
    dialog --backtitle "$BACK_T" --title "About" --infobox "VS Code Installer for Debian AMD64 and/or ARM(32/64) - Version 2\nBy SUFandom\nVersion 2" 0 0
    menu
}

function menu () {
    MAINPG=$(dialog --backtitle "$BACK_T" \
                    --title "$MAIN_T" \
                    --menu "Pick an Option\n\nVersion: $ID\nSHA256: $SHA256\n\nStatus:\n\nIs VS Installed?: $(check_vs)\nScript Dependency Installed?: $(check_src_dep)\nAutoremove Flag Set: $AR\n\nNote: If you select either Install or Uninstall, it will directly do it without confirmation" 0 0 0 \
                    "Install VS Code" "Install VS Code" \
                    "Uninstall" "Uninstall VS Code" \
                    "About" "About Installer" \
                    2>&1 >/dev/tty)
    fs=$?
    case $fs in
        1)
            exit 1
            ;;
    esac
    case $MAINPG in
        "Install VS Code")
            install_vs
            ;;
        "Uninstall")
            uninstall_vs
            ;;
        "About")
            about
            ;;
    esac
}

if [ "$(/usr/bin/id -u)" == "0" ]; then
    welcome
else
    exit 1
fi