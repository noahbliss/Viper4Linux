# Viper4Linux
At long last! Viper4Linux!

Disclaimer: 
I am not associated with the awesome mates over at Viper. I wish I was, but it is what it is. (Jason, you're particularly awesome.)  You can find their git here: https://github.com/vipersaudio  and their site here: http://vipersaudio.com/blog/  

While all my software is free (GPL), theirs is not. This (my) software makes use of their non-free libraries. I have kept these libraries separate from this code, but it is dependent on them. You can find all the necessary instructions below. 

# Installation
I hope to release a script shortly that will automate installation, but alas, I am busy...

Step 1:  
  Get the build-essential or similar package installed. You will be compiling their gstreamer plugin.  
  You will also need gstreamer-1.0 (not gstreamer, and not gstreamer-0.10)  
  
  For Debian:  
  
    apt-get install build-essential  
    apt-get install gstreamer-1.0 

Step 2:  
  Get this software and their software, and more of their software...  
  (You will be using a fork of their gstreamer software. Feel free to compare it, I only changed one line.)  
  
    git clone https://github.com/L3vi47h4N/Viper4Linux.git  
    git clone https://github.com/L3vi47h4N/gst-plugin-viperfx  
    git clone https://github.com/vipersaudio/viperfx_core_binary.git  
  
Step 3:  
  Build the gstreamer plugin.  

    cd gst-plugin-viperfx  
    ./autogen.sh  
    make  
    cd src/.libs
    #Don't ask me why it is built into a hidden directory >.<
  
  You now need to install the plugin. The install path is different on different systems. On my Debian, it was located at /usr/lib/x86_64-linux-gnu/gstreamer-1.0/. Yours should have a ton of libgst*.so files in it.  
  
    sudo cp libgstviperfx.so /usr/lib/x86_64-linux-gnu/gstreamer-1.0/
    cd ../../.. #I think that should get us back to our main git directory.
    #Now test it with gst-inspect-1.0
    gst-inspect-1.0 viperfx
    
  If this doesn't return a ton of options related to viper, then check the permissions on the file that they match the other files. If they do, double check that the plugin compiled properly.  
  
Step 4:  
  Install the main library file. (this will be copied with a different name! Do not keep the original name!)
    
    sudo cp viperfx_core_binary/libviperfx_x64_linux.so libviperfx.so
  
Step 5: (optional)  
  Delete the uneeded git repos to free space.  
  
    rm -rf viperfx_core_binary gst-plugin-viperfx
    
Step 6:  
  Configure the system by installing the configs.  
  This will be what makes the magic work.  
    
    cd Viper4Linux
    cp -r viper4linux ~/.config  
    
  Install viper (the executable bash file) into your path somewhere.
  
    #Just pick one.
    cp viper ~/bin #requires ~/bin to be in $PATH
    sudo cp viper /usr/local/bin
    #/usr/bin and /bin will also work. *shrug*
    
# Configuration  
Most of your configuration will be done in ~/.config/viper4linux with the following two files:  
  
  devices.conf -- More to come on this as I dev more, but right now it is just one line with location=$your_alsa_sink_path_here 
    (more to come on how to make this)  
 
  audio.conf -- This is where you configure how Viper behaves with all the cool bass boosting, reverb, clarity mods, etc.  
    You can find out what accepted values you can use here by running gst-inspect-1.0 viperfx. I have included all the known options for the plugin with mostly default values in the template file. 
  
  Both of these files are sourced by shell, so keep your dirty spaces, backdoors, etc, out of them. ;P  
  
  
# Running  
viper(.sh) has four options right now, `start`, `stop`, `restart`, and `status`. These probably do exactly what you think they do.  
Viper will need to be restarted every time a setting is changed. (Sorry).

I leverage pulseaudio and null sinks to do my work. Pulseaudio is somewhat... delicate. If you switch outputs after starting Viper, things may break. running `viper restart` should resolve this and I hope to code in contingencies in the future.  

# Final Notes  
I am not a great developer, just tossing this out there and if someone finds it useful, I will be happy. If you have improvements, please submit a DETAILED pull request. Everyone benefits from shared expertise. Thanks!
