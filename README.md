# Viper4Linux - An Adaptive Digital Sound Processor
Making Loonix sound good.  

## This Repo is feature frozen + maintenance. To open issues/request features/track latest dev go check out the [Audio4Linux repo](https://github.com/Audio4Linux)! 

Disclaimer:  
I am not associated with the awesome mates over at Viper. I wish I was, but it is what it is. (Jason, you're particularly awesome.)  You can find their git here: https://github.com/vipersaudio  and their site here: http://vipersaudio.com/blog/  

While all my software is free (GPL), theirs is not. This (my) software makes use of their non-free libraries. I have kept these libraries separate from this code, but it is dependent on them. You can find all the necessary instructions below. 

DOES NOT WORK WITH DEEPIN (very well). Check the [deepin](https://github.com/noahbliss/Viper4Linux/tree/deepin) branch for a patched version. (Props to [topjor](https://github.com/topjor) for this fix.) There is a bug in Deepin where any new audio streams are forced to go to the "default" output device even if they are specifically told to go elsewhere. Please harass the Deepin devs for me. 

# Installation
At this point I've given up on automating the installation process, but it isn't that bad really. If you're lazy, use Arch.  

## Packages

### Arch  
We have a package for Arch.  

    yay -S viper4linux-git  
    
We also have a package for the GUI! check it out at https://github.com/ThePBone/Viper4Linux-GUI.

  Stable package:
    
    yay -S viper4linux-gui
    
  Development package:

    yay -S viper4linux-gui-git
 
### Opensuse
We have a package for opensuse Leap 15.1 and opensuse Tumbleweed.
First you need to add the repos according to your version (in this example Tumbleweed is used).  

    sudo zypper ar https://download.opensuse.org/repositories/home:/bosconovic:/viper4linux/openSUSE_Tumbleweed/ viper  
   
Once you have added the repo, refresh the package list.  

    sudo zypper refresh
    
Now you're ready to install viper4linux.  

    sudo zypper in gstreamer-plugins-viperfx libviperfx viper4linux
    
There is also a package for the stable releases of the GUI (https://github.com/ThePBone/Viper4Linux-GUI).  

    sudo zypper in viper4linux-gui

## Manually

Step 1:  
  Get the build-essential or similar package installed. You will be compiling their gstreamer plugin.  
  You will also need gstreamer-1.0 (not gstreamer, and not gstreamer-0.10).  
  
  For Debian:  
  
    sudo apt install build-essential git autoconf libtool gstreamer1.0 libgstreamer-plugins-base1.0-dev gstreamer1.0-tools
    
  For Arch:  
  
    sudo pacman -S base-devel git gst-plugins-good 
  
  For Ubuntu the following packages are reported to be needed:  
  
    sudo apt install build-essential git autoconf automake autopoint libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev  
  
  For Solus the following packages are reported to be needed:  
  
    sudo eopkg it -c system.devel  
    sudo eopkg it gstreamer-1.0-devel gstreamer-1.0-plugins-base-devel  

  For Fedora:  
  
  (I don't currently support Fedora. That said, there are reports of it working. Thobi from the Telegram group mentioned needing the gstreamer1-plugins-base-devel.x86_64 package.)  

Step 2:  
  Get this software and their software, and more of their software...  
  
    git clone https://github.com/noahbliss/Viper4Linux.git  
    git clone https://github.com/Audio4Linux/gst-plugin-viperfx   
    git clone https://github.com/vipersaudio/viperfx_core_binary.git  
  
Step 3:  
  Build the gstreamer plugin.  
  
    cd gst-plugin-viperfx  
    cmake -B build -S .
    make -C build
    cd build
  
  You now need to install the plugin. The install path is different on different systems. On my Debian, it was located at /usr/lib/x86_64-linux-gnu/gstreamer-1.0/. Yours should have a ton of libgst*.so files in it.  

  Debian:  
  
    sudo cp libgstviperfx.so /usr/lib/x86_64-linux-gnu/gstreamer-1.0/  
  Arch:  
  
    sudo cp libgstviperfx.so /usr/lib/gstreamer-1.0/  
    
  The rest of it:  
  
    cd ../../.. #I think that should get us back to our main git directory.
    #Now test it with gst-inspect-1.0
    gst-inspect-1.0 viperfx
    
  If this doesn't return a ton of options related to viper, then check the permissions on the file that they match the other files. If they do, double check that the plugin compiled properly.  
  
Step 4:  
  Install the main library file. (this will be copied with a different name! Do not keep the original name!)
    
    sudo cp viperfx_core_binary/libviperfx_x64_linux.so /lib/libviperfx.so
  
  There are some distros that use different lib paths. For example, Solus wants the file to be placed at /usr/lib64/libviperfx.so. 
  
Step 5: (optional)  
  Delete the unneeded git repos to free space.  
  
    rm -rf viperfx_core_binary gst-plugin-viperfx
    
Step 6:  
  Configure the system by installing the configs.  
  This will be what makes the magic work.  
  **Note: Current V4L will attempt to use the current default output sink if it cannot find the devices.conf file. If you prefer this fallback behavior, then simply do not have a devices.conf file in the following path. 
    
    cd Viper4Linux
    cp -r viper4linux ~/.config  
    
  Install viper (the executable bash file) into your path somewhere.
  
    #Just pick one.
    cp viper ~/bin #requires ~/bin to be in $PATH
    sudo cp viper /usr/local/bin
    #/usr/bin and /bin will also work. *shrug*
    
# Configuration  

We have a GUI made by ThePBone which is available here: https://github.com/ThePBone/Viper4Linux-GUI  

Most of your configuration will be done in ~/.config/viper4linux with the following two files:  
  
  devices.conf -- More to come on this as I dev more, but right now it is just one line with:  
      `location=$your_alsa_sink_path_here`  
    If you have pactl available, you can find this information by using:  
      `pactl list sinks | grep "Name: " -A1`  
    The part you want is after the "Name: " section.  
    
   **Current V4L will attempt to use the current default output sink if it cannot find the devices.conf file. 
    

 
  audio.conf -- This is where you configure how Viper behaves with all the cool bass boosting, reverb, clarity mods, etc.  
    You can find out what accepted values you can use here by running gst-inspect-1.0 viperfx. I have included all the known options for the plugin with mostly default values in the template file. 
  
  Both of these files are sourced by shell, so keep your dirty spaces, backdoors, etc, out of them. ;P  
  
  
# Running  
viper(.sh) has four options right now, `start`, `stop`, `restart`, and `status`. These probably do exactly what you think they do.  
Viper will need to be restarted every time a setting is changed. (Sorry).

I leverage pulseaudio and null sinks to do my work. Pulseaudio is somewhat... delicate. If you switch outputs after starting Viper, things may break. running `viper restart` should resolve this and I hope to code in contingencies in the future.  

I did encounter an issue where audio would become intermittently choppy. If you also have this issue, try editing /etc/pulse/default.pa (as root) and adding the following line. If you already have this line, edit it, DO NOT MAKE A DUPLICATE. (things break.)  

  `load-module module-udev-detect tsched=0`  

# Final Notes  
I am not a great developer, just tossing this out there and if someone finds it useful, I will be happy. If you have improvements, please submit a DETAILED pull request. Everyone benefits from shared expertise. Thanks!  

Got a dope config? Don't like mine but don't want to make one yourself? Check out alternatives made by our community here! Feel free to submit a pull request with your own too!  
    https://github.com/noahbliss/Viper4Linux-Configs  

Got an idea? Comments/suggestions that aren't really appropriate for github? Want a community? Take a look at our Telegram group!  
    https://t.me/Viper4Linux

# Uninstallation  
(I always hate it when devs don't include this)  
To uninstall, remove the following files:  

    sudo rm $yourgstreamerlibpath/libgstviperfx.so
    sudo rm /lib/libviperfx.so
    sudo rm $(command -v viper)
    rm -rf ~/.config/viper4linux
    
Peace!

Shout-outs and stuff:  
We've got some cool people in our community. A few notable mentions follow below in no particular order.  

[ThePBone](https://github.com/ThePBone) - GUI development and work with the dynamic system.  
[yochananmarqos](https://github.com/yochananmarqos) - Work with the creation and maintenance of the AUR packages.  
@MaxFomo on Telegram. - AUR package creation and maintenance.  
[fcuzzocrea](https://github.com/fcuzzocrea) - OpenSuse package creation and maintenance.  
