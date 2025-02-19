# Commands
/mda  
/mecdrumsalarm

# Jargon
* Turn: A 30 second period following someone in the party drumming.  
* "Next drum": The maximum of the remaining turn duration and the lowest drum cooldown in the party.  
* Queue: The current state of the drum rotation based on the player client without consideration for suggestions from other party members.
* Synced Queue: The client's current understanding of the current state of the drum rotation based on recent suggestions from party members that came in through CHAT_MSG_ADDON events.
* Suggestions: The rotation data sent by party members to the player's client through SendAddonMessage. Suggestions received within the last 1.5 seconds are used to determine syncedQueue and syncedSecondsUntilNextTurn.  
* Pull: See "Definition and detection of a 'pull'" section. 
* Eligibility Status: See "Eligibility Statuses" section.

# Definition and detection of a "pull"
A "pull" is what this addon defines to be a combat deserving of having alerts shown, such as on-screen alert to drum and sound alerts. The purpose of this is to avoid the addon being annoying during non-important combats such as trash fights.

There are three different ways for how a pull can be detected
* DBM timer started
* Someone in party drummed using your configured drum item (e.g. Drums of Battle)
* A character in the raid did some action to a raid boss.

A pull is considered to be ended when the members in the player's party are all out of combat for at least 10 seconds.

# How synced queue and synced seconds until next turn are chosen
To determine the synced queue, we take suggestions received within the last 1.5 seconds, find the most popular queues by count, and then use the queue of highest count. In the case of a tie, the one last in the table is chosen.

To determine the synced "seconds until next turn", we take suggestions received within the last 1.5 seconds, group together suggestions that are within 2 seconds of each other, find the most popular of these clumps by counting them, and then use the one with highest count. In the case of a time, the one last in the table is chosen.

# High level of how the backend/core works
* Every 1 second, the player's client calculates what it believes is the correct state of the data the addon needs, such as the current rotation queue, time until next turn, and data on the player's character such as their drum cooldown and type.
* The player's client will receive drum type, drum cooldown, and eligibility status data from all the raiders in the group through CHAT_MSG_ADDON events. They will also receive suggested queue data from their party members which is inserted into the Rotation.recentSuggestions table.
* A player will consider themself to be "new to party" if they are switched into a new party. If they are returned to their original party within 10 seconds then will they will be not be considered "new" to that original party. However, if they were in the new party for more than 10 seconds then they are considered a official member of that new party.
* If the player is "Eligible" status, are the first person in queue to drum, and there's 5 seconds or less until the next drum should happen, then they will be "flagged to drum soon".
* There is a 2 second grace period that starts whenever the player is newly flagged to drum. This is to try to prevent the player from getting false positive sound and on-screen message alerts.

# High level of how the GUI works
* MasterFrame has an update script that runs every 0.25 seconds. It controls the entire GUI and is fed data from the Core scripts.
* Options in the ConfigUI frame can be setup using orderedConfigNames and configUIData in init.lua. MDA_CONFIG_DEFAULTS sets the default values of the addon's SavedVariable MDA_CONFIG.
* Frame positions are saved on player logout via EventsPlayerLogout.lua.

# Eligbility Statuses
Each raider determines their own "eligiblity status" and sends this information out to the other raiders every second. The possible statuses are as follows:

* Eligible: The player is capable of drumming, although they may be on cooldown.
* No response: If the player's client hasn't received a CHAT_MSG_ADDON from a particular raider in the last 5 seconds, then that raider is given a "No response" status.
* Drummed: The player drummed just a moment ago. This is a very brief status.
* Dead
* No drums: The player doesn't have drums in their inventory.
* New to party: The player was switched to a new party in the last 10 seconds.
* Unknown: This status means the raider hasn't yet sent their information to the player's client. Happens if a raider has never been online. Also happens briefly at the very start of the addon loading up.

# Queue calculation
Ineligible people are always placed at the end of queues.

Among eligible people, sort by drum cooldown.

In the event of a tie, sort by class priority. (see CLASS_ROTATION_PRIORITIES in Rotation.lua)

If there is still a tie, sort by character name alphabetically.

# 2.4.3 vs 2.5.2
All handling of differences between the 2.4.3 and 2.5.2 client are done in the TBC and TBCC folders respectively, particilarly in their API.lua files.

MecDrumsAlarm.toc handles the load order for the 2.4.3 client.

MecDrumsAlarm-BCC.toc handles the load order for the 2.5.2 client.
