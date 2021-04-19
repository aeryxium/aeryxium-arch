# aeryxium-arch
A set of proof-of-concept packages designed to demonstrate and test the power of the Arch Build System. With only a few small tweaks (for example, actually setting user passwords which is fairly trivial to implement), these packages show how an entire Arch install can be replicated by passing a single package to `pacstrap`.

## Licensing and Warranty
This entire repo is licensed under GPLv3, it is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Everything in this repo is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

A copy of the GNU General Public License is included with this repo.

## Project Background
I frequent the r/archlinux subreddit and frequently see people trying to come up with ways to try and reproduce their builds. Given that I have a simple home server configured as a DHCP/DNS/FTP/File server which I had created a metapackage for to reproduce, I decided to test expanding this concept into a broader space. I've been toying with the idea of creating a series of tutorials and general Arch/Linux information and this seemed like a perfect end-goal for such a series as it encompasses everything I was hoping to cover: basic Linux shell commands, shell scripting, sed and awk, bootloaders, networking, desktop environments and window managers, custom service files and drop-ins, using the AUR, hosting a personal repo, maintaining PKGBUILDs, writing custom metapackages, etc. Despite being the end-goal, I decided to tackle this first as it will likely take the longest to complete and also serve as the motivation for what can be done with the basic tools.

This is not designed as a replacement to the traditional installation process described on the wiki. Rather, this is for advanced users that are already familiar with the install process, working on the command line, the `pacman` package manager, building AUR packages, writing their own custom PKGBUILDs and simple scripting. If you attempt to use these as a framework for your own installs when you aren't already capable of completing a manual install easily or if you don't understand what the commands you are typing during that process do, you are going to have a bad time and will almost ceratinly be unable to get any help at all with it. **These packages should not be used in their current state without modification to suit your own environment.**

In choosing what packages to use and how to configure the system, I made a few simple observations on what people were frequently asking about:

1. Server discussions:
   - Network gateway:
	 - Ad blocking
	 - DNS server
	 - VPN server
     - DHCP server
   - Media server:
     - Plex or other streaming service
	 - Media organization like sonarr/radarr/etc
     - Reverse proxy
	 - Samba fileserver
     - Torrent and usenet clients
2. Workstation discussions:
   - Bootloader
   - Networking
   - Installing WM/DE
   - Gaming (steam, etc.)
   - Graphics
3. Additional topics:
   - Backups
   - Docker or other containers
   - Dotfiles
   - Encryption
   - LVM
   - Snapshots for rolling-back
   - Split tunnelling of some variety
   - SSH
   - TOR
   - Webserver

Obviously some of these tasks overlap; both servers and workstations need to have a bootloader configured, for example. Also some of these concepts I did not bother to review for various reason. For example, I see LVM as a bit of a dinosaur and I haven't used it in many, many years, so I focused on btrfs and how it handles snapshots instead. But if LVM fits your use-case, this proof-of-concept still applies and your own fork could be adopted. I can't think of anything you may need that couldn't be implemented in the method I demonstrate here. Other topics are easily build with easy reproducibility in mind, so they aren't touched on here (for example, docker/containerization).

## Hardware Limitations
The experiment is also limited to hardware I have available for testing (i.e. not my own personal daily-use systems that I would rather not disturb). I have access to a handful of difference machines that I can toy with:

1. Intel NUC
2. Xeon-based fileserver with dedicated ZFS storage pools
3. Intel-based desktop with access to both AMD and Nvidia GPUs
4. Lenovo X220 laptop
5. Lenovo X1 Extreme Gen 2

## Implementation
As this is a general proof-of-concept and educational tool, the division of labour chosen may not entirely make sense in your environment, or indeed in any environment, but I based these decisions on my own experience in IT, in working with large multi-user environments in academia, and my own personal usage. I also wanted to modularize the process as much as possible which means some packages are very simple, while others are pretty complex. My logic was that no duplication of any kind should exist if it was at all possible to avoid it. To that end, I have separated everything out in a way that made the most sense to me while trying to cover the bulk of the complex topics to prove how they can work. In an effort to try and cover as many of the things I observed commonly discussed and that I felt relevant, I decided to create a simulated environment with the following specific machines and requirements:

