; ============================================================
; Fisch Macro V13.4
; ============================================================
#SingleInstance Force
setkeydelay, -1
setmousedelay, -1
setbatchlines, -1
SetTitleMatchMode 2

CoordMode, ToolTip, Relative
CoordMode, Pixel, Relative
CoordMode, Mouse, Relative

if (InStr(A_ScriptDir, ".zip\") || InStr(A_ScriptDir, ".rar\") || InStr(A_ScriptDir, ".7z\")) {
    MsgBox, 0x40030, Extract Files Required, You must extract the files from the ZIP archive first!`n`nThe macro cannot save settings while running from inside a ZIP file.`n`nPlease:`n1. Right-click the ZIP file`n2. Select "Extract All"`n3. Run the macro from the extracted folder
    ExitApp
}

FileAppend, , %A_ScriptDir%\test_write.tmp
if (ErrorLevel) {
    if (InStr(A_ScriptDir, "Downloads") && (InStr(A_ScriptDir, "Compressed") || InStr(A_ScriptDir, "Temp"))) {
        MsgBox, 0x40030, Extract Files Required, It appears you're running from a compressed/temporary folder.`n`nPlease extract all files to a regular folder (like Desktop or Documents) before running the macro.`n`nCurrent location: %A_ScriptDir%
        ExitApp
    } else {
        MsgBox, 0x40030, Permission Error, Cannot write to current directory: %A_ScriptDir%`n`nTry:`n1. Moving the files to Desktop or Documents`n2. Running as Administrator`n3. Extracting from ZIP if compressed
        ExitApp
    }
} else {
    FileDelete, %A_ScriptDir%\test_write.tmp
}

;		GUI		==============================================================================================================;

Gui, Font, s9 cWhite, Segoe UI
Gui,+AlwaysOnTop
Gui, +Resize +MinSize
Gui, +LastFound -Theme  ; Disable Windows theming so text colors can apply to Edit boxes
Gui, Font, c0xFFFFFF
Gui, Add, Tab2, w850 h620, General Settings|Shake Settings|Minigame Settings|Other Settings
Gui, Color, 0x1D1D1D Bold

; Buttons
Gui, Tab
Gui, Font, s9 cWhite, Segoe UI
Gui, Add, Text, x30 y565 , Active Configuration
Gui, Add, ComboBox, x30 y580 w160 h100 vDropItem gSelectItem
Gui, Add, Button, x200 y580 w100 h30 gSaveSettings, 💾 Save
Gui, Add, Button, x310 y580 w100 h30 gLoadSettings, 📂 Load
Gui, Add, Button, x420 y580 w100 h30 gExitScript, ❌ Exit
Gui, Add, Button, x530 y580 w100 h30 gLaunch, ▶️ Start
Gui, Add, Text, x820 y600 , V13.4

; The GUI section below uses 0xRRGGBB instead of 0xBBGGRR unlike the other sections
; ====== General Tab ======
Gui, Tab, General
Gui, Font, s9 cWhite, Segoe UI
Gui, Font, c0x00FF00
Gui, Add, Text, x30 y40, General Settings
Gui, Font, cWhite Norm

Gui, Font, c0x00FF00 Bold
Gui, Add, GroupBox, x20 y60 w380 h230, Automation
Gui, Font, cWhite Norm
Gui, Add, Text, x40 y90, Auto Lower Graphics:
Gui, Add, Checkbox, x220 y90 vAutoLowerGraphics, Enable
Gui, Add, Text, x40 y130, Auto Zoom In:
Gui, Add, Checkbox, x220 y130 vAutoZoomInCamera, Enable
Gui, Add, Text, x40 y170, Auto Enable Camera Mode:
Gui, Add, Checkbox, x220 y170 vAutoEnableCameraMode, Enable
Gui, Add, Text, x40 y210, Auto Look Down:
Gui, Add, Checkbox, x220 y210 vAutoLookDownCamera, Enable
Gui, Add, Text, x40 y250, Auto Blur:
Gui, Add, Checkbox, x220 y250 vAutoBlurCamera, Enable

Gui, Font, c0x00FF00 Bold
Gui, Add, GroupBox, x440 y60 w380 h160, Timing and pacing
Gui, Font, cWhite Norm
Gui, Add, Text, x460 y90, Restart Delay (ms):
Gui, Add, Edit, x640 y90 w100 vRestartDelay cBlack, 1500
Gui, Add, Text, x460 y130, Wait for Bobber to Land (ms):
Gui, Add, Edit, x640 y130 w100 vWaitForBobberDelay cBlack, 1000
Gui, Add, Text, x460 y170, Bait Delay (ms):
Gui, Add, Edit, x640 y170 w100 vBaitDelay cBlack, 0

Gui, Font, c0x00FF00 Bold
Gui, Add, GroupBox, x440 y240 w380 h250, Casting
Gui, Font, cWhite Norm
Gui, Add, Text, x460 y270, Perfect Cast (slower):
Gui, Add, Checkbox, x640 y270 vPerfectCast, Enable
Gui, Add, Text, x460 y310, Hold Rod Cast Duration (ms):
Gui, Add, Edit, x640 y310 w100 vHoldRodCastDuration cBlack, 600
Gui, Add, Text, x460 y350, Perfect Cast Tolerance:
Gui, Add, Edit, x640 y350 w100 vPerfectCastTolerance cBlack, 15

Gui, Font, c0x00FF00 Bold
Gui, Add, GroupBox, x20 y310 w380 h210, Resources
Gui, Font, cWhite Norm
Gui, Font, c0x6A9955
Gui, Add, Link, x40 y340, <a href="https://discord.com/invite/mangos"> Join Blooms Discord</a>
Gui, Add, Link, x40 y370, <a href="https://discord.com/channels/1322430437536170037/1323672910640185415">Setup Guide (Discord)</a>
Gui, Add, Link, x40 y400, <a href="https://docs.google.com/document/d/12fJkFRHTFfNDDADC8Je8MUOE6k7fzKIl0z5oPQWaNqA/edit?usp=sharing">Fisch V14 Progress</a>
Gui, Font, cWhite
Gui, Add, Text, x40 y430, If it’s your first time, check all boxes.
Gui, Add, Text, x40 y460, Click the top-right camera icon if not working.
Gui, Add, Text, x40 y490, Run as Admin if you can’t save or load settings.

; ====== Shake Tab ======
Gui, Tab, Shake
Gui, Font, s9 cWhite, Segoe UI
Gui, Font, c0x87CEEB Bold
Gui, Add, Text, x30 y40, Shake Settings
Gui, Font, cWhite Norm

; === Shake Configuration ===
Gui, Font, c0x87CEEB Bold
Gui, Add, GroupBox, x20 y60 w370 h420, Shake Configuration
Gui, Font, cWhite Norm
Gui, Add, Text, x40 y90, Navigation Key:
Gui, Add, Edit, x200 y87 w100 vNavigationKey cBlack, \
Gui, Add, Text, x40 y125, Shake Mode:
Gui, Add, ComboBox, x200 y120 w100 vShakeMode cBlack, Click|Navigation|Wait
Gui, Add, Text, x40 y160, Shake Failsafe (sec):
Gui, Add, Edit, x200 y157 w100 vShakeFailsafe cBlack, 20

; --- Click Shake Settings ---
Gui, Font, c0x87CEEB Bold
Gui, Add, GroupBox, x40 y190 w320 h90, Click Mode
Gui, Font, cWhite Norm
Gui, Add, Text, x60 y215, Color Tolerance:
Gui, Add, Edit, x200 y215 w100 vShakeTolerance cBlack, 3
Gui, Add, Text, x60 y245, Scan Delay (ms):
Gui, Add, Edit, x200 y245 w100 vClickScanDelay cBlack, 10

; --- Navigation Settings ---
Gui, Font, c0x87CEEB Bold
Gui, Add, GroupBox, x40 y290 w320 h70, Navigation Mode
Gui, Font, cWhite Norm
Gui, Font, cWhite
Gui, Add, Text, x60 y315, Spam Delay (ms):
Gui, Add, Edit, x200 y315 w100 vNavigationSpamDelay cBlack, 10

; --- Wait Settings ---
Gui, Font, c0x87CEEB Bold
Gui, Add, GroupBox, x40 y370 w320 h90, Wait Mode
Gui, Font, cWhite Norm
Gui, Add, Text, x60 y395, Wait Until Clicking (ms):
Gui, Add, Edit, x200 y392 w100 vWaitUntilClicking cBlack, 9000

; === Notes ===
Gui, Font, c0x87CEEB Bold
Gui, Add, GroupBox, x420 y60 w400 h380, Notes
Gui, Font, cWhite Norm
Gui, Add, Text, x440 y90, - Set correct Navigation Key in Roblox
Gui, Add, Text, x440 y120, - Choose a Shake Mode that matches your style
Gui, Add, Text, x440 y150, - Adjust delay values for your latency
Gui, Add, Text, x440 y180, - Load → Save → Start for reliability
Gui, Add, Text, x440 y210, - Click = pixel shake | Nav = key spam | Wait = timer-based
Gui, Font

; ====== Minigame Tab ======
Gui, Tab, Minigame
Gui, Font, s9 cWhite, Segoe UI
Gui, Font, c0xE87B07 Bold
Gui, Add, Text, x30 y40, Minigame Settings
Gui, Font, cWhite Norm

