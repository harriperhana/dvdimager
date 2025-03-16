# Why?
Somehow I have ended up to own a quite large collection of DVD movies but doesn't really have any convenient way to watch em. So instead of everytime setting up my laptop - which have the only household optical drive - with external screen I just make an image of the movie so I can stream it through my network and watch it with any device. So with this script it's more straightforward to make the image and even do a whole bunch at one time.

# Usage
The only prerequisite is `dd`, which you most probably already have, but in case it's missing, you must install it first.

- Debian  
`apt install coreutils`
- Arch  
`pacman -S coreutils`
- Fedora  
`dnf install coreutils`
- CentOS  
`yum install coreutils`
- openSUSE  
`zypper install coreutils`

After you have satisfied the requirements, just set the script executable with `chmod +x dvdimager.sh` and start destroying disks!

Script defaults using `/dev/cdrom` symlink, but if you have multiple drives you can pass wanted one with parameter, for example...
```
./dvdimager.sh sr1
```