1. Network gateway (headless)
   - Firewall
   - Encrypted DNS server with caching and ad-blocking
   - Internal DHCP server handling static IPs and reservations
   - Reverse proxy
   - Public Key Infrastructure
   - Certbot Certificate Management
   - VPN server
2. Media and fileserver (headless)
   - Configure/import ZFS storage pools
   - Samba server
   - WebDAV server
   - Plex Server
   - Sonarr/Radarr/Lidarr/Mylar3
   - VPN client with split tunnel
   - Deluge through VPN with web access
   - NZBGet
3. Desktop workstation
   - Dedicated GPU
   - 2D/3D hardware acceleration
   - bspwm with basic application set
   - Gaming with steam (and Dwarf Fortress, obviously)
4. Laptop workstation
   - Hybrid GPU with switching
   - 2D/3D hardware acceleration
   - Enhancements for battery life
   - bspwm with basic application set
   - Gaming with steam (and Dwarf Fortress, obviously)
   - Full-disk LUKS encryption with yubikey

To demonstrate how packages can be customized for specific hardware, the laptop workstation project has multiple implementations. In my case, I have one specific for my X220 and another specific for my X1 Extreme Gen 2. I could have left hardware-specific packages to the user to install, but I decided to include everything in the proof-of-concept. What works best in each specific case for an individuals specific hardware availability will need to be determined by the user.

## Automation Concepts
You might be wondering, "How did you account for the hardware differences? Do you just install everything on every machine and configure only what you need?" That's certainly one way. This is actually the biggest limitation of the project actually. Dependencies can't be changed at install time, they have to be determined when the package is created. To avoid having to duplicate packages just to account for hardware differences (for example, to avoid needing two different identical desktop PKGBUILDs to ensure the right CPU microcode gets installed), I simply established a set of `depends` and `provides` that allow for the flexibility.

If you simply mount your partitions and try to `pacstrap` a high-level package from this repo, you'll be prompted when multiple packages satisfy a dependency. So you'll be asked, for example, if you want to install the Intel CPU microcode or the AMD CPU microcode, or if you want AMD-based graphics support, Nvidia-based graphics support, or Intel-based graphics support. Certainly what hardware exists on the system is easily determined by a script, but this is simply a limitation of the Arch Build System. It is my goal to also have an "install script" to accompany these packages that will handle this automatically, but at the moment that project is just an idea. Even still, the idea that you don't need a script, but can still fully reproduce your install is certainly a nice fallback, even if you do have to answer a few questions.

## AUR Packages
Some packages depend on AUR packages being available to `pacman`. This is best done by using a hosting custom repository. AUR packages required are listed below and are added as submodules to this repo. To clone them as well, use `git submodule update --init --reursive --remote`. To update them to the latest version if you already cloned them, use `git submodule update --recursive --remote`.

* aeryxium-devel
  * aurutils: helper tools for the arch user repository
  * repoctl: an AUR helper that also simplifies managing local Pacman repositories

## A Note on Backups
It's important to note as well that this method or recreating installs is not a substitute for good backups. The objective here is to be able to install your exact system from scratch, including all your configurations. My samples here do not include user data. For example, the Sonarr database will be empty even if the ZFS storage pool imports with whatever media is on it that Sonarr was tracking. You could, of course, include backups as part of this concept, but I prefer not to. Rather, any personal data that would need to be imported manually is simply displayed in a MOTD. Some may find this to be an unacceptable method of reproducing an install... so be it. My objective wasn't to avoid doing backups, but rather to be able to make a fresh, clean install of my machine to which I would copy over from backups only that data I wanted copied over. I realize that logic is more prevalent on Windows, where semi-frequent reinstalls are needed to keep things clean, but I still occasionally found myself wanting to do the same with a Linux system for a variety of reasons. It can't be stressed enough:

### 1. Make frequent, multiple backups

### 2. Test your backups regularly

### 3. Keep at least of your backup copies offsite