; === Control Stats ===
Gui, Font, c0xE87B07 Bold
Gui, Add, GroupBox, x20 y60 w350 h190, Control Stats
Gui, Font, cWhite Norm
Gui, Add, Text, x40 y90, Resilience:
Gui, Add, Edit, x180 y87 w100 vResilience cBlack, 0
Gui, Add, Text, x40 y125, Control:
Gui, Add, Edit, x180 y122 w100 vControl cBlack, 0
Gui, Add, Checkbox, x40 y160 vNegativeControl, Negative Control
Gui, Add, Button, x180 y160 w100 h25 gGenerateResillience, Generate values

; === Control Loop ===
Gui, Font, c0xE87B07 Bold
Gui, Add, GroupBox, x400 y60 w370 h190, Side Bar Settings
Gui, Font, cWhite Norm
Gui, Add, Text, x420 y90, Scan Delay:
Gui, Add, Edit, x600 y87 w100 vScanDelay cBlack, 10
Gui, Add, Text, x420 y125, Side Bar Ratio:
Gui, Add, Edit, x600 y122 w100 vSideBarRatio cBlack, 0.7
Gui, Add, Text, x420 y160, Side Bar Delay:
Gui, Add, Edit, x600 y157 w100 vSideDelay cBlack, 400

; === Detection Tolerance ===
Gui, Font, c0xE87B07 Bold
Gui, Add, GroupBox, x20 y270 w350 h140, Detection Tolerance
Gui, Font, cWhite Norm
Gui, Add, Text, x40 y300, Fish Bar Tolerance:
Gui, Add, Edit, x180 y297 w100 vFishLeftColorTolerance cBlack, 5
Gui, Add, Text, x40 y335, White Bar Tolerance:
Gui, Add, Edit, x180 y332 w100 vWhiteLeftColorTolerance cBlack, 15
Gui, Add, Text, x40 y370, Arrow Tolerance:
Gui, Add, Edit, x180 y367 w100 vArrowColorTolerance cBlack, 6
Gui, Add, Link, x420 y190, <a href="https://docs.google.com/document/d/17qkxS2nzCXO8k-tvT_s-w4UF_GiqZbgOzAWNFsbUZI8/edit?usp=sharing">Open Minigame Guide</a>

; === Bar Stability ===
Gui, Font, c0xE87B07 Bold
Gui, Add, GroupBox, x400 y270 w370 h280, Stability Profiles
Gui, Font, cWhite Norm
Gui, Add, Text, x420 y295, Stable Right Multiplier:
Gui, Add, Edit, x600 y292 w100 vStableRightMultiplier cBlack, 2.36
Gui, Add, Text, x420 y325, Stable Right Division:
Gui, Add, Edit, x600 y322 w100 vStableRightDivision cBlack, 1.55
Gui, Add, Text, x420 y355, Stable Left Multiplier:
Gui, Add, Edit, x600 y352 w100 vStableLeftMultiplier cBlack, 1.211
Gui, Add, Text, x420 y385, Stable Left Division:
Gui, Add, Edit, x600 y382 w100 vStableLeftDivision cBlack, 1.12
Gui, Add, Text, x420 y415, Unstable Right Multiplier:
Gui, Add, Edit, x600 y412 w100 vUnstableRightMultiplier cBlack, 2.665
Gui, Add, Text, x420 y445, Unstable Right Division:
Gui, Add, Edit, x600 y442 w100 vUnstableRightDivision cBlack, 1.5
Gui, Add, Text, x420 y475, Unstable Left Multiplier:
Gui, Add, Edit, x600 y472 w100 vUnstableLeftMultiplier cBlack, 2.19
Gui, Add, Text, x420 y505, Unstable Left Division:
Gui, Add, Edit, x600 y502 w100 vUnstableLeftDivision cBlack, 1
Gui, Font, cWhite

; === Ankle Settings ===
Gui, Font, c0xE87B07 Bold
Gui, Add, GroupBox, x20 y420 w350 h90, Ankle Settings
Gui, Font, cWhite Norm
Gui, Add, Text, x40 y450, Right Ankle Break Multiplier:
Gui, Add, Edit, x250 y447 w100 vRightAnkleBreakMultiplier cBlack, 0.75
Gui, Add, Text, x40 y480, Left Ankle Break Multiplier:
Gui, Add, Edit, x250 y477 w100 vLeftAnkleBreakMultiplier cBlack, 0.45

Gui, Font

; ====== Other Tab ======
Gui, Tab, Other
Gui, Font, s9 cWhite, Segoe UI
Gui, Font, c0xFF0000 Bold
Gui, Add, Text, x30 y40, Other Settings
Gui, Font, cWhite Norm
Gui, Font, c0xFF0000 Bold
Gui, Add, GroupBox, x20 y60 w370 h250, Custom Rod Options
Gui, Font, cWhite Norm
; Custom rod options
Gui, Add, Text, x40 y90, Seraphic Rod Check:
Gui, Add, Checkbox, x220 y90 vSera, Enable
Gui, Add, Text, x40 y130, Seraphic Rod Cycles:
Gui, Add, Edit, x220 y127 w100 vSeraCycles cBlack, 25
Gui, Add, Text, x40 y170, Random Rod Check:
Gui, Add, Checkbox, x220 y170 vRandomRod, Enable

Gui, Font, c0xFF0000 Bold
Gui, Add, GroupBox, x420 y60 w360 h290, Bar Colors
Gui, Font, cWhite Norm

Gui, Add, Text, x440 y90, Bar Color (in 0xBBGGRR):
Gui, Add, Edit, x600 y90 w100 vLeftColor cBlack, 0xFFFFFF

Gui, Add, Text, x440 y130, Bar Color 2 (in 0xBBGGRR):
Gui, Add, Edit, x600 y130 w100 vLeftColor2 cBlack, 0x00FC43

Gui, Add, Text, x440 y170, Arrow Color (in 0xBBGGRR):
Gui, Add, Edit, x600 y170 w100 vArrowColor cBlack, 0x878584

Gui, Add, Text, x440 y210, Arrow Color 2 (in 0xBBGGRR):
Gui, Add, Edit, x600 y210 w100 vArrowColor2 cBlack, 0x878584

Gui, Add, Text, x440 y250, Fish Color (in 0xBBGGRR):
Gui, Add, Edit, x600 y250 w100 vFishColor cBlack, 0x5B4B43

Gui, Font

; show GUI
Gui, Show,,
return

Loop, %A_ScriptDir%\*.ini
{
    StringTrimRight, fileName, A_LoopFileName, 4
    GuiControl,, DropItem, %fileName%
}

SettingsFileName := A_ScriptDir . "\" . SettingsFileName . ".ini"
return

SelectItem:
    Gui, Submit, NoHide
    SettingsFileName := A_ScriptDir . "\" . DropItem . ".ini"
return

GenerateResillience:
    Gui, Submit, NoHide

    ; Use GUI values directly
    stable_right_multiplier := 2.36 + (Control * 0.05) + (Resilience * 0.02)
    stable_left_multiplier  := 1.211 + (Control * 0.04) + (Resilience * 0.02)
    unstable_right_multiplier := 2.665 + (Control * 0.06) + (Resilience * 0.03)
    unstable_left_multiplier  := 2.19 + (Control * 0.05) + (Resilience * 0.025)

    stable_right_division := 1.55 - (Control * 0.02) - (Resilience * 0.005)
    unstable_right_division := 1.5 - (Control * 0.03) - (Resilience * 0.01)
    stable_left_division := 1.12 - (Control * 0.015) - (Resilience * 0.005)
    unstable_left_division := 1.0 - (Control * 0.02) - (Resilience * 0.01)

    right_ankle_multiplier := 0.25 + (Control / 30) + (Resilience / 60)
    left_ankle_multiplier  := 0.25 + (Control / 40) + (Resilience / 80)

    ; Clamp values
    if (right_ankle_multiplier > 0.45)
        right_ankle_multiplier := 0.45
    if (left_ankle_multiplier > 0.35)
        left_ankle_multiplier := 0.35

    ; Update GUI fields with calculated values
    GuiControl,, StableRightMultiplier, %stable_right_multiplier%
    GuiControl,, StableLeftMultiplier, %stable_left_multiplier%
    GuiControl,, UnstableRightMultiplier, %unstable_right_multiplier%
    GuiControl,, UnstableLeftMultiplier, %unstable_left_multiplier%

    GuiControl,, StableRightDivision, %stable_right_division%
    GuiControl,, StableLeftDivision, %stable_left_division%
    GuiControl,, UnstableRightDivision, %unstable_right_division%
    GuiControl,, UnstableLeftDivision, %unstable_left_division%

    GuiControl,, RightAnkleBreakMultiplier, %right_ankle_multiplier%
    GuiControl,, LeftAnkleBreakMultiplier, %left_ankle_multiplier%
return

