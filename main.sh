#!/bin/bash 
clear
case $(uname -m) in
    x86_64)
        echo " "
        ;;
    armv7a)
        echo "32 Bit ARM is not supported, sorry"
        exit 1
        ;;
    *)
        echo "Sorry. VSCode for $(uname -m) is not available at the moment..."
        exit 1
        ;;
esac
if [ "$(/usr/bin/id -u)" -ne 0 ]; then
    dialog --backtitle "Error" --title "Cannot Continue without SuperUser" --msgbox "The script cannot run under user session\n\nThis script requires root access to continue..." 0 0
    password=$(dialog --backtitle "Enter Password" \
                        --title "Enter sudo Password" \
                        --clear \
                        --passwordbox "Enter sudo password, all input texts are invisible for security reasons\n\nSee Security.md for more info, if it's wrong, the script wont launch again" 0 0 \
                        2>&1 >/dev/tty)
    grab=$?
        case $grab in 
            1)
                unset password # Security reasons
                exit 1
                ;;
        esac 
    echo "$password" | sudo -S "$0" "$@"
    grab=$?
        case $grab in
            1)
                clear
                unset password
                echo "Wrong Password, relaunch again, at least with sudo main.sh to avoid this"
                echo "If you have already launched this sucessfully, then that means its ok. Im currently trying to figure out this"
                exit $grab 
                ;;
        esac 
    exit 0
fi 

unset password

# CACHING
TITLE="VS Code Installer"
BACK="VS Code Installer - Version 1"

# COLORS!
# setaf - foreground
# setab - background
#RED=$(tput setaf 1)
#GREEN=$(tput setaf 2)
#YELLOW=$(tput setaf 3)
#BLUE=$(tput setaf 4)
#MAGENTA=$(tput setaf 5)
#CYAN=$(tput setaf 6)
#WHITE=$(tput setaf 7)
#RESET=$(tput sgr0)

# Important Function (Not really)
function msg () {
    echo "$1"
}

# Cached Function

function datetime () {
    MONTH_DATE_YEAR=$(date +%m-%d-%y)
    TIMECOUNT=$(date +%T)
    msg "$MONTH_DATE_YEAR $TIMECOUNT"
}

function extract () {
    #7za x pack/pak.7z.001
    echo "Checking your Device"
    case $(uname -m) in
        aarch64)
            msg "Detected Aarch64, if you are running this on PRoot-termux, then the install may be sucessful but there may be no way to launch it under smooth conditions"
            7za x pack/ARM64/pak_arm64.7z.001
            ;;
        armhf)
            msg "Detected ARM32, if you are running this on PRoot-termux, then the install may be sucessful but there may be no way to launch it under smooth conditions"
            7za x pack/ARMHF/pak_armhf.7z.001
            ;;
        x86_64)
            7za x pack/AMD64/pak_amd64.7z.001
            ;;
        *)
            echo "Your Architecture : $(uname -m), is not supported..."
            sleep 10
            menu
            ;;
    esac
}
function install () {
    case $(uname -m) in
        aarch64)
            sudo apt install -y ./vs_arm64.deb
            ;;
        armhf)
            sudo apt install -y ./vs_armhf.deb
            ;;
        x86_64)
            sudo apt install -y ./vs_amd64.deb
            ;;
    esac        
    #sudo apt install -y ./pak.deb
}

function clean () {
    rm -rf *.deb
}

function remove () {
    sudo apt remove code -y
}

function chk_spc () {
    case $(uname -m) in
        x86_64)
            msg "AVAILABLE for 64 Bit: $(cat pack/VERSION_AMD64)"
            ;;
        aarch64)
            msg "AVAILABLE for ARM64: $(cat pack/VERSION_ARM64)"
            ;;
        armhf)
            msg "Available for ARM7 Hard Float: $(cat pack/VERSION_ARM32)"
            ;;
        *)
            msg "UNAVAILABLE"
            BLOCK=1
            ;;
    esac
}

function chk_ist () {
    if [ -e "/usr/bin/code" ] && [ -e "/usr/share/code" ]; then 
        msg "Installed"
    else 
        msg "Not Installed"
    fi
}

# Check Packages
packages=("7za" "dialog")
for pkg in "${packages[@]}" ; do
    msg "$(datetime) : Checking if you have: $pkg"
    sleep 1
    cmd=$(command -v "$pkg" 2>/dev/null)
    if [ -n "$cmd" ]; then 
        msg "$(datetime) : $pkg Exits, Located at: '$cmd'"
    else
        msg "$(datetime) : Package $pkg not installed, please install it using 'sudo apt install $pkg' then continue"
        sleep 3
        exit 1
    fi
done
sleep 2
clear

function welcome () {
    dialog --infobox "VS Code Installer\n\nNot Related to Microsoft Whatsoever, but here to let you install VS Code anyways..." 0 0 
    sleep 5
    agree
}

function agree () {
    dialog --backtitle "Microsoft Visual Studio Code License Terms" --title "VS Code License Agreement" --yes-label "Agree to Microsoft License Agreement" --no-label "Exit" --yesno "$(cat lc/MS.txt)" 0 0 
    lcx=$?
    case $lcx in
        0)
            menu 
            ;;
        1)
            exit 1
            ;;
    esac  
}

# Menu 
function menu () {
    menu=$(dialog \
            --backtitle "VS Code Package Manager By SUFandom" \
            --title "Main Menu" \
            --clear \
            --menu "Choose an Option" 0 0 0 \
            "Install" "Install VS Code from Microsoft. Status: $(chk_spc)" \
            "Remove" "Status: $(chk_ist) : Removes MS VSCode" \
            "About" "About" \
            2>&1 >/dev/tty)
    lcx=$?
    case $lcx in 
        1)
            exit 1
            ;;
    esac 
    case $menu in 
        "Install")
            if [ "$BLOCK" == 1 ]; then
                dialog --msgbox "Your Host doesn't support VS Code Bundled in to the offline installer..." 0 0
                menu
            fi
            clear
            msg "This Process Job is set in Verbose to ensure Stability..."
            msg "Starting Process..."
            sleep 3
            extract
            install 
            clean 
            msg "Done..."
            sleep 3
            menu
            ;;
        "Remove")
            clear
            remove 
            ;;
        "About")
            dialog --backtitle "About" --title "VS Code Installer About" --msgbox "VS Code Package Manager by SUFandom\n\nVersion 1.1\n\nThis script's purpose is just simply install Microsoft's VS Code Easily...\n\nRead Microsoft's License about VS Code in here:\nhttps://code.visualstudio.com/license?lang=en\n\nWHATS NEW:\n- Support for three Architectures (armhf, arm64, x86_64)" 0 0
            menu 
            ;;
    esac

}

# Init Area
# DONOTADD ANYTHING
welcome
