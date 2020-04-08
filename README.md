# Picture Changer

## Using the existing Framed Picture Changer

Drop textures in the central display, that's it :)

Click on the picture to show next one.

To customize the display, click on the frame to show the menu.

* □ **Public** - Permit everyone to drop textures and click to change current picture (shared display)
* □ **Fade** - Fade out/in during picture change
* □ **Bright** - Set the picture fullbright (not dependant of environment lights)
* □ **Chat** - Tells in local chat the name of the current picture when it changes
* ***TIMER** - Shows the timer menu
  * **10s**, **20s**, **40s** - Wait the number of seconds between two pictures
  * **1m**, **2m**, **5m**, **10m**, **20m**, **40m** - Wait the number of minutes between two pictures
  * **Default** - Revert to default (1 minute)
  * **Off** - Disable timer (picture change is manual only)
* ***LIST** - Shows the pictures list menu, permitting to select the current one
* **◀** / **▶** - Shows previous/next picture
* **Reset** - Reset the script (default values)

## Using the script on another build

The top of the script contains a few variables made to adapt to other builds than the provided Framed Picture Changer.

**PICTURE_LINK** is the link number of the prim that will contain the picture display. **PICTURE_FACE** the face on which in will appear. By default, the script is provided with an invalid face to be sure the script is modified before it is used.

**CACHE_LINK** is optional (should have value `-1` if not used), and if used, represents the link number where an 8-faces object will serve as cache to pre-load pictures.