; Save settings
SaveSettings:
    Gui, Submit, NoHide
    if (DropItem = "")
        SettingsFileName := A_ScriptDir . "\default.ini"
    else
        SettingsFileName := A_ScriptDir . "\" . DropItem . ".ini"
    
    FileAppend, , %SettingsFileName%  ; Create the file if it doesn't exist

    IniWrite, %AutoLowerGraphics%, %SettingsFileName%, General, AutoLowerGraphics
    IniWrite, %AutoZoomInCamera%, %SettingsFileName%, General, AutoZoomInCamera
    IniWrite, %AutoEnableCameraMode%, %SettingsFileName%, General, AutoEnableCameraMode
    IniWrite, %AutoLookDownCamera%, %SettingsFileName%, General, AutoLookDownCamera
    IniWrite, %AutoBlurCamera%, %SettingsFileName%, General, AutoBlurCamera

    IniWrite, %RestartDelay%, %SettingsFileName%, General, RestartDelay
    IniWrite, %HoldRodCastDuration%, %SettingsFileName%, General, HoldRodCastDuration
    IniWrite, %PerfectCastTolerance%, %SettingsFileName%, General, PerfectCastTolerance
    IniWrite, %WaitForBobberDelay%, %SettingsFileName%, General, WaitForBobberDelay
    IniWrite, %BaitDelay%, %SettingsFileName%, General, BaitDelay
    IniWrite, %Sera%, %SettingsFileName%, General, Sera
    IniWrite, %RandomRod%, %SettingsFileName%, General, RandomRod

    IniWrite, %NavigationKey%, %SettingsFileName%, Shake, NavigationKey
    IniWrite, %ShakeMode%, %SettingsFileName%, Shake, ShakeMode
    IniWrite, %ShakeFailsafe%, %SettingsFileName%, Shake, ShakeFailsafe

    IniWrite, %ShakeTolerance%, %SettingsFileName%, Shake, ShakeTolerance
    IniWrite, %ClickScanDelay%, %SettingsFileName%, Shake, ClickScanDelay
    IniWrite, %NavigationSpamDelay%, %SettingsFileName%, Shake, NavigationSpamDelay
    IniWrite, %WaitUntilClicking%, %SettingsFileName%, Shake, WaitUntilClicking
    IniWrite, %PerfectCast%, %SettingsFileName%, Shake, PerfectCast

    IniWrite, %Resilience%, %SettingsFileName%, Minigame, Resilience
    IniWrite, %Control%, %SettingsFileName%, Minigame, Control
    IniWrite, %NegativeControl%, %SettingsFileName%, Minigame, NegativeControl
    IniWrite, %FishLeftColorTolerance%, %SettingsFileName%, Minigame, FishLeftColorTolerance
    IniWrite, %WhiteLeftColorTolerance%, %SettingsFileName%, Minigame, WhiteLeftColorTolerance
    IniWrite, %ArrowColorTolerance%, %SettingsFileName%, Minigame, ArrowColorTolerance

    IniWrite, %ScanDelay%, %SettingsFileName%, Minigame, ScanDelay
    IniWrite, %SideBarRatio%, %SettingsFileName%, Minigame, SideBarRatio
    IniWrite, %SideDelay%, %SettingsFileName%, Minigame, SideDelay

    IniWrite, %StableRightMultiplier%, %SettingsFileName%, Minigame, StableRightMultiplier
    IniWrite, %StableRightDivision%, %SettingsFileName%, Minigame, StableRightDivision
    IniWrite, %StableLeftMultiplier%, %SettingsFileName%, Minigame, StableLeftMultiplier
    IniWrite, %StableLeftDivision%, %SettingsFileName%, Minigame, StableLeftDivision

    IniWrite, %UnstableRightMultiplier%, %SettingsFileName%, Minigame, UnstableRightMultiplier
    IniWrite, %UnstableRightDivision%, %SettingsFileName%, Minigame, UnstableRightDivision
    IniWrite, %UnstableLeftMultiplier%, %SettingsFileName%, Minigame, UnstableLeftMultiplier
    IniWrite, %UnstableLeftDivision%, %SettingsFileName%, Minigame, UnstableLeftDivision
    
    IniWrite, %RightAnkleBreakMultiplier%, %SettingsFileName%, Minigame, RightAnkleBreakMultiplier
    IniWrite, %LeftAnkleBreakMultiplier%, %SettingsFileName%, Minigame, LeftAnkleBreakMultiplier

    IniWrite, %LeftColor%, %SettingsFileName%, Others, LeftColor
    IniWrite, %LeftColor2%, %SettingsFileName%, Others, LeftColor2
    IniWrite, %LeftColor3%, %SettingsFileName%, Others, LeftColor3
    IniWrite, %ArrowColor%, %SettingsFileName%, Others, ArrowColor
    IniWrite, %ArrowColor2%, %SettingsFileName%, Others, ArrowColor2
    IniWrite, %FishColor%, %SettingsFileName%, Others, FishColor
    IniWrite, %SeraCycles%, %SettingsFileName%, Others, SeraCycles

    ; Done
    Gui, -AlwaysOnTop
    MsgBox, 0x40040, Saved, Settings saved successfully as %SettingsFileName% !, 0.8
    Gui, +AlwaysOnTop
return

; Load settings
LoadSettings:
    IniRead, lAutoLowerGraphics, %SettingsFileName%, General, AutoLowerGraphics
    IniRead, lAutoZoomInCamera, %SettingsFileName%, General, AutoZoomInCamera
    IniRead, lAutoEnableCameraMode, %SettingsFileName%, General, AutoEnableCameraMode
    IniRead, lAutoLookDownCamera, %SettingsFileName%, General, AutoLookDownCamera
    IniRead, lAutoBlurCamera, %SettingsFileName%, General, AutoBlurCamera

    IniRead, lRestartDelay, %SettingsFileName%, General, RestartDelay
    IniRead, lHoldRodCastDuration, %SettingsFileName%, General, HoldRodCastDuration
    IniRead, lWaitForBobberDelay, %SettingsFileName%, General, WaitForBobberDelay
    IniRead, lBaitDelay, %SettingsFileName%, General, BaitDelay
    IniRead, lSera, %SettingsFileName%, General, Sera
    IniRead, lRandomRod, %SettingsFileName%, General, RandomRod
    IniRead, lPerfectCastTolerance, %SettingsFileName%, General, PerfectCastTolerance

    IniRead, lNavigationKey, %SettingsFileName%, Shake, NavigationKey
    IniRead, lShakeMode, %SettingsFileName%, Shake, ShakeMode
    IniRead, lShakeFailsafe, %SettingsFileName%, Shake, ShakeFailsafe

    IniRead, lShakeTolerance, %SettingsFileName%, Shake, ShakeTolerance
    IniRead, lClickScanDelay, %SettingsFileName%, Shake, ClickScanDelay
    IniRead, lNavigationSpamDelay, %SettingsFileName%, Shake, NavigationSpamDelay
    IniRead, lWaitUntilClicking, %SettingsFileName%, Shake, WaitUntilClicking
    IniRead, lPerfectCast, %SettingsFileName%, Shake, PerfectCast

    IniRead, lResilience, %SettingsFileName%, Minigame, Resilience
    IniRead, lControl, %SettingsFileName%, Minigame, Control
    IniRead, lNegativeControl, %SettingsFileName%, Minigame, NegativeControl
    IniRead, lFishLeftColorTolerance, %SettingsFileName%, Minigame, FishLeftColorTolerance
    IniRead, lWhiteLeftColorTolerance, %SettingsFileName%, Minigame, WhiteLeftColorTolerance
    IniRead, lArrowColorTolerance, %SettingsFileName%, Minigame, ArrowColorTolerance

    IniRead, lScanDelay, %SettingsFileName%, Minigame, ScanDelay
    IniRead, lSideBarRatio, %SettingsFileName%, Minigame, SideBarRatio
    IniRead, lSideDelay, %SettingsFileName%, Minigame, SideDelay

    IniRead, lStableRightMultiplier, %SettingsFileName%, Minigame, StableRightMultiplier
    IniRead, lStableRightDivision, %SettingsFileName%, Minigame, StableRightDivision
    IniRead, lStableLeftMultiplier, %SettingsFileName%, Minigame, StableLeftMultiplier
    IniRead, lStableLeftDivision, %SettingsFileName%, Minigame, StableLeftDivision

    IniRead, lUnstableRightMultiplier, %SettingsFileName%, Minigame, UnstableRightMultiplier
    IniRead, lUnstableRightDivision, %SettingsFileName%, Minigame, UnstableRightDivision
    IniRead, lUnstableLeftMultiplier, %SettingsFileName%, Minigame, UnstableLeftMultiplier
    IniRead, lUnstableLeftDivision, %SettingsFileName%, Minigame, UnstableLeftDivision

    IniRead, lRightAnkleBreakMultiplier, %SettingsFileName%, Minigame, RightAnkleBreakMultiplier
    IniRead, lLeftAnkleBreakMultiplier, %SettingsFileName%, Minigame, LeftAnkleBreakMultiplier

    IniRead, lLeftColor, %SettingsFileName%, Others, LeftColor
    IniRead, lLeftColor2, %SettingsFileName%, Others, LeftColor2
    IniRead, lLeftColor3, %SettingsFileName%, Others, LeftColor3
    IniRead, lArrowColor, %SettingsFileName%, Others, ArrowColor
    IniRead, lArrowColor2, %SettingsFileName%, Others, ArrowColor2
    IniRead, lFishColor, %SettingsFileName%, Others, FishColor

    IniRead, lSeraCycles, %SettingsFileName%, Others, SeraCycles
    
    ; Update GUI
    if FileExist(SettingsFileName) {
        Gui, Submit, NoHide
        GuiControl,, AutoLowerGraphics, %lAutoLowerGraphics%
        GuiControl,, AutoZoomInCamera, %lAutoZoomInCamera%
        GuiControl,, AutoEnableCameraMode, %lAutoEnableCameraMode%
        GuiControl,, AutoLookDownCamera, %lAutoLookDownCamera%
        GuiControl,, AutoBlurCamera, %lAutoBlurCamera%
        GuiControl,, PerfectCastTolerance, %lPerfectCastTolerance%

        GuiControl,, RestartDelay, %lRestartDelay%
        GuiControl,, HoldRodCastDuration, %lHoldRodCastDuration%
        GuiControl,, WaitForBobberDelay, %lWaitForBobberDelay%
        GuiControl,, BaitDelay, %lBaitDelay%
        GuiControl,, Sera, %lSera%
        GuiControl,, RandomRod, %lRandomRod%

        GuiControl,, NavigationKey, %lNavigationKey%
        GuiControl,Choose, ShakeMode, %lShakeMode%
        GuiControl,, ShakeFailsafe, %lShakeFailsafe%

        GuiControl,, ShakeTolerance, %lShakeTolerance%
        GuiControl,, ClickScanDelay, %lClickScanDelay%
        GuiControl,, NavigationSpamDelay, %lNavigationSpamDelay%
        GuiControl,, WaitUntilClicking, %lWaitUntilClicking%
        GuiControl,, PerfectCast, %lPerfectCast%

        GuiControl,, Resilience, %lResilience%
        GuiControl,, Control, %lControl%
        GuiControl,, NegativeControl, %lNegativeControl% 
        GuiControl,, FishLeftColorTolerance, %lFishLeftColorTolerance%
        GuiControl,, WhiteLeftColorTolerance, %lWhiteLeftColorTolerance%
        GuiControl,, ArrowColorTolerance, %lArrowColorTolerance%

        GuiControl,, ScanDelay, %lScanDelay%
        GuiControl,, SideBarRatio, %lSideBarRatio%
        GuiControl,, SideDelay, %lSideDelay%

        GuiControl,, StableRightMultiplier, %lStableRightMultiplier%
        GuiControl,, StableRightDivision, %lStableRightDivision%
        GuiControl,, StableLeftMultiplier, %lStableLeftMultiplier%
        GuiControl,, StableLeftDivision, %lStableLeftDivision%

        GuiControl,, UnstableRightMultiplier, %lUnstableRightMultiplier%
        GuiControl,, UnstableRightDivision, %lUnstableRightDivision%
        GuiControl,, UnstableLeftMultiplier, %lUnstableLeftMultiplier%
        GuiControl,, UnstableLeftDivision, %lUnstableLeftDivision%

        GuiControl,, RightAnkleBreakMultiplier, %lRightAnkleBreakMultiplier%
        GuiControl,, LeftAnkleBreakMultiplier, %lLeftAnkleBreakMultiplier%
        
        GuiControl,, LeftColor3, %lLeftColor3%

        GuiControl,, LeftColor, %lLeftColor%
        GuiControl,, LeftColor2, %lLeftColor2%
        GuiControl,, ArrowColor, %lArrowColor%
        GuiControl,, ArrowColor2, %lArrowColor2%
        GuiControl,, FishColor, %lFishColor%

        GuiControl,, SeraCycles, %lSeraCycles%

        ; Done
        Gui, -AlwaysOnTop
        MsgBox, 0x40040, Loaded, Loaded %SettingsFileName% !, 0.8
        Gui, +AlwaysOnTop
        goto, SaveSettings
    } else {
        Gui, -AlwaysOnTop
        MsgBox, 0x40030, Loaded, Settings failed to load.
        Gui, +AlwaysOnTop
    }
