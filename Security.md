[<< Back to README](readme.md)

# Security

This page is dedicated on the technical use case of SuperUser password Handling

If you don't like it, then please don't use the repo, for better solution

This repo is always transparent when handling sensitive data, which is the sudo password

This is the line code that implement such:

``` 
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
```

As you can see, the binary software that i used is dialog, a TUI Software that may not require a windowing session except if its launched on Terminal Emulators

I could use `zenity` but this method is better because all of it are in the terminal session, in which `zenity` usually take 3 seconds just to load a License Agreement and i personally feel it's annoying

Well, as for the passwords, the variables that handle the passwords get cleared out by `unset` which is a tool to remove variables like it doesn't exist. So its a minimum guarantee that your sudo password isn't compromised. Unless you `|` (piped) it

