// Picture Change by Typhaine Artez - 2017 for OpenSim
//
// Provided under Creative Commons Attribution-Non-Commercial-ShareAlike 4.0 International license.
// Please be sure you read and adhere to the terms of this license: https://creativecommons.org/licenses/by-nc-sa/4.0/

// (changelog at the end of the script)
//
////////////////////////////////////////////////////////////////////////////////
// Setup: change variables below accordingly to your build.

// Link number of the object containing the displayed pictures (defaults to -1
// to deactivate it and ensure it's setup correctly)
integer PICTURE_LINK = 1;

// Face number of the displayed pictures on the PICTURE_LINK object (defaults to
// -1 to deactivate it and ensure it's setup correctly)
integer PICTURE_FACE = -1;

// Link number of the cache object. Set to -1 to deactivate cache.
// The cache is a 8 faces linked object hidden in the build (but not made 100%
// transparent), that preloads pictures before they are displayed.
integer CACHE_LINK = -1;

// End of setup (do not modify code below unless you know what you do)
////////////////////////////////////////////////////////////////////////////////

integer numpics = 0;
integer curpic = 0;

float timeout = 60.;
integer fade = TRUE;
integer bright = FALSE;
integer public = FALSE;
integer text = FALSE;

integer menuChan = 0;
integer menuPage = 0;
integer menuPg = 1;
key menuUser;

resetPictures() {
    curpic = 0;
    numpics = llGetInventoryNumber(INVENTORY_TEXTURE);
    menuPg = 0;
}

fadeTexture(integer in) {
    float i;
    if (in) {
        i = 0.;
        while (i < 1.) {
            i += .05;
            llSetLinkPrimitiveParamsFast(PICTURE_LINK, [PRIM_COLOR, PICTURE_FACE, <i, i, i>, 1.]);
            llSleep(0.05);
        }
    }
    else {
        i = 1.;
        while (i > 0.) {
            i -= .05;
            llSetLinkPrimitiveParamsFast(PICTURE_LINK, [PRIM_COLOR, PICTURE_FACE, <i, i, i>, 1.]);
            llSleep(0.05);
        }
    }
}

integer getMin(integer a, integer b) {
    if (a < b) return a;
    return b;
}

integer getMax(integer a, integer b) {
    if (a < b) return b;
    return a;
}

setTexture(integer index) {
    list prms = llGetLinkPrimitiveParams(PICTURE_LINK, [PRIM_TEXTURE, PICTURE_FACE]);
    string name = llGetInventoryName(INVENTORY_TEXTURE, index);
    if (name == "") {
        name = TEXTURE_BLANK;
    }

    if (name != TEXTURE_BLANK) {
        say("Displaying picture (" + (string)(index+1) + "): " + name);
        if (fade) {
            fadeTexture(FALSE);
        }
    }
    llSetLinkPrimitiveParamsFast(PICTURE_LINK, [ PRIM_TEXTURE, PICTURE_FACE, name ] + llList2List(prms, 1, 3));

    if (name != TEXTURE_BLANK) {
        if (~CACHE_LINK) { // cache handling
            updateCache(index);
        }
        if (fade) { // animation handling
            fadeTexture(TRUE);
        }
    }

    llSetTimerEvent(timeout);
}

updateCache(integer index) {
    integer count = 8;
    if (count > numpics) {
        count = numpics;
    }
    index -= count / 2;
    if (index < 0) {
        index = 0;
    }
    count = index+ count;
    integer face = 0;
    list params;
    for (; index < count; ++index, ++face) {
        params += [PRIM_TEXTURE, face, llGetInventoryName(INVENTORY_TEXTURE, index), <1.,1.,0.>, ZERO_VECTOR, 0];
    }
    llSetLinkPrimitiveParamsFast(CACHE_LINK, params);
}

changePicture(integer move) {
    curpic += move;
    if (curpic < 0) {
        curpic = numpics - 1;
    }
    else if (curpic >= numpics) {
        curpic = 0;
    }
    setTexture(curpic);
}

say(string msg) {
    if (msg != "" && text) {
        llWhisper(0, msg);
    }
}

integer menuGetChecked(string btn) {
    return (llGetSubString(btn, 0, 0) == "☒");
}

string menuSetChecked(string name, integer check) {
    return llList2String(["□", "☒"], check) + " " + name;
}

string menuGetTimer() {
    if (timeout == 0.) {
        return "off";
    }
    else if (timeout <= 60.) {
        return (string)((integer)timeout) + " seconds";
    }
    return (string)((integer)timeout / 60) + " minutes";
}

string menuGetCurrent() {
    string name = llGetInventoryName(INVENTORY_TEXTURE, curpic);
    if (name == "") { return ": (none)";}
    return "(" + (string)(curpic + 1) + "): " + name;
}