return

ExitScript:
    ExitApp
return

GuiClose:
ExitApp

;====================================================================================================;
Launch:
Gui, Hide
    IniRead, lAutoLowerGraphics, %SettingsFileName%, General, AutoLowerGraphics
    IniRead, lAutoZoomInCamera, %SettingsFileName%, General, AutoZoomInCamera
    IniRead, lAutoEnableCameraMode, %SettingsFileName%, General, AutoEnableCameraMode
    IniRead, lAutoLookDownCamera, %SettingsFileName%, General, AutoLookDownCamera
    IniRead, lAutoBlurCamera, %SettingsFileName%, General, AutoBlurCamera

    IniRead, lRestartDelay, %SettingsFileName%, General, RestartDelay
    IniRead, lHoldRodCastDuration, %SettingsFileName%, General, HoldRodCastDuration
    IniRead, lWaitForBobberDelay, %SettingsFileName%, General, WaitForBobberDelay
    IniRead, lBaitDelay, %SettingsFileName%, General, BaitDelay
    IniRead, lSera, %SettingsFileName%, General, Sera
    IniRead, lRandomRod, %SettingsFileName%, General, RandomRod
    IniRead, lPerfectCastTolerance, %SettingsFileName%, General, PerfectCastTolerance

    IniRead, lNavigationKey, %SettingsFileName%, Shake, NavigationKey
    IniRead, lShakeMode, %SettingsFileName%, Shake, ShakeMode
    IniRead, lShakeFailsafe, %SettingsFileName%, Shake, ShakeFailsafe

    IniRead, lShakeTolerance, %SettingsFileName%, Shake, ShakeTolerance
    IniRead, lClickScanDelay, %SettingsFileName%, Shake, ClickScanDelay
    IniRead, lNavigationSpamDelay, %SettingsFileName%, Shake, NavigationSpamDelay
    IniRead, lWaitUntilClicking, %SettingsFileName%, Shake, WaitUntilClicking
    IniRead, lPerfectCast, %SettingsFileName%, Shake, PerfectCast

    IniRead, lResilience, %SettingsFileName%, Minigame, Resilience
    IniRead, lControl, %SettingsFileName%, Minigame, Control
    IniRead, lNegativeControl, %SettingsFileName%, Minigame, NegativeControl
    IniRead, lFishLeftColorTolerance, %SettingsFileName%, Minigame, FishLeftColorTolerance
    IniRead, lWhiteLeftColorTolerance, %SettingsFileName%, Minigame, WhiteLeftColorTolerance
    IniRead, lArrowColorTolerance, %SettingsFileName%, Minigame, ArrowColorTolerance

    IniRead, lScanDelay, %SettingsFileName%, Minigame, ScanDelay
    IniRead, lSideBarRatio, %SettingsFileName%, Minigame, SideBarRatio
    IniRead, lSideDelay, %SettingsFileName%, Minigame, SideDelay

    IniRead, lStableRightMultiplier, %SettingsFileName%, Minigame, StableRightMultiplier
    IniRead, lStableRightDivision, %SettingsFileName%, Minigame, StableRightDivision
    IniRead, lStableLeftMultiplier, %SettingsFileName%, Minigame, StableLeftMultiplier
    IniRead, lStableLeftDivision, %SettingsFileName%, Minigame, StableLeftDivision

    IniRead, lUnstableRightMultiplier, %SettingsFileName%, Minigame, UnstableRightMultiplier
    IniRead, lUnstableRightDivision, %SettingsFileName%, Minigame, UnstableRightDivision
    IniRead, lUnstableLeftMultiplier, %SettingsFileName%, Minigame, UnstableLeftMultiplier
    IniRead, lUnstableLeftDivision, %SettingsFileName%, Minigame, UnstableLeftDivision

    IniRead, lRightAnkleBreakMultiplier, %SettingsFileName%, Minigame, RightAnkleBreakMultiplier
    IniRead, lLeftAnkleBreakMultiplier, %SettingsFileName%, Minigame, LeftAnkleBreakMultiplier

    IniRead, lLeftColor, %SettingsFileName%, Others, LeftColor
    IniRead, lLeftColor2, %SettingsFileName%, Others, LeftColor2
    IniRead, lLeftColor3, %SettingsFileName%, Others, LeftColor3
    IniRead, lArrowColor, %SettingsFileName%, Others, ArrowColor
    IniRead, lArrowColor2, %SettingsFileName%, Others, ArrowColor2
    IniRead, lFishColor, %SettingsFileName%, Others, FishColor

    IniRead, lSeraCycles, %SettingsFileName%, Others, SeraCycles
    SeraCycles := lSeraCycles

if (ShakeMode != "Navigation" and ShakeMode != "Click" and ShakeMode != "Wait") {
    MsgBox, 16, Error, Shake Mode wasn't saved, and was automatically corrected to click.
    ShakeMode := "Click"
    IniWrite, %ShakeMode%, %SettingsFileName%, Shake, ShakeMode
}


;====================================================================================================;

WinActivate, Roblox
if WinActive("ahk_exe RobloxPlayerBeta.exe") || WinActive("ahk_exe eurotruck2.exe")
    {
    WinMaximize, Roblox
    }
else
    {
    MsgBox, 0x40030, Error, Make sure that roblox is launched and opened.
    Reload
    }

