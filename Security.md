[<< Back to README](readme.md)

# Security

This page is dedicated on the technical use case of SuperUser password Handling

If you don't like it, then run the code as sudo first for better security

This repo is always transparent when handling sensitive data, which is the sudo password

This is the line code that implement such:

``` 

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
```

As you can see, the binary software that i used is dialog, a TUI Software that may not require a windowing session except if its launched on Terminal Emulators

I could use `zenity` but this method is better because all of it are in the terminal session, in which `zenity` usually take 3 seconds just to load a License Agreement and i personally feel it's annoying

Well, as for the passwords, the variables that handle the passwords get cleared out by `unset` which is a tool to remove variables like it doesn't exist. So its a minimum guarantee that your sudo password isn't compromised. Unless you `|` (piped) it

