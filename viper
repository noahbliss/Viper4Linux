#!/usr/bin/env bash
#Noah Bliss
configpath=$HOME/.config/viper4linux
fallbackconfigpath=/etc/viper4linux
if ! [ -d "$configpath" ]; then configpath="$fallbackconfigpath"; fi
audiofile=$configpath/audio.conf
devicefile=$configpath/devices.conf
tmppath=/tmp/viper4linux
idfile=$tmppath/sinkid.tmp
if [ -f $idfile ]; then oldid=$(< $idfile); fi
pidfile=$tmppath/pid.tmp
if [ -f $pidfile ]; then pid=$(< $pidfile); fi
logfile=$tmppath/viper.log
vipersink=viper
mkdir -p $configpath
mkdir -p $tmppath
# Make $configpath the working directory. This allows IRS and similar files to be referenced in configs without needing a path prefix. 
cd "$configpath"


start () {
	stop
	if [ -f $devicefile ]; then 
		declare $(head -n1 $devicefile) #get location and desc from file
	else
		#Do our best.
		location=$(pactl info | grep "Default Sink" | awk -F ": " '{print $2}')
		if [ "$location" == "$vipersink" ]; then echo "Something is very wrong (Target is same as our vipersink name)."; return; fi
	fi
	idnum=$(pactl load-module module-null-sink sink_name=$vipersink sink_properties=device.description="Viper4Linux")
	echo $idnum > $idfile
	echo "Setting original sink to full volume..."
	pactl set-sink-volume $location 1.0
	echo "Changing primary sink to Viper..."
	pactl set-default-sink $vipersink
	source $audiofile
	gst-launch-1.0 -v pulsesrc device=$vipersink.monitor volume=1.0 ! viperfx \
        fx-enable="$fx_enable" conv-enable="$conv_enable" conv-ir-path="$conv_ir_path" conv-cc-level="$conv_cc_level" vhe-enable="$vhe_enable" vhe-level="$vhe_level" vse-enable="$vse_enable" vse-ref-bark="$vse_ref_bark" vse-bark-cons="$vse_bark_cons" eq-enable="$eq_enable" eq-band1="$eq_band1" eq-band2="$eq_band2" eq-band3="$eq_band3" eq-band4="$eq_band4" eq-band5="$eq_band5" eq-band6="$eq_band6" eq-band7="$eq_band7" eq-band8="$eq_band8" eq-band9="$eq_band9" eq-band10="$eq_band10" colm-enable="$colm_enable" colm-widening="$colm_widening" colm-depth="$colm_depth" ds-enable="$ds_enable" ds-level="$ds_level" reverb-enable="$reverb_enable" reverb-roomsize="$reverb_roomsize" reverb-width="$reverb_width" reverb-damp="$reverb_damp" reverb-wet="$reverb_wet" reverb-dry="$reverb_dry" agc-enable="$agc_enable" agc-ratio="$agc_ratio" agc-volume="$agc_volume" agc-maxgain="$agc_maxgain" vb-enable="$vb_enable" vb-mode="$vb_mode" vb-freq="$vb_freq" vb-gain="$vb_gain" vc-enable="$vc_enable" vc-mode="$vc_mode" vc-level="$vc_level" cure-enable="$cure_enable" cure-level="$cure_level" tube-enable="$tube_enable" ax-enable="$ax_enable" ax-mode="$ax_mode" fetcomp-enable="$fetcomp_enable" fetcomp-threshold="$fetcomp_threshold" fetcomp-ratio="$fetcomp_ratio" fetcomp-kneewidth="$fetcomp_kneewidth" fetcomp-autoknee="$fetcomp_autoknee" fetcomp-gain="$fetcomp_gain" fetcomp-autogain="$fetcomp_autogain" fetcomp-attack="$fetcomp_attack" fetcomp-autoattack="$fetcomp_autoattack" fetcomp-release="$fetcomp_release" fetcomp-autorelease="$fetcomp_autorelease" fetcomp-meta-kneemulti="$fetcomp_meta_kneemulti" fetcomp-meta-maxattack="$fetcomp_meta_maxattack" fetcomp-meta-maxrelease="$fetcomp_meta_maxrelease" fetcomp-meta-crest="$fetcomp_meta_crest" fetcomp-meta-adapt="$fetcomp_meta_adapt" fetcomp-noclip="$fetcomp_noclip" out-volume="$out_volume" out-pan="$out_pan" lim-threshold="$lim_threshold" dynsys-enable="$dynsys_enable" dynsys-ycoeff1="$dynsys_ycoeff1" dynsys-sidegain1="$dynsys_sidegain1" dynsys-xcoeff1="$dynsys_xcoeff1" dynsys-bassgain="$dynsys_bassgain" dynsys-ycoeff2="$dynsys_ycoeff2" dynsys-sidegain2="$dynsys_sidegain2" dynsys-xcoeff2="$dynsys_xcoeff2" \
	! pulsesink device="$location" > $logfile &
	echo $! > $pidfile
	echo "Moving existing audio streams to Viper..."
	while read existing_sink; do pactl move-sink-input $existing_sink $vipersink; done < <(pactl list sink-inputs short | awk '{print $1}')
}

stop () {
        if [ -f $pidfile ]; then
		if ps -p $pid &>/dev/null; then kill $pid; murdercanary="Killed process."; else murdercanary="Looks like it was already dead...?"; fi
		rm $pidfile && pidcanary="Deleted pidfile."
		echo "$murdercanary $pidcanary"
        fi
        if [ -f $idfile ]; then
                pactl unload-module $oldid
		rm $idfile
		echo "Unloaded Viper sink."
        fi
}

restart () {
	start
}

status () {
	if [ -f $pidfile ]; then pidfilestatus="There is a pidfile.";
		if ps -p $pid &>/dev/null; then
		       	pidstatus="There is also a process running at pid $pid."
			running="[RUNNING]"; else
			pidstatus="However, there is no process running with the expected pid."
			running="[ERROR]"
		fi; else
		pidfilestatus="No process."
		running="[STOPPED]"
	fi
	if [ -f $idfile ]; then
		idfilestatus="There is an idfile. The viper sink seems to be loaded at id: $oldid."; else
		idfilestatus="No idfile found."
	fi
	echo "$running"
	echo "$pidfilestatus $pidstatus"
	echo "$idfilestatus"
}
$@