if (A_ScreenDPI != 96) {
    MsgBox, 0x40030, Error, Display Scale is not set to 100.`nPress the Windows key > Find "Change the resolution of the display" > Set the Scale to 100
    Reload
}
;====================================================================================================;

Send, {LButton up}
Send, {rbutton up}
Send, {shift up}

;====================================================================================================;

Calculations:
WinGetActiveStats, Title, WindowWidth, WindowHeight, WindowLeft, WindowTop

CameraCheckLeft := WindowWidth/2.8444 ; action 1
CameraCheckRight := WindowWidth/1.5421 ; action 3
CameraCheckTop := WindowHeight/1.28 ; action 2
CameraCheckBottom := WindowHeight ; action 4

CameraClickX := WindowWidth / 1.0164
CameraClickY := WindowHeight / 1.5  ; FIXED: Added divisor value

ClickShakeLeft := WindowWidth/4
ClickShakeRight := WindowWidth/1.2736
ClickShakeTop := WindowHeight/8
ClickShakeBottom := WindowHeight/1.3409

FishBarLeft := WindowWidth/3.3160
FishBarRight := WindowWidth/1.4317
FishBarTop := WindowHeight/1.2
FishBarBottom := WindowHeight/1.1512

ProgressAreaLeft := WindowWidth/2.55
ProgressAreaRight := WindowWidth/1.63
ProgressAreaTop := WindowHeight/1.13
ProgressAreaBottom := WindowHeight/1.08

InviteAreaLeft := WindowWidth/3.4285
InviteAreaTop := WindowHeight/8.93
InviteAreaRight := WindowWidth/1.4087
InviteAreaBottom := WindowHeight/2.335

ResolutionScalingX := WindowWidth / 1920
ResolutionScalingY := WindowHeight / 1080

CloseInviteX := WindowWidth/3.2
CloseInviteY := WindowHeight/7.68

HalfScreenWidth := WindowWidth / 2

FishBarToolTipHeight := WindowHeight/1.0626

LevelCheckLeft := WindowWidth / 1.1098
LevelCheckTop := WindowHeight / 1.102
LevelCheckRight := WindowWidth / 1
LevelCheckBottom := WindowHeight / 1.0485

CastAreaLeft := WindowWidth / 1.5934
CastAreaTop := WindowHeight / 5.2409
CastAreaRight := WindowWidth / 1.5012
CastAreaBottom := WindowHeight / 1.5341

; Thanks Lunar res calculation
ResolutionScaling := WindowWidth / (WindowWidth * 2.37)

LookDownX := WindowWidth/2
LookDownY := WindowHeight/4

runtimeS := 0
runtimeM := 0
runtimeH := 0
PixelScaling := 1034/(FishBarRight-FishBarLeft)

ToolTipX := WindowWidth/20
ToolTip1 := (WindowHeight/2)-(20*9)
ToolTip2 := (WindowHeight/2)-(20*8)
ToolTip3 := (WindowHeight/2)-(20*7)
ToolTip4 := (WindowHeight/2)-(20*6)
ToolTip5 := (WindowHeight/2)-(20*5)
ToolTip6 := (WindowHeight/2)-(20*4)
ToolTip7 := (WindowHeight/2)-(20*3)
ToolTip8 := (WindowHeight/2)-(20*2)
ToolTip9 := (WindowHeight/2)-(20*1)
ToolTip10 := (WindowHeight/2)
ToolTip11 := (WindowHeight/2)+(20*1)
ToolTip12 := (WindowHeight/2)+(20*2)
ToolTip13 := (WindowHeight/2)+(20*3)
ToolTip14 := (WindowHeight/2)+(20*4)
ToolTip15 := (WindowHeight/2)+(20*5)
ToolTip16 := (WindowHeight/2)+(20*6)
ToolTip17 := (WindowHeight/2)+(20*7)
ToolTip18 := (WindowHeight/2)+(20*8)
ToolTip19 := (WindowHeight/2)+(20*9)
ToolTip20 := (WindowHeight/2)+(20*10)

; FIXED: Added quotes around string comparisons
if (LeftColor3 = "Mossjaw") {
    CurrentLeftColor3 := 0x5C745F
} else if (LeftColor3 = "Kraken") {
    CurrentLeftColor3 := 0x8AD142
} else if (LeftColor3 = "Ancient Kraken") {
    CurrentLeftColor3 := 0x2D376F
}

Navigation := "Off"  ; FIXED: Added quotes around string

ToolTip, Made By Longest, %ToolTipX%, %ToolTip1%, 1
ToolTip, Fisch Macro V13 - Jul 30th, %ToolTipX%, %ToolTip2%, 2
ToolTip, Runtime: 0h 0m 0s, %ToolTipX%, %ToolTip3%, 3

ToolTip, Press "P" to Start, %ToolTipX%, %ToolTip4%, 4
ToolTip, Press "O" to Reload, %ToolTipX%, %ToolTip5%, 5
ToolTip, Press "M" to Exit, %ToolTipX%, %ToolTip6%, 6
ToolTip, Press "Y" to Generate Bar Colors, %ToolTipX%, %ToolTip8%, 8

if (AutoLowerGraphics = true)
    {
    ToolTip, AutoLowerGraphics: true, %ToolTipX%, %ToolTip9%, 9
    }
else
    {
    ToolTip, AutoLowerGraphics: false, %ToolTipX%, %ToolTip9%, 9
    }
    
if (AutoEnableCameraMode = true)
    {
    ToolTip, AutoEnableCameraMode: true, %ToolTipX%, %ToolTip10%, 10
    }
else
    {
    ToolTip, AutoEnableCameraMode: false, %ToolTipX%, %ToolTip10%, 10
    }
    
if (AutoZoomInCamera = true)
    {
    ToolTip, AutoZoomInCamera: true, %ToolTipX%, %ToolTip11%, 11
    }
else
    {
    ToolTip, AutoZoomInCamera: false, %ToolTipX%, %ToolTip11%, 11
    }
    
if (AutoLookDownCamera = true)
    {
    ToolTip, AutoLookDownCamera: true, %ToolTipX%, %ToolTip12%, 12
    }
else
    {
    ToolTip, AutoLookDownCamera: false, %ToolTipX%, %ToolTip12%, 12
    }
ToolTip, Navigation Key: "%NavigationKey%", %ToolTipX%, %ToolTip14%, 14

if (ShakeMode = "Click")
    {
    ToolTip, Shake Mode: "Click", %ToolTipX%, %ToolTip16%, 16
    }
else if (ShakeMode = "Navigation")
    {
    ToolTip, Shake Mode: "Navigation", %ToolTipX%, %ToolTip16%, 16
    }
else
    {
    ToolTip, Shake Mode: "Wait", %ToolTipX%, %ToolTip16%, 16
    }
return

;====================================================================================================;

CloseInviteButton:
; Close invite if detected
InviteX := 0
InviteY := 0
PixelSearch, InviteX, InviteY, InviteAreaLeft, InviteAreaTop, InviteAreaRight, InviteAreaBottom, 0x151212, 10, Fast
if !ErrorLevel {
    Click, %CloseInviteX%, %CloseInviteY%  ; FIXED: Added % signs around variables
}
return

; Thanks Lunar
runtime:
    runtimeS++
    if (runtimeS >= 60)
    {
        runtimeS := 0
        runtimeM++
    }
    if (runtimeM >= 60)
    {
        runtimeM := 0
        runtimeH++
    }

    ToolTip, Runtime: %runtimeH%h %runtimeM%m %runtimeS%s, %ToolTipX%, %ToolTip3%, 3

    if (WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("ahk_exe eurotruck2.exe")) {
        if (!WinActive("ahk_exe RobloxPlayerBeta.exe") || !WinActive("ahk_exe eurotruck2.exe")) {
            WinActivate
        }
    }
    else {
        exitapp
    }
return

;====================================================================================================;

#IfWinNotActive, ahk_class AutoHotkeyGUI
$o::Reload
$m::ExitApp
$p:: goto StartCalculation
$y:: goto CalculateControl
#IfWinNotActive


CalculateControl:
;====================================================================================================;
; Use Lunar's Bar Calculation to calculate distance between half of screen and bar area
if (Control = 0) {
    Control := 0.001
}
if (NegativeControl = true) {
    WhiteBarSize := Round((A_ScreenWidth / 247.03) * (InStr(Control, "0.") ? (Control * -100) : Control) + (A_ScreenWidth / 8.2759), 0)
} else {
    WhiteBarSize := Round((A_ScreenWidth / 247.03) * (InStr(Control, "0.") ? (Control * 100) : Control) + (A_ScreenWidth / 8.2759), 0)
}
; Now define HalfBarSize and HalfScreenWidth
HalfScreenWidth := WindowWidth / 2
HalfBarSize := WhiteBarSize / 2

    ; Bar Color detection (center of the bar)
    LeftColorX := HalfScreenWidth - HalfBarSize + 9
    LeftColorY := WindowHeight / 1.1701
    PixelGetColor, CurrentLeftColor, LeftColorX, LeftColorY
    ToolTip, Bar Color: %CurrentLeftColor%, %ToolTipX%, %ToolTip10%, 10

    ; Arrow 1 (left arrow) detection
    ArrowColorY := WindowHeight / 1.1663
    ArrowColorX := HalfScreenWidth - HalfBarSize + 30 + (28.5714 * Control * ResolutionScalingX)
    PixelGetColor, ArrowColor, ArrowColorX, ArrowColorY
    ToolTip, Arrow Color 1: %ArrowColor%, %ToolTipX%, %ToolTip11%, 11

    ; Arrow 2 (right arrow) detection
    Send, {LButton down}
    Sleep, 50
    ArrowColor2X := WhiteBarSize - ArrowColorX
    PixelGetColor, ArrowColor2, ArrowColor2X, ArrowColorY
    ToolTip, Arrow Color 2: %ArrowColor2%, %ToolTipX%, %ToolTip12%, 12
    Send, {LButton up}

    ; Fish color detection
    FishColorX := HalfScreenWidth
    FishColorY := WindowHeight / 1.1701
    PixelGetColor, FishColor, FishColorX, FishColorY
    ToolTip, Fish Color: %FishColor%, %ToolTipX%, %ToolTip13%, 13

;======================== Save Colors ==========================
; Read existing settings but exclude color lines
FileRead, SettingsContent, %SettingsFileName%
CleanSettings := ""

Loop, Parse, SettingsContent, `n, `r
{
    Line := Trim(A_LoopField)
    if (Line = "" || RegExMatch(Line, "^(LeftColor|ArrowColor|ArrowColor2|FishColor)="))
        continue
    CleanSettings .= Line . "`n"
}

CleanSettings := Trim(CleanSettings)

; Build new settings content
NewSettingsContent := CleanSettings
if (NewSettingsContent != "")
    NewSettingsContent .= "`n"
    
