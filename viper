#!/usr/bin/env bash
configpath=$HOME/.config/viper4linux
audiofile=$configpath/audio.conf
devicefile=$configpath/devices.conf
tmppath=/tmp/viper4linux
idfile=$tmppath/sinkid.tmp
pidfile=$tmppath/pid.tmp
logfile=$tmppath/viper.log
mkdir -p $configpath
mkdir -p $tmppath

start () {
	declare $(head -n1 $devicefile) #get location and desc from file
	if [ -f $pidfile ]; then kill $(< $pidfile); fi
	if [ -f $idfile ]; then
		oldid=$(< $idfile)
		pactl unload-module $oldid
	fi
	idnum=$(pactl load-module module-null-sink sink_name=viper sink_properties=device.description="Viper4Linux")
	echo $idnum > $idfile
	echo "Setting original sink to full volume..."
	pactl set-sink-volume $location 1.0
	echo "Changing primary sink to Viper..."
	pactl set-default-sink viper
	source $audiofile
	gst-launch-1.0 -v pulsesrc device=viper.monitor ! viperfx \
        fx-enable="$fx_enable" conv-enable="$conv_enable" conv-ir-path="$conv_ir_path" conv-cc-level="$conv_cc_level" vhe-enable="$vhe_enable" vhe-level="$vhe_level" vse-enable="$vse_enable" vse-ref-bark="$vse_ref_bark" vse-bark-cons="$vse_bark_cons" eq-enable="$eq_enable" eq-band1="$eq_band1" eq-band2="$eq_band2" eq-band3="$eq_band3" eq-band4="$eq_band4" eq-band5="$eq_band5" eq-band6="$eq_band6" eq-band7="$eq_band7" eq-band8="$eq_band8" eq-band9="$eq_band9" eq-band10="$eq_band10" colm-enable="$colm_enable" colm-widening="$colm_widening" colm-depth="$colm_depth" ds-enable="$ds_enable" ds-level="$ds_level" reverb-enable="$reverb_enable" reverb-roomsize="$reverb_roomsize" reverb-width="$reverb_width" reverb-damp="$reverb_damp" reverb-wet="$reverb_wet" reverb-dry="$reverb_dry" agc-enable="$agc_enable" agc-ratio="$agc_ratio" agc-volume="$agc_volume" agc-maxgain="$agc_maxgain" vb-enable="$vb_enable" vb-mode="$vb_mode" vb-freq="$vb_freq" vb-gain="$vb_gain" vc-enable="$vc_enable" vc-mode="$vc_mode" vc-level="$vc_level" cure-enable="$cure_enable" cure-level="$cure_level" tube-enable="$tube_enable" ax-enable="$ax_enable" ax-mode="$ax_mode" fetcomp-enable="$fetcomp_enable" fetcomp-threshold="$fetcomp_threshold" fetcomp-ratio="$fetcomp_ratio" fetcomp-kneewidth="$fetcomp_kneewidth" fetcomp-autoknee="$fetcomp_autoknee" fetcomp-gain="$fetcomp_gain" fetcomp-autogain="$fetcomp_autogain" fetcomp-attack="$fetcomp_attack" fetcomp-autoattack="$fetcomp_autoattack" fetcomp-release="$fetcomp_release" fetcomp-autorelease="$fetcomp_autorelease" fetcomp-meta-kneemulti="$fetcomp_meta_kneemulti" fetcomp-meta-maxattack="$fetcomp_meta_maxattack" fetcomp-meta-maxrelease="$fetcomp_meta_maxrelease" fetcomp-meta-crest="$fetcomp_meta_crest" fetcomp-meta-adapt="$fetcomp_meta_adapt" fetcomp-noclip="$fetcomp_noclip" out-volume="$out_volume" out-pan="$out_pan" lim-threshold="$lim_threshold" \
	! pulsesink device="$location" > $logfile &
	echo $! > $pidfile
}

stop () {
        if [ -f $pidfile ]; then 
		kill $(< $pidfile)
		rm $pidfile
		echo "Killed gstreamer process."
	fi
        if [ -f $idfile ]; then
                oldid=$(< $idfile)
                pactl unload-module $oldid
		rm $idfile
		echo "Unloaded Viper sink."
        fi
}

restart () {
	start
}

status () {
	echo "Not yet fully implemented."
	if [ -f $pidfile ]; then echo "There is a pidfile. Gstreamer may be running at pid: $(< $pidfile)."; else echo "No pidfile found. (likely stopped)"; fi
	if [ -f $idfile ]; then echo "There is an idfile. The viper sink seems to be loaded at id: $(< $idfile)."; else echo "No idfile found. (likely stopped)"; fi
}

$@
