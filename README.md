# MecDrumsAlarm
A drum rotation addon for the 2.4.3 and 2.5.2 WoW TBC clients. In order for this addon to work, the other members of your raid must also have it installed. The addon only works in raids.

# Installation

[Download the ZIP file of the lastest release here and put them into the Addons folder of your WoW installation.](https://github.com/MecAtlantiss/MecDrumsAlarm/releases/latest)

If the addon doesn't appear in-game, then you likely put the wrong folder into your Addons folder.

# Commands

/mda  
/mecdrumsalarm

# Settings

You must select a drum type of Drums of Battle, Drums of Restoration, Drums of War, or None. Selecting None will hide the addon. By default, the addon will select Drums of Battle.

You can also choose whether or not you want on-screen messages and/or sounds that alert you when it is your turn to drum.

# How it works

This addon will collaborate information relevant to a drum rotation between raiders and party members by sending out information to the raid and party every 1 second. The rotation will be automatically calculated by the addon and you cannot override the rotation. It will attempt to gracefully handle disruptive events, such as players dying, being swapped into different groups temporarily to bloodlust/heroism, disconnecting, having no drums in inventory, etc.

In an effort to avoid spamming you with alerts during trash fights, it is setup to detect important combats by looking for DBM pull timers, or party members drumming, or someone attacking one of the TBC raid bosses. Once the addon detects a pull, it will enable the on-screen and sound alerts.