NewSettingsContent .= "LeftColor=" . CurrentLeftColor . "`n"
NewSettingsContent .= "ArrowColor=" . ArrowColor . "`n"
NewSettingsContent .= "ArrowColor2=" . ArrowColor2 . "`n" 
NewSettingsContent .= "FishColor=" . FishColor

; Save back to file
FileDelete, %SettingsFileName%
FileAppend, %NewSettingsContent%, %SettingsFileName%

; Update GUI controls
GuiControl,, LeftColor, %CurrentLeftColor%
GuiControl,, ArrowColor, %ArrowColor%
GuiControl,, ArrowColor2, %ArrowColor2%
GuiControl,, FishColor, %FishColor%

ToolTip, Bar colors saved to %SettingsFileName%, %ToolTipX%, %ToolTip14%, 14
return


StartCalculation:
;====================================================================================================;

gosub, Calculations
SetTimer, runtime, 1000

ToolTip, Press "O" to Reload, %ToolTipX%, %ToolTip4%, 4
ToolTip, Press "M" to Exit, %ToolTipX%, %ToolTip5%, 5
ToolTip, Do NOT use Roblox in Fullscreen, %ToolTipX%, %ToolTip6%, 6
ToolTip, , , , 10
ToolTip, , , , 11
ToolTip, , , , 12
ToolTip, , , , 14
ToolTip, , , , 16

; removed minigame detection method because if it detect the fish it can detect it even in blox fruits and duskwire
DetectionColor := FishColor

ToolTip, Current Task: AutoLowerGraphics, %ToolTipX%, %ToolTip7%, 7
ToolTip, F10 Count: 0/20, %ToolTipX%, %ToolTip9%, 9
f10counter := 0
if (AutoLowerGraphics = true)
    {
    Send, {shift}
    ToolTip, Action: Press Shift, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
    Send, {shift down}
    ToolTip, Action: Hold Shift, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
    loop, 20
        {
        f10counter++
        ToolTip, F10 Count: %f10counter%/20, %ToolTipX%, %ToolTip9%, 9
        Send, {f10}
        ToolTip, Action: Press F10, %ToolTipX%, %ToolTip8%, 8
        Sleep, 50
        }
    Send, {shift up}
    ToolTip, Action: Release Shift, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
    }

ToolTip, Current Task: AutoZoomInCamera, %ToolTipX%, %ToolTip7%, 7
ToolTip, Scroll In: 0/20, %ToolTipX%, %ToolTip9%, 9
ToolTip, Scroll Out: 0/1, %ToolTipX%, %ToolTip10%, 10
scrollcounter := 0
if (AutoZoomInCamera = true)
    {
    Sleep, 50
    loop, 20
        {
        scrollcounter++
        ToolTip, Scroll In: %scrollcounter%/20, %ToolTipX%, %ToolTip9%, 9
        Send, {wheelup}
        ToolTip, Action: Scroll In, %ToolTipX%, %ToolTip8%, 8
        Sleep, 50
        }
    Send, {wheeldown}
    ToolTip, Scroll Out: 1/1, %ToolTipX%, %ToolTip10%, 10
    ToolTip, Action: Scroll Out, %ToolTipX%, %ToolTip8%, 8
    AutoZoomDelay := AutoZoomDelay*5
    Sleep, 50
    }

RestartMacro:
; Removed auto blur because the game disable blur in minigame
ToolTip, , , , 10

ToolTip, Current Task: AutoEnableCameraMode, %ToolTipX%, %ToolTip7%, 7
ToolTip, Right Count: 0/10, %ToolTipX%, %ToolTip9%, 9
rightcounter := 0

if (AutoEnableCameraMode = true) {
    PixelSearch, , , LevelCheckLeft, LevelCheckTop, LevelCheckRight, LevelCheckBottom, 0xACDCFF, 0, Fast
    if !ErrorLevel {
        Sleep, 50
        Send, {2}
        ToolTip, Action: Press 2, %ToolTipX%, %ToolTip8%, 8
        Sleep, 50
        Send, {1}
        ToolTip, Action: Press 1, %ToolTipX%, %ToolTip8%, 8
        Sleep, 50

        if (NavigationFail = true)
        {
            Send, {esc}
            Sleep, 50
            Send, {esc}
            Sleep, 50
            Send, {%NavigationKey%}
            Sleep, 50
            NavigationFail := false
        }

        Sleep, 50
        Send, {%NavigationKey%}
        Navigation := "On"  ; FIXED: Added quotes
        ToolTip, Action: Press %NavigationKey%, %ToolTipX%, %ToolTip8%, 8
        Sleep, 50

        loop, 10
        {
            rightcounter++
            ToolTip, Right Count: %rightcounter%/10, %ToolTipX%, %ToolTip9%, 9
            Send, {right}
            ToolTip, Action: Press Right, %ToolTipX%, %ToolTip8%, 8
            Sleep, 90
        }

        Send, {enter}
        ToolTip, Action: Press Enter, %ToolTipX%, %ToolTip8%, 8
        Sleep, 50

        if (ShakeMode = "Click")
        {
            Send, {%NavigationKey%}
            Navigation := "Off"  ; FIXED: Added quotes
        }
    }
}

ToolTip, , , , 9
ToolTip, Current Task: AutoLookDownCamera, %ToolTipX%, %ToolTip7%, 7
if (AutoLookDownCamera = true)
    {
    Send, {rbutton up}
    Sleep, 50
    MouseMove, LookDownX, LookDownY
    ToolTip, Action: Position Mouse, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
    Send, {rbutton down}
    ToolTip, Action: Hold Right Click, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
    DllCall("mouse_event", "Int", 0x01, "Int", 0, "Int", 10000)
    ToolTip, Action: Move Mouse Down, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
    Send, {rbutton up}
    ToolTip, Action: Release Right Click, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
    MouseMove, LookDownX, LookDownY
    ToolTip, Action: Position Mouse, %ToolTipX%, %ToolTip8%, 8
    Sleep, 50
}
    
ToolTip, Current Task: Press Navigation Key, %ToolTipX%, %ToolTip7%, 7	
if (ShakeMode = "Navigation") and (Navigation := "Off") {  ; FIXED: Added quotes
    Send, {%NavigationKey%}
    Navigation := "On"  ; FIXED: Added quotes
}

if (PerfectCast = true) {
    ToolTip, Current Task: Zoom out (Perfect Cast), %ToolTipX%, %ToolTip7%, 7
    
    ; Zoom out
    Loop, 4 {
        Send, {wheeldown}
        Sleep, 50
    }

    Send, {rbutton up}
    Sleep, 50
    MouseMove, LookDownX, LookDownY
    Sleep, 50
    Send, {rbutton down}
    Sleep, 50
    DllCall("mouse_event", "Int", 0x01, "Int", 0, "Int", -10000)
    Sleep, 50
    Send, {rbutton up}
    Sleep, 50
    MouseMove, LookDownX, LookDownY
    Sleep, 50

    ; Start holding left click to charge cast
    Send, {LButton down}

    ; Look for perfect cast (white touching green)
    Loop, 300 {
        ; Look for green area first
        PixelSearch, GreenX, GreenY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0x4AAB61, %PerfectCastTolerance%, Fast
        if (ErrorLevel) {
            Send, {rbutton up}
            Sleep, 50
            MouseMove, LookDownX, LookDownY
            Sleep, 50
            Send, {rbutton down}
            Sleep, 50
            DllCall("mouse_event", "Int", 0x01, "Int", 20, "Int", 0)
            Sleep, 50
            Send, {rbutton up}
            Sleep, 50
            MouseMove, LookDownX, LookDownY
            Sleep, 50 ; Small delay to prevent excessive CPU usage
            continue
        }

        ; Look for white area
        PixelSearch, WhiteX, WhiteY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0xD8E2E2, %PerfectCastTolerance%, Fast
        if (ErrorLevel) {
            Sleep, 10
            continue
        }

        ; Clear ToolTips when both colors are found
        ToolTip,,,,8

        ; Check if white and green areas touch (within 60 pixels)
        if (Abs(WhiteX - GreenX) <= 60 && Abs(WhiteY - GreenY) <= 60) {
            break
        }
        
        ; Small delay to prevent excessive CPU usage
        Sleep, 10
    }
    Send, {LButton up}
    ; Zoom back in
    Loop, 4 {
        Send, {wheelup}
        Sleep, 50
    }
    
    ; Clear final ToolTip
    ToolTip,,,,7
    Send, {rbutton up}
    Sleep, 50
    MouseMove, LookDownX, LookDownY
    Sleep, 50
    Send, {rbutton down}
    Sleep, 50
    DllCall("mouse_event", "Int", 0x01, "Int", 0, "Int", 10000)
    Sleep, 50
    Send, {rbutton up}
    Sleep, 50
    MouseMove, LookDownX, LookDownY
    Sleep, 50
} else {
    ToolTip, Current Task: Casting Rod, %ToolTipX%, %ToolTip7%, 7
    Send, {LButton down}
    ToolTip, Action: Casting For %HoldRodCastDuration%ms, %ToolTipX%, %ToolTip8%, 8
    Sleep, %HoldRodCastDuration%
    Send, {LButton up}
}
; This section is not related to the holding cast mechanic
ToolTip, Action: Waiting For Bobber (%WaitForBobberDelay%ms), %ToolTipX%, %ToolTip8%, 8
Sleep, %WaitForBobberDelay%
if (ShakeMode = "Click")
    goto ClickShakeMode
else if (ShakeMode = "Navigation")
    goto NavigationShakeMode
