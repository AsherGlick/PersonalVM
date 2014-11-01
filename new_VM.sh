#!/bin/bash
#################################### LICENSE ###################################
# Copyright (c) 2014, Asher Glick                                              #
# All rights reserved.                                                         #
#                                                                              #
# Redistribution and use in source and binary forms, with or without           #
# modification, are permitted provided that the following conditions are met:  #
#                                                                              #
# * Redistributions of source code must retain the above copyright notice,     #
# this                                                                         #
#   list of conditions and the following disclaimer.                           #
# * Redistributions in binary form must reproduce the above copyright notice,  #
#   this list of conditions and the following disclaimer in the documentation  #
#   and/or other materials provided with the distribution.                     #
#                                                                              #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   #
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE    #
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR          #
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF         #
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS     #
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN      #
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)      #
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE   #
# POSSIBILITY OF SUCH DAMAGE.                                                  #
################################################################################



################################ Welcome Message ###############################
# Display a simple welcome message to the user telling them that they need to  #
# run the command that this script prints in order to complete the             #
# instalation of the new VM                                                    #
################################################################################
dialog --msgbox "\n     Building Install Commandfor a new VM\n      Command will be printed at the end" 8 50



########################## Get the name of the new VM ##########################
# Prompt the user to enter the desired name of their new Virtual Machine       #
################################################################################
VM_name=`dialog --stdout --inputbox "New VM Name" 10 40`
if [ -z "$VM_name" ]
then 
	exit
fi



############################# Get the Install Image ############################
# Prompt the user for which instal image they want to use from the             #
# `/var/lib/libvirt/images/` folder                                            #
################################################################################
files=`ls /var/lib/libvirt/images/`

dialog_options=()

# window height and width still need to be messed with
title="Pick an instalation image"
window_height="30"
menu_width="0"
menu_height="30"

for fn in $files; do
	size=${#fn}
	if [ $size -gt $menu_width ]; then
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



################################ Get the OS Type ###############################
# Have the user select which general os type is being used, Linux, Unix, or    #
# Windows. This is used for optimizations of the VM                            #
################################################################################
VM_OS_type=`dialog --stdout --menu "Pick the OS Type" 10 30 4 'linux' '_' 'unix' '_' 'windows' '_'`
if [ -z "$VM_OS_type" ]
then 
	exit
fi



############################## Get the OS Varient ##############################
# Get the variant of the OS that is being used. This provides further          #
# optimizations for the VM. I am not sure what to do if the desired OS is not  #
# on the list nor how this selection relates to the OS Type                    #
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



########################## Get the RAM Allocation Size #########################
# Prompt the user to enter how much RAM should be allocated to this VM (in MB) #
################################################################################
VM_RAM_allocation=`dialog --stdout --inputbox "Memory Allocated (MB)" 8 40 "512"`
if [ -z "$VM_RAM_allocation" ]
then 
	exit
fi



###################### Get the Hard Drive Allocation Size ######################
# Prompt the user to enter how much Hard Drive space should be allocated to    #
# this VM (in GB)                                                              #
################################################################################
VM_HDD_allocation=`dialog --stdout --inputbox "Harddrive Allocation (GB)" 8 40 "20"`
if [ -z "$VM_HDD_allocation" ]
then 
	exit
fi


################################################################################
################## Display the generated command to the user ###################
################################################################################
echo "" # create some space
echo "" # create some space
echo virt-install \
	--name=${VM_name} \
	--arch=x86_64 \
	--vcpus=1 \
	--ram=${VM_RAM_allocation} \
	--os-type=${VM_OS_type} \
	--os-variant=${VM_variant} \
	--hvm \
	--connect=qemu:///system \
	--network bridge:br0 \
	--cdrom=/var/lib/libvirt/images/${VM_instalation_image} \
	--disk path=/mnt/virtual_machines/${VM_name}.img,size=${VM_HDD_allocation} \
	--graphics vnc,keymap=en-us \
	--noautoconsole \
	--accelerate


################################### SIGNATURE ##################################
#                                      ,,                                      #
#                     db             `7MM                                      #
#                    ;MM:              MM                                      #
#                   ,V^MM.    ,pP"Ybd  MMpMMMb.  .gP"Ya `7Mb,od8               #
#                  ,M  `MM    8I   `"  MM    MM ,M'   Yb  MM' "'               #
#                  AbmmmqMA   `YMMMa.  MM    MM 8M""""""  MM                   #
#                 A'     VML  L.   I8  MM    MM YM.    ,  MM                   #
#               .AMA.   .AMMA.M9mmmP'.JMML  JMML.`Mbmmd'.JMML.                 #
#                                                                              #
#                                                                              #
#                                  ,,    ,,                                    #
#                      .g8"""bgd `7MM    db        `7MM                        #
#                    .dP'     `M   MM                MM                        #
#                    dM'       `   MM  `7MM  ,p6"bo  MM  ,MP'                  #
#                    MM            MM    MM 6M'  OO  MM ;Y                     #
#                    MM.    `7MMF' MM    MM 8M       MM;Mm                     #
#                    `Mb.     MM   MM    MM YM.    , MM `Mb.                   #
#                      `"bmmmdPY .JMML..JMML.YMbmd'.JMML. YA.                  #
#                                                                              #
################################################################################