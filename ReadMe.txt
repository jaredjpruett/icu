How To Use
--------------------------------------------------------------------------------

Click on the tracked blip(s) in minimap to display a selectable popup menu
containing indepth details of the blip(s). Enemy faction players will be
immediately targeted and a message with information on your target will be
printed to the specified chat (default prints to party/raid/self, depending).

Move mouse cursor away from minimap or the popup to close the menu.

You may select from the popup menu to acquire the blip as target if it is still
within range. Then, a ping will be generated on the last known location of the
target, and your party will receive a message with information on your target.

Shift-click on the minimap to generate a normal ping.


Version History
--------------------------------------------------------------------------------

Version 1.4 (05 Dec 2017)
- Cleaned up modifications and refactored some existing code.

Version 1.3 (15 Sep 2013)
- Modified such that, upon clicking the blip of an enemy player on the minimap,
  said enemy player is automatically targeted and a message is printed to chat.

Version 1.2 (10 Feb 2005)
- Added ReadMe.txt
- Added health percentage to player targets in dialog display.
- Removed "PLAYER: -" from player targets in dialog display. ICU is made for
  PvP, too much information is not good.
- Tweaked somewhat, and added more comments. It seems declaring local global
  table causes memory leaks in LUA.
- Added ##OptionalDeps: MapNotes to the toc file. It should work with Cosmo
  MapNotes. Thanks to Diungo on curse-gaming.com

Version 1.1 (28 Jan 2005)
- Fixed bug with crashing when targetting indoor units.

Version 1.0 (26 Jan 2005)
- Initial release.


Known Issues
--------------------------------------------------------------------------------

This Addon works great as a targetting mechanism in PvP but very poorly in PvE.
A word of warning: refrain from clicking on a bunch of mob blips on the minimap 
while in combat. One to three mob blips should be fine. Otherwise, you may just
end up shooting something else and draw aggro.

TargetByName() works by taking a provided name string, and searches for the a
target nearest to the player. However, NPC names (mobs included) are NOT unique,
so you may see some odd behaviour when you attempt to target NPCs. This cannot
be helped unless Blizzard improved the targeting API.

As it is, this Addon provides sufficient advantages to the hunter class in PvP.