else if (ShakeMode = "Wait")
    goto WaitShakeMode

;====================================================================================================;

ClickShakeMode:

ShakeStartTime := A_TickCount

ToolTip, Current Task: Shaking, %ToolTipX%, %ToolTip7%, 7
ToolTip, Click X: None, %ToolTipX%, %ToolTip8%, 8
ToolTip, Click Y: None, %ToolTipX%, %ToolTip9%, 9
ToolTip, Click Count: 0, %ToolTipX%, %ToolTip11%, 11
ToolTip, Bypass Count: 0/10, %ToolTipX%, %ToolTip12%, 12
ToolTip, Failsafe: 0/%ShakeFailsafe%, %ToolTipX%, %ToolTip14%, 14

ClickFailsafeCount := 0
ClickCount := 0
ClickShakeRepeatBypassCounter := 0
MemoryX := 0
MemoryY := 0
ForceReset := false

SetTimer, ClickShakeFailsafe, 1000

ClickShakeModeRedo:
if (ForceReset)
{
    ToolTip,,,11
    ToolTip,,,12
    ToolTip,,,14
    goto RestartMacro
}

Sleep, %ClickScanDelay%

; --- Detect minigame trigger color ---
PixelSearch,,, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %DetectionColor%, %FishLeftColorTolerance%, Fast
if !ErrorLevel
{
    SetTimer, ClickShakeFailsafe, off
    ToolTip,,,9
    ToolTip,,,11
    ToolTip,,,12
    ToolTip,,,14
    goto BarMinigame
}

; --- Detect shake click color ---
PixelSearch, ClickX, ClickY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0xFFFFFF, %ShakeTolerance%, Fast
if !ErrorLevel
{
    ToolTip, Click X: %ClickX%, %ToolTipX%, %ToolTip8%, 8
    ToolTip, Click Y: %ClickY%, %ToolTipX%, %ToolTip9%, 9

    if (ClickX != MemoryX || ClickY != MemoryY)
    {
        ClickShakeRepeatBypassCounter := 0
        ToolTip, Bypass Count: %ClickShakeRepeatBypassCounter%/10, %ToolTipX%, %ToolTip12%, 12
        ClickCount++
        Click, %ClickX%, %ClickY%
        ToolTip, Click Count: %ClickCount%, %ToolTipX%, %ToolTip11%, 11
        MemoryX := ClickX
        MemoryY := ClickY
        goto ClickShakeModeRedo
    }
    else
    {
        ClickShakeRepeatBypassCounter++
        ToolTip, Bypass Count: %ClickShakeRepeatBypassCounter%/10, %ToolTipX%, %ToolTip12%, 12
        if (ClickShakeRepeatBypassCounter >= 10)
        {
            MemoryX := 0
            MemoryY := 0
        }
        goto ClickShakeModeRedo
    }
}

goto ClickShakeModeRedo
return

;====================================================================================================;

ClickShakeFailsafe:
    ClickFailsafeCount++
    ToolTip, Failsafe: %ClickFailsafeCount%/%ShakeFailsafe%, %ToolTipX%, %ToolTip14%, 14
    if (ClickFailsafeCount >= ShakeFailsafe)
    {
        SetTimer, ClickShakeFailsafe, off
        ForceReset := true
    }
return

NavigationShakeFailsafe:
ShakeStartTime := A_TickCount
NavigationFailsafeCount++
ToolTip, Failsafe: %NavigationFailsafeCount%/%ShakeFailsafe%, %ToolTipX%, %ToolTip10%, 10
if (NavigationFailsafeCount >= ShakeFailsafe)
    {
    SetTimer, NavigationShakeFailsafe, off
    ForceReset := true
    }
return

NavigationShakeMode:

ToolTip, Current Task: Shaking, %ToolTipX%, %ToolTip7%, 7
ToolTip, Attempt Count: 0, %ToolTipX%, %ToolTip8%, 8
ToolTip, Failsafe: 0/%ShakeFailsafe%, %ToolTipX%, %ToolTip10%, 10

NavigationFailsafeCount := 0
NavigationCounter := 0
ForceReset := false

SetTimer, NavigationShakeFailsafe, 1000

NavigationShakeModeRedo:
if (ForceReset)
{
    ToolTip,,,10
    NavigationFail := true
    goto RestartMacro
}

Sleep, %NavigationSpamDelay%

; --- Minigame trigger detection ---
PixelSearch,,, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %DetectionColor%, %FishLeftColorTolerance%, Fast
if !ErrorLevel
{
    SetTimer, NavigationShakeFailsafe, off
    goto BarMinigame
}

NavigationCounter++
ToolTip, Attempt Count: %NavigationCounter%, %ToolTipX%, %ToolTip8%, 8
Send, {Enter}
goto NavigationShakeModeRedo

WaitShakeFailsafe:
WaitFailsafeCount++
ToolTip, Failsafe: %WaitFailsafeCount%/%ShakeFailsafe%, %ToolTipX%, %ToolTip15%, 15
if (WaitFailsafeCount >= ShakeFailsafe)
    {
    SetTimer, WaitShakeFailsafe, off
    ForceReset := true
    }
return

WaitShakeMode:

ToolTip, Current Task: Waiting, %ToolTipX%, %ToolTip7%, 7
ToolTip, Wait Time: %WaitUntilClicking% ms, %ToolTipX%, %ToolTip8%, 8
ToolTip, Click Status: Pending, %ToolTipX%, %ToolTip9%, 9
ToolTip, Failsafe: 0/%ShakeFailsafe%, %ToolTipX%, %ToolTip15%, 15

WaitFailsafeCount := 0
ForceReset := false

SetTimer, WaitShakeFailsafe, 1000

Sleep, %WaitUntilClicking%

Click
ToolTip, Click Status: Forced Click, %ToolTipX%, %ToolTip9%, 9

WaitShakeModeRedo:
if (ForceReset)
{
    ToolTip,,,15
    goto RestartMacro
}

; --- Detect minigame trigger (same as others) ---
PixelSearch,,, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %DetectionColor%, %FishLeftColorTolerance%, Fast
if !ErrorLevel
{
    SetTimer, WaitShakeFailsafe, off
    ToolTip,,,7
    ToolTip,,,8
    ToolTip,,,9
    ToolTip,,,15
    goto BarMinigame
}

; If color not found, keep waiting for it
Sleep, 50
goto WaitShakeModeRedo

; ==========Bar Minigame Code==========

BarMinigame:
Sleep, %BaitDelay%

; Try first color
PixelSearch, FoundX, FoundY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %LeftColor2%, %WhiteLeftColorTolerance%, Fast
if (!ErrorLevel) {
    PixelGetColor, CurrentLeftColor, FoundX, FoundY
    CurrentLeftColor := LeftColor2
} else {
    ; Try second color
    PixelSearch, FoundX, FoundY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %LeftColor%, %WhiteLeftColorTolerance%, Fast
    if (!ErrorLevel) {
        PixelGetColor, CurrentLeftColor, FoundX, FoundY
        CurrentLeftColor := LeftColor
    }
}


if (Sera = true) {
        ToolTip, Current Task: Stablizing Seraphic, %ToolTipX%, %ToolTip7%, 7
        ToolTip, , , , 8
        Loop, %SeraCycles%
        {
            Send, {LButton down}
            Sleep, 50
            Send, {LButton up}
            Sleep, 30
        }
        Send, {LButton down}
        Sleep, 800
        Send, {LButton up}
}

if (RandomRod = true) {
    PixelSearch, BarAreaX, BarAreaY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %ArrowColor2%, %WhiteLeftColorTolerance%, Fast
    ; Hold left click for 100 ms
    Send, {LButton down}
    Sleep, 50

    ; While holding left click, find the arrow color
    PixelSearch, ArrowAreaX, ArrowAreaY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %ArrowColor2%, %WhiteLeftColorTolerance%, Fast
    Sleep, 50

    ; Release right click
    Send, {LButton up}
    if (!ErrorLevel) {
        WhiteBarSize := ArrowAreaX - BarAreaX
    }
    ; Control and fallback calculations remain the same
    Control := 0.2
    NegativeControl := true
    WhiteBarSize2 := Round((A_ScreenWidth / 247.03) * (InStr(Control, "0.") ? (Control * -100) : Control) + (A_ScreenWidth / 8.2759), 0)
    if (WhiteBarSize2 > WhiteBarSize) {
        WhiteBarSize := WhiteBarSize2
    }
}

; Thanks Lunar Bar Calculations
if (Control = 0) {
    Control := 0.001
}
if (RandomRod != true) {  ; Only calculate WhiteBarSize this way if NOT using random rod
    if (NegativeControl = true) {
        WhiteBarSize := Round((A_ScreenWidth / 247.03) * (InStr(Control, "0.") ? (Control * -100) : Control) + (A_ScreenWidth / 8.2759), 0)
    } else {
        WhiteBarSize := Round((A_ScreenWidth / 247.03) * (InStr(Control, "0.") ? (Control * 100) : Control) + (A_ScreenWidth / 8.2759), 0)
    }
}

Sleep, 50
goto BarMinigameSingle


;====================================================================================================;

BarMinigameSingle:

    EndMinigame := false
    ToolTip, Current Task: Playing Bar Minigame, %ToolTipX%, %ToolTip7%, 7
    ToolTip, Bar Size: %WhiteBarSize%, %ToolTipX%, %ToolTip8%, 8
    ToolTip, Looking for Bar, %ToolTipX%, %ToolTip10%, 10
    HalfBarSize := WhiteBarSize/2
    Deadzone := WhiteBarSize*0.1
    Deadzone2 := HalfBarSize*0.75

    MaxLeftBar := FishBarLeft+(WhiteBarSize*SideBarRatio)
    MaxRightBar := FishBarRight-(WhiteBarSize*SideBarRatio)
    SetTimer, BarMinigame2, %ScanDelay%

