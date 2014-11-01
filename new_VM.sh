#!/bin/bash


dialog --msgbox "\n     Building Install Commandfor a new VM\n      Command will be printed at the end" 8 50

################################################################################
# Name
################################################################################

VM_name=`dialog --stdout --inputbox "New VM Name" 10 40`
if [ -z "$VM_name" ]
then 
	exit
fi

################################################################################
# Select instalation image
################################################################################

files=`ls /var/lib/libvirt/images/`

dialog_options=()

# window height and width still need to be messed with
title="Pick an instalation image"
window_height="30"
menu_width="0"
#window_width=$((`tput cols`-70))
#window_width=$window_width - 2
menu_height="30"

for fn in $files; do
    size=${#fn}
    if [ $size -gt $menu_width ]; then
        echo "larger"
        menu_width=$size
    fi
    dialog_options+=($fn)
    dialog_options+=("_")
done

# add the framing and padding to the width
window_width=$(($menu_width + 8))

VM_instalation_image=`dialog --stdout --menu "$title" $window_height $window_width $menu_height ${dialog_options[@]}`
if [ -z "$VM_instalation_image" ]
then 
	exit
fi



###################
# Get the OS Type #
###################
VM_OS_type=`dialog --stdout --menu "Pick the OS Type" 10 30 4 'linux' '_' 'unix' '_' 'windows' '_'`
if [ -z "$VM_OS_type" ]
then 
	exit
fi


################################################################################
# Get the list of os variants #
################################################################################
IFS=$'\n'
osvariants=(`virt-install --os-variant list`)
variant_options=()
longest_tag=0
longest_name=0


for variant in ${osvariants[@]};  do
    tag=`echo "$variant" | sed -e "s/ .*//g"`
    name="`echo \"$variant\" | sed -e \"s/.*: //g\"`"
    tag_length=${#tag}
    name_length=${#name}
    if [ $tag_length -gt $longest_tag ]; then
        longest_tag=$tag_length
    fi
    if [ $name_length -gt $longest_name ]; then
        longest_name=$name_length
    fi
    variant_options+=($tag)
    variant_options+=($name)
done


window_width=$((8 + $longest_tag + $longest_name))

VM_variant=`dialog --stdout --menu "Pick the OS Variant" $window_height $window_width $menu_height ${variant_options[@]}`

unset IFS

if [ -z "$VM_variant" ]
then 
	exit
fi



######################
# Get ram allocation #
######################

VM_RAM_allocation=`dialog --stdout --inputbox "Memory Allocated (MB)" 8 40 "512"`
if [ -z "$VM_RAM_allocation" ]
then 
	exit
fi


############################
# Get HDD Space Allocation #
############################

VM_HDD_allocation=`dialog --stdout --inputbox "Harddrive Allocation (GB)" 8 40 "20"`
if [ -z "$VM_HDD_allocation" ]
then 
	exit
fi


################################################################################
# Display the command to the user so they can run it themselves
################################################################################
echo ${hddallocation}
echo ${ramallocation}

echo virt-install \
    --name=${VM_name} \
    --arch=x86_64 \
    --vcpus=1 \
    --ram=512 \
    --os-type=linux \
    --os-variant=debianwheezy \
    --hvm \
    --connect=qemu:///system \
    --network bridge:br0 \
    --cdrom=/var/lib/libvirt/images/${VM_instalation_image} \
    --disk path=/mnt/virtual_machines/${VM_name}.img,size=20 \
    --graphics vnc,keymap=en-us \
    --noautoconsole \
    --accelerate