menu(integer m, integer move) {
    list buttons;
    string title;
    integer i;
    integer c;

    if (m > -1) {
        menuPage = m;
        menuPg = 0;
    }
    else if (move != 0) {
        menuPg += move;
    } 

    if (menuPage == 0) {
        title = "Change frame options or display a list of pictures.\nUse the arrows to change to the previous or next picture.\n\nCurrent picture " + menuGetCurrent();
        buttons = [
            menuSetChecked("Public", public), menuSetChecked("Fade", fade), menuSetChecked("Bright", bright),
            menuSetChecked("Chat", text), "*TIMER", "*LIST",
            "◀", "Reset", "▶"
        ];
    }
    else if (menuPage == 1) {
        title = "Change the picture change timeout or disable it with Off.\n\nActual timeout: " + menuGetTimer();
        buttons = [
            "10s", "20s", "40s",
            "1m", "2m", "5m",
            "10m", "20m", "40m",
            "Default", "Off", "*BACK"
        ];
    }
    else if (menuPage == 2) {
        integer start = 0;
        integer stop = numpics - 1;
        string name;

        title = "Current picture " + menuGetCurrent() + "\n\nIn this menu:";
        if (numpics > 9) {
            // build navigation
            start = menuPg * 9;
            stop  = (menuPg + 1) * 9 - 1;
        }
        for (i = start; i <= stop; ++i) {
            name = llGetInventoryName(INVENTORY_TEXTURE, i);
            if (name != "") {
                title += "\n" + (string)(i + 1) + " • " + name;
                buttons += (string)(i + 1);
            }
            else {
                buttons += " ";
            }
        }
        buttons += [ llList2String([" ", "◀ PAGE"], (menuPg > 0)), "*BACK", llList2String([" ", "PAGE ▶"], (stop < numpics - 1)) ];
    }

    if (title != "" && llGetListLength(buttons) > 0) {
        llDialog(menuUser, "\n" + title, llList2List(buttons, 9, 11) + llList2List(buttons, 6, 8) + llList2List(buttons, 3, 5) + llList2List(buttons, 0, 2), menuChan);
    }
}

default {
    state_entry() {
        if (PICTURE_LINK == -1 || PICTURE_FACE == -1) {
            llOwnerSay("Script variables haven't been set yet. Please open the script and modify them at the top of the script.");
        }
        else {
            state running;
        }
    }
    changed(integer what) {
        if (what & (CHANGED_INVENTORY | CHANGED_OWNER)) {
            llResetScript();
        }
    }
}

state running {
    state_entry() {
        bright = llList2Integer(llGetLinkPrimitiveParams(PICTURE_LINK, [PRIM_FULLBRIGHT, PICTURE_FACE]), 0);
        resetPictures();
        setTexture(0);

        menuChan = (integer)llFrand(-2147483392.0) - 255;
        llListen(menuChan, "", "", "");
        llSetTimerEvent(timeout);
        llAllowInventoryDrop(public);
    }

    changed(integer what) {
        if (what & CHANGED_INVENTORY) {
            say("Content change, resetting picture list...");
            resetPictures();
        }
        else if (what & CHANGED_OWNER) {
            llResetScript();
        }
    }

    timer() {
        if (timeout > 0.) {
            changePicture(1);
        }
    }

    touch_start(integer num) {
        integer isOwner = (llDetectedKey(0) == llGetOwner());
        if (public || isOwner) {
            if (llDetectedLinkNumber(0) == PICTURE_LINK && llDetectedTouchFace(0) == PICTURE_FACE) {
                changePicture(1);
            }
            else if (isOwner) {
                menuUser = llDetectedKey(0);
                menu(0, 0);
            }
        }
    }

    listen(integer channel, string name, key id, string msg) {
        if (channel != menuChan || id != menuUser) {
            return;
        }
        if (menuPage == 0) {
            if (msg == "◀") {
                changePicture(-1);
            }
            else if (msg == "▶") {
                changePicture(1);
            }
            else if (msg == "*TIMER") {
                menu(1, 0);
                return;
            }
            else if (msg == "*LIST") {
                menu(2, 0);
                return;
            }
            else if (msg == "Reset") {
                llResetScript();
            }
            else if (~llListFindList(["□", "☒"], [llGetSubString(msg, 0, 0)])) {
                string btn = llGetSubString(msg, 2, -1);
                if (btn == "Public") {
                    public = 1 - menuGetChecked(msg);
                    say(llList2String(["A", "Disa"], public) + "llow anyone to drop pictures");
                    llAllowInventoryDrop(public);
                }
                else if (btn == "Fade") {
                    fade = 1 - menuGetChecked(msg);
                    say(llList2String(["En", "Dis"], fade) + "able fading effect");
                }
                else if (btn == "Bright") {
                    bright = 1 - menuGetChecked(msg);
                    say(llList2String(["En", "Dis"], bright) + "able full bright display");
                    llSetLinkPrimitiveParamsFast(PICTURE_LINK, [PRIM_FULLBRIGHT, PICTURE_FACE, bright]);
                }
                else if (btn == "Chat") {
                    text = 1 - menuGetChecked(msg);
                    say("Enable chat feedback");
                }
            }
        }
        else if (menuPage == 1) {
            if (msg == "Off") {
                timeout = 0.;
                say("Timer disabled");
            }
            else if (msg == "Default") {
                timeout = 60.;
                say("Timer reset to default: " + menuGetTimer());
            }
            else if (msg != "*BACK") {
                integer i = llSubStringIndex(msg, "s");
                if (~i) {
                    timeout = (float)llGetSubString(msg, 0, i - 1);
                }
                else {
                    i = llSubStringIndex(msg, "m");
                    if (~i) {
                        timeout = 60. * (float)llGetSubString(msg, 0, i - 1);
                    }
                }
                say("Timer set to: " + menuGetTimer());
            }
        }
        else if (menuPage == 2) {
            if (msg == "◀ PAGE") {
                menu(-1, -1);
            }
            else if (msg == "PAGE ▶") {
                menu(-1, 1);
            }
            else if (msg != "*BACK") {
                integer i = (integer)msg;
                if (i > 0) {
                    curpic = i - 1;
                    setTexture(curpic);
                }
            }
        }
        if (msg == "*BACK") {
            menu(0, 0);
            return;
        }
        menu(-1, 0);
    }

}

////////////////////////////////////////////////////////////////////////////////
// Changelog

// 1.3 2020-04-08
//  * Added license
// 1.2 2017-11-06
//  * Changed setup (modify script variables instead of setting the description)
//  * Documentation (README notecard) written
// 1.1 2017-11-05
//  * Improved cache to 8 faces. Some bug fixes.
// 1.0 2017-11-03
//  * Initial release