BarMinigameAction:
    Loop {
        if (EndMinigame = true)
        {
            Sleep, %RestartDelay%
            goto RestartMacro
        }
        if (Action = 0)
        {
            SideToggle := false
            Send, {LButton down}
            Sleep, 10
            Send, {LButton up}
            Sleep, 10
        }
        else if (Action = 1)
        {
            SideToggle := false
            Send, {LButton up}
            if (AnkleBreak = false)
            {
                Sleep, %AnkleBreakDuration%
                AnkleBreakDuration := 0
            }
            AdaptiveDuration := 0.5 + 0.5 * (DistanceFactor ** 1.2)
            if (DistanceFactor < 0.2)
                AdaptiveDuration := 0.15 + 0.15 * DistanceFactor
            Duration := Abs(Direction) * StableLeftMultiplier * PixelScaling * AdaptiveDuration
            Sleep, %Duration%
            Send, {LButton down}
            CounterStrafe := Duration/StableLeftDivision
            Sleep, %CounterStrafe%
            AnkleBreak := true
            AnkleBreakDuration := AnkleBreakDuration+(Duration-CounterStrafe)*LeftAnkleBreakMultiplier
        }
        else if (Action = 2)
        {
            SideToggle := false
            Send, {LButton down}
            if (AnkleBreak = true)
            {
                Sleep, %AnkleBreakDuration%
                AnkleBreakDuration := 0
            }
            AdaptiveDuration := 0.5 + 0.5 * (DistanceFactor ** 1.2)
            if (DistanceFactor < 0.2)
                AdaptiveDuration := 0.15 + 0.15 * DistanceFactor
            Duration := Abs(Direction) * StableRightMultiplier * PixelScaling * AdaptiveDuration
            Sleep, %Duration%
            Send, {LButton up}
            CounterStrafe := Duration/StableRightDivision
            Sleep, %CounterStrafe%
            AnkleBreak := false
            AnkleBreakDuration := AnkleBreakDuration+(Duration-CounterStrafe)*RightAnkleBreakMultiplier
        }
        else if (Action = 3)
        {
            if (SideToggle = false)
            {
                AnkleBreak := false
                AnkleBreakDuration := 0
                SideToggle := true
                Send, {LButton up}
                Sleep, %SideDelay%
            }
            Sleep, %ScanDelay%
        }
        else if (Action = 4)
        {
            if (SideToggle = false)
            {
                AnkleBreak := false
                AnkleBreakDuration := 0
                SideToggle := true
                Send, {LButton down}
                Sleep, %SideDelay%
            }
            Sleep, %ScanDelay%
        }
        else if (Action = 5)
        {
            SideToggle := false
            Send, {LButton up}
            if (AnkleBreak = false)
            {
                Sleep, %AnkleBreakDuration%
                AnkleBreakDuration := 0
            }
            MinDuration := 10
            if (Control >= 0.25)
                MaxDuration := WhiteBarSize * 0.75
            else if (Control >= 0.2)
                MaxDuration := WhiteBarSize * 0.8
            else if (Control >= 0.15)
                MaxDuration := WhiteBarSize * 0.88
            else
                MaxDuration := WhiteBarSize + (Abs(Direction) * 0.2)

            Duration := Max(MinDuration, Min(Abs(Direction) * UnstableLeftMultiplier * PixelScaling, MaxDuration))
            Sleep, %Duration%
            Send, {LButton down}
            CounterStrafe := Duration/UnstableLeftDivision
            Sleep, %CounterStrafe%
            AnkleBreak := true
            AnkleBreakDuration := AnkleBreakDuration+(Duration-CounterStrafe)*LeftAnkleBreakMultiplier
        }
        else if (Action = 6)
        {
            SideToggle := false
            Send, {LButton down}
            if (AnkleBreak = true)
            {
                Sleep, %AnkleBreakDuration%
                AnkleBreakDuration := 0
            }
            MinDuration := 10
            if (Control >= 0.25)
                MaxDuration := WhiteBarSize * 0.75
            else if (Control >= 0.2)
                MaxDuration := WhiteBarSize * 0.8
            else if (Control >= 0.15)
                MaxDuration := WhiteBarSize * 0.88
            else
                MaxDuration := WhiteBarSize + (Abs(Direction) * 0.2)

            Duration := Max(MinDuration, Min(Abs(Direction) * UnstableRightMultiplier * PixelScaling, MaxDuration))
            Sleep, %Duration%
            Send, {LButton up}
            CounterStrafe := Duration/UnstableRightDivision
            Sleep, %CounterStrafe%
            AnkleBreak := false
            AnkleBreakDuration := AnkleBreakDuration+(Duration-CounterStrafe)*RightAnkleBreakMultiplier
        }
        else
        {
            Sleep, %ScanDelay%
        }
}

BarMinigame2:
    Sleep, 1
    PixelSearch, FishX, FishY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %FishColor%, %FishLeftColorTolerance%, Fast
    if !ErrorLevel
    {
        ToolTip, +, %FishX%, %FishBarToolTipHeight%, 20
        if (FishX < MaxLeftBar)
        {
            Action := 3
            ToolTip, |, %MaxLeftBar%, %FishBarToolTipHeight%, 19
            ToolTip, Direction: Max Left, %ToolTipX%, %ToolTip10%, 10
            PixelSearch, ArrowX, ArrowY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %ArrowColor%, %ArrowColorTolerance%, Fast
            if !ErrorLevel
            {
                ToolTip, <-, %ArrowX%, %FishBarToolTipHeight%, 18
                if (MaxLeftBar < ArrowX)
                {
                    SideToggle := false
                }
            }
            return
        }
        else if (FishX > MaxRightBar)
        {
            Action := 4
            ToolTip, |, %MaxRightBar%, %FishBarToolTipHeight%, 19
            ToolTip, Direction: Max Right, %ToolTipX%, %ToolTip10%, 10
            PixelSearch, ArrowX, ArrowY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %ArrowColor2%, %ArrowColorTolerance%, Fast
            if !ErrorLevel
            {
                ToolTip, ->, %ArrowX%, %FishBarToolTipHeight%, 18
                if (MaxRightBar > ArrowX)
                {
                    SideToggle := false
                }
            }
            return
        }
        PixelSearch, BarX, BarY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %LeftColor%, %WhiteLeftColorTolerance%, Fast
        if !ErrorLevel
        {
            ToolTip, , , , 18
            BarX := BarX + HalfBarSize
            Direction := BarX - FishX
            DistanceFactor := Abs(Direction) / HalfBarSize
            DistanceFactor := Max(0.01, DistanceFactor)

            Ratio2 := Deadzone2/WhiteBarSize
            if (Direction > Deadzone && Direction < Deadzone2)
            {
                Action := 1
                ToolTip, Tracking direction: <, %ToolTipX%, %ToolTip10%, 10
                ToolTip, <, %BarX%, %FishBarToolTipHeight%, 19
            }
            else if (Direction < -Deadzone && Direction > -Deadzone2)
            {
                Action := 2
                ToolTip, Tracking direction: >, %ToolTipX%, %ToolTip10%, 10
                ToolTip, >, %BarX%, %FishBarToolTipHeight%, 19
            }
            else if (Direction > Deadzone2)
            {
                Action := 5
                ToolTip, Tracking direction: < (Fast), %ToolTipX%, %ToolTip10%, 10
                ToolTip, <, %BarX%, %FishBarToolTipHeight%, 19
            }
            else if (Direction < -Deadzone2)
            {
                Action := 6
                ToolTip, Tracking direction: > (Fast), %ToolTipX%, %ToolTip10%, 10
                ToolTip, >, %BarX%, %FishBarToolTipHeight%, 19
            }
            else
            {
                Action := 0
                ToolTip, Stabilizing, %ToolTipX%, %ToolTip10%, 10
                ToolTip, ., %BarX%, %FishBarToolTipHeight%, 19
            }
        }
        else
        {
            Direction := (ArrowX > 0) ? HalfBarSize : -HalfBarSize
            PixelSearch, ArrowX, ArrowY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %ArrowColor%, %ArrowColorTolerance%, Fast
            ArrowX := ArrowX-FishX
            if (ArrowX > 0)
            {
                Action := 5
                BarX := FishX+HalfBarSize
                ToolTip, Tracking direction: < (Fast), %ToolTipX%, %ToolTip10%, 10
                ToolTip, <, %BarX%, %FishBarToolTipHeight%, 19
            }
            else
            {
                Action := 6
                BarX := FishX-HalfBarSize
                ToolTip, Tracking direction: > (Fast), %ToolTipX%, %ToolTip10%, 10
                ToolTip, >, %BarX%, %FishBarToolTipHeight%, 19
            }
        }
    }
else
{
    Click, %CloseInviteX%, %CloseInviteY%  ; FIXED: Added % signs
    ToolTip, , , , 10
    ToolTip, , , , 11
    ToolTip, , , , 12
    ToolTip, , , , 13
    ToolTip, , , , 14
    ToolTip, , , , 15
    ToolTip, , , , 17
    ToolTip, , , , 18
    ToolTip, , , , 19
    ToolTip, , , , 20
    EndMinigame := true
    SetTimer, BarMinigame2, Off
}