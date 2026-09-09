; PyWare Fishing V4.41 (Lite)
; Build: July 10th Global Settings
; Developer: Catman2608

; Initialization
#SingleInstance Force
FileEncoding, UTF-8
setkeydelay, -1
setmousedelay, -1
setbatchlines, -1
SetTitleMatchMode 2

CoordMode, ToolTip, Relative
CoordMode, Pixel, Relative
CoordMode, Mouse, Relative

; GUI (0xRRGGBB)

Gui, +Resize +MinSize
Gui, Color, 0x1D1D1D
Gui, Font, s13 cFFFFFF Bold, Segoe UI
Gui, Add, Text, x30 y10, PyWare Fishing V4.41 (Lite)
Gui, Font, s9 cFFFFFF Norm, Segoe UI
Gui, Add, Tab2, x20 y40 w650 h550, Basic|Automation|About

; Top Bar
Configs := ""

Loop, Files, %A_ScriptDir%\Configs\*.ini
{
    SplitPath, A_LoopFileName,,, Extension, FileName
    Configs .= FileName "|"
}

; Remove trailing |
Configs := RTrim(Configs, "|")

Gui, Add, ComboBox, x530 y10 w100 h100 vActiveConfig cBlack gConfigChange, %Configs%
Gui, Add, Button, x410 y10 w100 h22 gCalculations, 🖩 Detect Roblox

; Basic tab
Gui, Tab, Basic
Gui, Font, s9 c0x90EE90 Bold
Gui, Add, Text, x40 y80, Basic Settings

Gui, Font, s9 c0x90EE90 Bold
Gui, Add, GroupBox, x40 y110 w300 h100, Hotkey Settings
Gui, Font, s9 cWhite Norm

Gui, Add, Checkbox, x220 y80 vHotkeyState gEnableHotkeys, Enable Hotkeys

Gui, Add, Text, x60 y130, Start Key:
Gui, Add, Edit, x220 y130 w100 vStartKey cBlack, F5

Gui, Add, Text, x60 y160, Stop Key:
Gui, Add, Edit, x220 y160 w100 vStopKey cBlack, F7

Gui, Font, s9 c0x90EE90 Bold
Gui, Add, GroupBox, x350 y110 w300 h100, Hotbar Settings
Gui, Font, s9 cWhite Norm

Gui, Add, Text, x370 y130, Fishing Rod Key:
Gui, Add, Edit, x530 y130 w100 vFishingRodKey cBlack, 1

Gui, Add, Text, x370 y160, Equipment Bag Key:
Gui, Add, Edit, x530 y160 w100 vEquipmentBagKey cBlack, 2

Gui, Font, s9 c0x90EE90 Bold
Gui, Add, GroupBox, x40 y220 w610 h210, Color Options (0xBBGGRR)
Gui, Font, s9 cWhite Norm

Gui, Add, Text, x60 y240, Initial Control:
Gui, Add, Edit, x220 y240 w100 vInitialControl cBlack, 0

Gui, Add, Text, x60 y270, Left Bar Color:
Gui, Add, Edit, x220 y270 w100 vLeftColor cBlack, 0xF1F1F1

Gui, Add, Text, x60 y300, Right Bar Color:
Gui, Add, Edit, x220 y300 w100 vRightColor cBlack, 0xFFFFFF

Gui, Add, Text, x60 y330, Arrow Color:
Gui, Add, Edit, x220 y330 w100 vArrowColor cBlack, 0x878584

Gui, Add, Text, x60 y360, Fish Color:
Gui, Add, Edit, x220 y360 w100 vFishColor cBlack, 0x5B4B43

Gui, Add, Text, x60 y390, Shake Color:
Gui, Add, Edit, x220 y390 w100 vShakeColor cBlack, 0xFFFFFF

Gui, Add, Button, x530 y240 w100 h30 gPickColors, 🖌 Pick Colors

Gui, Add, Text, x370 y270, Left Bar Tolerance:
Gui, Add, Edit, x530 y270 w100 vLeftTolerance cBlack, 8

Gui, Add, Text, x370 y300, Right Bar Tolerance:
Gui, Add, Edit, x530 y300 w100 vRightTolerance cBlack, 8

Gui, Add, Text, x370 y330, Arrow Tolerance:
Gui, Add, Edit, x530 y330 w100 vArrowTolerance cBlack, 8

Gui, Add, Text, x370 y360, Fish Tolerance:
Gui, Add, Edit, x530 y360 w100 vFishTolerance cBlack, 4

Gui, Add, Text, x370 y390, Shake Tolerance:
Gui, Add, Edit, x530 y390 w100 vShakeTolerance cBlack, 4

; Automation tab
Gui, Tab, Automation
Gui, Font, s9 c0x87CEEB Bold
Gui, Add, Text, x40 y80, Automation Settings

Gui, Font, s9 c0x87CEEB Bold
Gui, Add, GroupBox, x40 y110 w300 h250, Basic Options
Gui, Font, s9 cWhite Norm

Gui, Add, Text, x60 y130, Auto Select Rod:
Gui, Add, Checkbox, x220 y130 vAutoSelectRod, Enable

Gui, Add, Text, x60 y160, Auto Zoom In:
Gui, Add, Checkbox, x220 y160 vAutoZoomIn, Enable

Gui, Add, Text, x60 y190, Fish Overlay:
Gui, Add, Checkbox, x220 y190 vMeasureArrow, Enable

Gui, Add, Text, x60 y220, Lock Cursor:
Gui, Add, Checkbox, x220 y220 vFixPDController, Enable

Gui, Add, Text, x60 y250, Select Rod Duration (ms):
Gui, Add, Edit, x220 y250 w100 vSelectRodDuration cBlack, 350

Gui, Add, Text, x60 y280, Casting Mode:
Gui, Add, ComboBox, x220 y280 w100 vCastingMode cBlack, Normal|Perfect

Gui, Add, Text, x60 y310, Shake Mode:
Gui, Add, ComboBox, x220 y310 w100 vShakeMode cBlack, Click|Navigation

Gui, Font, s9 c0x87CEEB Bold
Gui, Add, GroupBox, x350 y110 w300 h130, Casting Options
Gui, Font, s9 cWhite Norm

Gui, Add, Text, x370 y130, Delay (ms):
Gui, Add, Edit, x530 y130 w100 vDelayBeforeCasting cBlack, 350

Gui, Add, Text, x370 y160, Duration (ms):
Gui, Add, Edit, x530 y160 w100 vCastDuration cBlack, 350

Gui, Add, Text, x370 y190, Delay (ms):
Gui, Add, Edit, x530 y190 w100 vDelayAfterCasting cBlack, 350

Gui, Font, s9 c0x87CEEB Bold
Gui, Add, GroupBox, x350 y250 w300 h110, Perfect Cast Options
Gui, Font, s9 cWhite Norm

Gui, Add, Text, x370 y270, Scan Delay (ms):
Gui, Add, Edit, x530 y270 w100 vCastScanDelay cBlack, 50

Gui, Add, Text, x370 y300, Cast Timeout (ms):
Gui, Add, Edit, x530 y300 w100 vCastTimeout cBlack, 5000

Gui, Add, Text, x370 y330, Release Delay (ms):
Gui, Add, Edit, x530 y330 w100 vReleaseDelay cBlack, 350

Gui, Font, s9 c0x87CEEB Bold
Gui, Add, GroupBox, x350 y370 w300 h110, Shake Options
Gui, Font, s9 cWhite Norm

Gui, Add, Text, x370 y390, Shake Delay (ms):
Gui, Add, Edit, x530 y390 w100 vShakeScanDelay cBlack, 80

Gui, Add, Text, x370 y420, Shake Failsafe (attempts):
Gui, Add, Edit, x530 y420 w100 vShakeFailsafe cBlack, 80

Gui, Font, s9 c0x87CEEB Bold
Gui, Add, GroupBox, x40 y370 w300 h180, Minigame Options
Gui, Font, s9 cWhite Norm

Gui, Add, Text, x60 y390, Scan Delay (ms):
Gui, Add, Edit, x220 y390 w100 vMinigameScanDelay cBlack, 10

Gui, Add, Text, x60 y420, Restart Delay (ms):
Gui, Add, Edit, x220 y420 w100 vRestartDelay cBlack, 3000

Gui, Add, Text, x60 y450, Bar Ratio from Side:
Gui, Add, Edit, x220 y450 w100 vBarRatioFromSide cBlack, 0.5

Gui, Add, Text, x60 y480, KP (Proportional Gain):
Gui, Add, Edit, x220 y480 w100 vKP cBlack, 0.93

Gui, Add, Text, x60 y510, KD (Derivative Gain):
Gui, Add, Edit, x220 y510 w100 vKD cBlack, 0.07

; About Tab
Gui, Tab, About
Gui, Font, s9 c0xFFFFFF Bold
Gui, Add, Text, x40 y80, About This Macro

; About section
Gui, Font, s9 cFFFFFF Bold
Gui, Add, GroupBox, x40 y110 w600 h160, About this macro
Gui, Font, s9 cFFFFFF Norm

Gui, Add, Picture, x60 y130 w48 h48, % mainDir "Images\\PyWareGardening.png"
Gui, Font, s9 cFFD700 Bold
Gui, Add, Text, x110 y130 w350, Catman2608
Gui, Font, s9 cFFC0CB Bold
Gui, Add, Text, x110 y150 w350, PyWare Fishing V4.41 (Lite)
Gui, Font, s9 cFFFFFF Norm

; Disclaimer section
Gui, Font, s9 cFF4444 Bold
Gui, Add, Text, x60 y190 w550, IMPORTANT DISCLAIMER: 
Gui, Font, s9 cFFFFFF Norm
Gui, Add, Text, x60 y210 w550, Any person claiming to be part of this project or its development, other than Catman2608
Gui, Add, Text, x60 y230 w550, is most likely lying. Be cautious of fake contributors or impersonators.

; Resources section
Gui, Font, s9 cFFFFFF Bold
Gui, Add, GroupBox, x40 y290 w600 h180, Resources
Gui, Font, s9 cFFFFFF Norm

; Links with proper spacing
Gui, Add, Link, x60 y310 w560, <a href="https://discord.com/invite/aMZY8yrF8r">Join PyWare Discord Server</a>
Gui, Add, Link, x60 y340 w560, <a href="https://www.youtube.com/@HexaTitanGaming/">Official YouTube Channel</a>
Gui, Add, Link, x60 y370 w560, <a href="https://sites.google.com/view/icf-automation-network/?tab=t.0">Official PyWare Website</a>
Gui, Add, Link, x60 y400 w560, <a href="https://docs.google.com/document/d/1WwWWMR-eN-R-GO42IioToHpWTgiXkLoiNE_4NeE-GsU/edit?tab=t.0">Upcoming Features</a>


; Show Window and load settings
LoadSettings()
Gui, Show
return

PickColors:
    Loop {
        MouseGetPos, MouseX, MouseY
        PixelGetColor, Color, %MouseX%, %MouseY%

        MouseX += 10
        MouseY += 20
        ToolTip, %Color%, %MouseX%, %MouseY%, 1

        ; Stop the eyedropper when left-click is pressed
        if GetKeyState("LButton", "P") {
            break
        }
        Sleep, 50
    }
return

ConfigChange:
    Gui, Submit, NoHide
    LoadSettings()

SaveSettings:
    Gui, Submit, NoHide
    global ActiveConfig
    if (A_Platform = -1) {
        SettingsFile := A_ScriptDir . "\Configs\" . ActiveConfig . ".ini"
    } else {
        SettingsFile := A_ScriptDir . "/Configs/" . ActiveConfig . ".ini"
    }
    IniWrite, %InitialControl%, %SettingsFile%, Settings, InitialControl
    IniWrite, %LeftColor%, %SettingsFile%, Settings, LeftColor
    IniWrite, %RightColor%, %SettingsFile%, Settings, RightColor
    IniWrite, %ArrowColor%, %SettingsFile%, Settings, ArrowColor
    IniWrite, %FishColor%, %SettingsFile%, Settings, FishColor
    IniWrite, %ShakeColor%, %SettingsFile%, Settings, ShakeColor
    IniWrite, %LeftTolerance%, %SettingsFile%, Settings, LeftTolerance
    IniWrite, %RightTolerance%, %SettingsFile%, Settings, RightTolerance
    IniWrite, %ArrowTolerance%, %SettingsFile%, Settings, ArrowTolerance
    IniWrite, %FishTolerance%, %SettingsFile%, Settings, FishTolerance
    IniWrite, %ShakeTolerance%, %SettingsFile%, Settings, ShakeTolerance
    IniWrite, %AutoSelectRod%, %SettingsFile%, Settings, AutoSelectRod
    IniWrite, %AutoZoomIn%, %SettingsFile%, Settings, AutoZoomIn
    IniWrite, %MeasureArrow%, %SettingsFile%, Settings, MeasureArrow
    IniWrite, %FixPDController%, %SettingsFile%, Settings, FixPDController
    IniWrite, %SelectRodDuration%, %SettingsFile%, Settings, SelectRodDuration
    IniWrite, %CastingMode%, %SettingsFile%, Settings, CastingMode
    IniWrite, %ShakeMode%, %SettingsFile%, Settings, ShakeMode
    IniWrite, %DelayBeforeCasting%, %SettingsFile%, Settings, DelayBeforeCasting
    IniWrite, %CastDuration%, %SettingsFile%, Settings, CastDuration
    IniWrite, %DelayAfterCasting%, %SettingsFile%, Settings, DelayAfterCasting
    IniWrite, %CastScanDelay%, %SettingsFile%, Settings, CastScanDelay
    IniWrite, %CastTimeout%, %SettingsFile%, Settings, CastTimeout
    IniWrite, %ReleaseDelay%, %SettingsFile%, Settings, ReleaseDelay
    IniWrite, %ShakeScanDelay%, %SettingsFile%, Settings, ShakeScanDelay
    IniWrite, %ShakeFailsafe%, %SettingsFile%, Settings, ShakeFailsafe
    IniWrite, %MinigameScanDelay%, %SettingsFile%, Settings, MinigameScanDelay
    IniWrite, %RestartDelay%, %SettingsFile%, Settings, RestartDelay
    IniWrite, %BarRatioFromSide%, %SettingsFile%, Settings, BarRatioFromSide
    IniWrite, %KP%, %SettingsFile%, Settings, KP
    IniWrite, %KD%, %SettingsFile%, Settings, KD

    GoSub, SaveGlobalSettings
    ; MsgBox, Saved %ActiveConfig% at %SettingsFile%
    return

LoadSettings() {
    Gui, Submit, NoHide
    global ActiveConfig
    if (A_Platform = -1) {
        SettingsFile := A_ScriptDir . "\Configs\" . ActiveConfig . ".ini"
    } else {
        SettingsFile := A_ScriptDir . "/Configs/" . ActiveConfig . ".ini"
    }
    IniRead, InitialControl, %SettingsFile%, Settings, InitialControl, 0
    IniRead, LeftColor, %SettingsFile%, Settings, LeftColor, 0xF1F1F1
    IniRead, RightColor, %SettingsFile%, Settings, RightColor, 0xFFFFFF
    IniRead, ArrowColor, %SettingsFile%, Settings, ArrowColor, 0x878584
    IniRead, FishColor, %SettingsFile%, Settings, FishColor, 0x5B4B43
    IniRead, ShakeColor, %SettingsFile%, Settings, ShakeColor, 0xFFFFFF
    IniRead, LeftTolerance, %SettingsFile%, Settings, LeftTolerance, 8
    IniRead, RightTolerance, %SettingsFile%, Settings, RightTolerance, 8
    IniRead, ArrowTolerance, %SettingsFile%, Settings, ArrowTolerance, 8
    IniRead, FishTolerance, %SettingsFile%, Settings, FishTolerance, 4
    IniRead, ShakeTolerance, %SettingsFile%, Settings, ShakeTolerance, 4
    IniRead, AutoSelectRod, %SettingsFile%, Settings, AutoSelectRod, 0
    IniRead, AutoZoomIn, %SettingsFile%, Settings, AutoZoomIn, 0
    IniRead, MeasureArrow, %SettingsFile%, Settings, MeasureArrow, 0
    IniRead, FixPDController, %SettingsFile%, Settings, FixPDController, 0
    IniRead, SelectRodDuration, %SettingsFile%, Settings, SelectRodDuration, 350
    IniRead, CastingMode, %SettingsFile%, Settings, CastingMode, Normal
    IniRead, ShakeMode, %SettingsFile%, Settings, ShakeMode, Click
    IniRead, DelayBeforeCasting, %SettingsFile%, Settings, DelayBeforeCasting, 350
    IniRead, CastDuration, %SettingsFile%, Settings, CastDuration, 350
    IniRead, DelayAfterCasting, %SettingsFile%, Settings, DelayAfterCasting, 350
    IniRead, CastScanDelay, %SettingsFile%, Settings, CastScanDelay, 50
    IniRead, CastTimeout, %SettingsFile%, Settings, CastTimeout, 5000
    IniRead, ReleaseDelay, %SettingsFile%, Settings, ReleaseDelay, 350
    IniRead, ShakeScanDelay, %SettingsFile%, Settings, ShakeScanDelay, 80
    IniRead, ShakeFailsafe, %SettingsFile%, Settings, ShakeFailsafe, 80
    IniRead, MinigameScanDelay, %SettingsFile%, Settings, MinigameScanDelay, 10
    IniRead, RestartDelay, %SettingsFile%, Settings, RestartDelay, 3000
    IniRead, BarRatioFromSide, %SettingsFile%, Settings, BarRatioFromSide, 0.5
    IniRead, KP, %SettingsFile%, Settings, KP, 0.93
    IniRead, KD, %SettingsFile%, Settings, KD, 0.07

    GuiControl,, InitialControl, %InitialControl%
    GuiControl,, LeftColor, %LeftColor%
    GuiControl,, RightColor, %RightColor%
    GuiControl,, ArrowColor, %ArrowColor%
    GuiControl,, FishColor, %FishColor%
    GuiControl,, ShakeColor, %ShakeColor%
    GuiControl,, LeftTolerance, %LeftTolerance%
    GuiControl,, RightTolerance, %RightTolerance%
    GuiControl,, ArrowTolerance, %ArrowTolerance%
    GuiControl,, FishTolerance, %FishTolerance%
    GuiControl,, ShakeTolerance, %ShakeTolerance%
    GuiControl,, AutoSelectRod, %AutoSelectRod%
    GuiControl,, AutoZoomIn, %AutoZoomIn%
    GuiControl,, MeasureArrow, %MeasureArrow%
    GuiControl,, FixPDController, %FixPDController%
    GuiControl,, SelectRodDuration, %SelectRodDuration%
    GuiControl,, CastingMode, %CastingMode%
    GuiControl,, ShakeMode, %ShakeMode%
    GuiControl,, DelayBeforeCasting, %DelayBeforeCasting%
    GuiControl,, CastDuration, %CastDuration%
    GuiControl,, DelayAfterCasting, %DelayAfterCasting%
    GuiControl,, CastScanDelay, %CastScanDelay%
    GuiControl,, CastTimeout, %CastTimeout%
    GuiControl,, ReleaseDelay, %ReleaseDelay%
    GuiControl,, ShakeScanDelay, %ShakeScanDelay%
    GuiControl,, ShakeFailsafe, %ShakeFailsafe%
    GuiControl,, MinigameScanDelay, %MinigameScanDelay%
    GuiControl,, RestartDelay, %RestartDelay%
    GuiControl,, BarRatioFromSide, %BarRatioFromSide%
    GuiControl,, KP, %KP%
    GuiControl,, KD, %KD%

    LoadGlobalSettings()
    ; MsgBox, Loaded %ActiveConfig% at %SettingsFile%
    return
}

SaveGlobalSettings:
    Gui, Submit, NoHide
    GlobalSettingsFile := A_ScriptDir . "\GlobalSettings.ini"
    IniWrite, %StartKey%, %GlobalSettingsFile%, Settings, StartKey
    IniWrite, %StopKey%, %GlobalSettingsFile%, Settings, StopKey
    IniWrite, %FishingRodKey%, %GlobalSettingsFile%, Settings, FishingRodKey
    IniWrite, %EquipmentBagKey%, %GlobalSettingsFile%, Settings, EquipmentBagKey

    ; MsgBox, Saved Global Settings at %GlobalSettingsFile%
    return

LoadGlobalSettings() {
    Gui, Submit, NoHide
    GlobalSettingsFile := A_ScriptDir . "\GlobalSettings.ini"
    IniRead, StartKey, %GlobalSettingsFile%, Settings, StartKey, F5
    IniRead, StopKey, %GlobalSettingsFile%, Settings, StopKey, F7
    IniRead, FishingRodKey, %GlobalSettingsFile%, Settings, FishingRodKey, 1
    IniRead, EquipmentBagKey, %GlobalSettingsFile%, Settings, EquipmentBagKey, 2

    GuiControl,, StartKey, %StartKey%
    GuiControl,, StopKey, %StopKey%
    GuiControl,, FishingRodKey, %FishingRodKey%
    GuiControl,, EquipmentBagKey, %EquipmentBagKey%
    ; MsgBox, Loaded Global Settings at %GlobalSettingsFile%
    return
}

EnableHotkeys:
    Gui, Submit, NoHide
    WinActivate, Roblox
    ; Add new bindings
    if (HotkeyState = 1) {
        Hotkey, %StartKey%, StartMacro, On
        Hotkey, %StopKey%, StopMacro, On

        ToolTip, Press %StartKey% to start, %TooltipX%, %Tooltip5%, 5
        ToolTip, Press %StopKey% to stop, %TooltipX%, %Tooltip6%, 6
    } else {
        Hotkey, %StartKey%, StartMacro, Off
        Hotkey, %StopKey%, StopMacro, Off

        ToolTip, Hotkeys %StartKey% and %StopKey% are FixPDController, %TooltipX%, %Tooltip5%, 5
        ToolTip, , %TooltipX%, %Tooltip6%, 6
    }
return

Calculations:
    ; Check if Roblox is running
    if !WinExist("ahk_exe RobloxPlayerBeta.exe") {
        WindowLeft := 0
        WindowTop := 0
        WindowWidth := A_ScreenWidth
        WindowHeight := A_ScreenHeight
    } else {
        WinActivate, Roblox
        WinGetPos, WindowLeft, WindowTop, WindowWidth, WindowHeight, ahk_exe RobloxPlayerBeta.exe
    }
    ; Validation Check
    if (WindowLeft < 0) {
        WindowLeft := 0
    }
    if (WindowTop < 0) {
        WindowTop := 0
    }
    if (WindowWidth > A_ScreenWidth) {
        WindowWidth := A_ScreenWidth
    }
    if (WindowHeight > A_ScreenHeight) {
        WindowHeight := A_ScreenHeight
    }
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

    ClickShakeLeft := WindowWidth/4
    ClickShakeRight := WindowWidth/1.2736
    ClickShakeTop := WindowHeight/8
    ClickShakeBottom := WindowHeight/1.3409

    FishBarLeft := WindowWidth/3.3160
    FishBarRight := WindowWidth/1.4317
    FishBarTop := WindowHeight/1.2
    FishBarBottom := WindowHeight/1.1512

    FishBarToolTipHeight := WindowHeight/1.0626

    ; Tooltips
    ToolTip, %WindowLeft% %WindowTop%, 0, 0, 17
    ToolTip, %WindowWidth% %WindowHeight%, %WindowWidth%, %WindowHeight%, 18

    ToolTip, Made By Catman2608, %ToolTipX%, %ToolTip1%, 1
    ToolTip, PyWare Fishing V4 Lite (July 14th Hotkeys), %ToolTipX%, %ToolTip2%, 2
    ToolTip, Runtime: 0h 0m 0s, %ToolTipX%, %ToolTip3%, 3
return

StartMacro:
GoSub, SaveSettings
GoSub, Calculations
Gui, Hide
ToolTip, Press %StopKey% to stop, %TooltipX%, %Tooltip5%, 5
ToolTip, Current Task: Beginning Alignmnet, %ToolTipX%, %ToolTip6%, 6

if (AutoZoomIn = 1) {
    ToolTip, Current Task: Auto Zoom In, %ToolTipX%, %ToolTip6%, 6
    Loop, 20 {
        Send, {wheelup}
    }
    Send, {wheeldown}
}
; Main loop
Loop {
    if (AutoSelectRod = 1) {
        ToolTip, Current Task: Auto Select Rod, %ToolTipX%, %ToolTip6%, 6
        ToolTip, Action: Press %EquipmentBagKey% and %FishingRodKey%, %ToolTipX%, %ToolTip7%, 7
        Send, %EquipmentBagKey%
        Sleep, %SelectRodDuration%
        Send, %FishingRodKey%
    }
    ToolTip, Current Task: Casting Rod, %ToolTipX%, %ToolTip6%, 6
    ToolTip, Casting Mode: %CastingMode%, %ToolTipX%, %ToolTip7%, 7
    Sleep, %DelayBeforeCasting%
    if (CastingMode = "Perfect") {
        GoSub, PerfectCast
    } else {
        Send, {LButton down}
        Sleep, %CastDuration%
        Send, {LButton up}
    }
    Sleep, %DelayAfterCasting%

    ToolTip, Current Task: Shaking, %ToolTipX%, %ToolTip6%, 6
    ToolTip, Shake Mode: %ShakeMode%, %ToolTipX%, %ToolTip7%, 7
    CurrentFailsafeCounter := 0
    Loop, %ShakeFailsafe% {
        PixelSearch,,, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %FishColor%, %FishLeftColorTolerance%, Fast
        if (ErrorLevel = 0) {
            break
        }
        if (ShakeMode = "Click") {
            GoSub, ShakeClick
        } else {
            Send, {Enter}
        }
        ToolTip, Failsafe: %CurrentFailsafeCounter%/%ShakeFailsafe%, %ToolTipX%, %ToolTip8%, 8
        CurrentFailsafeCounter += 1
        Sleep, %ShakeScanDelay%
    }
    GoSub, EnterMinigame
}
return

PerfectCast:
    IsInitialRun := True
    WhiteBottom := ClickShakeBottom
    ; Hold cast
    Send, {LButton down}
    Loop {
        PixelSearch, GreenX, GreenY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0x4CA064, %ShakeTolerance%, Fast
        if (ErrorLevel = 1) {
            ; Green not found - searching full screen
            PixelSearch, GreenX, GreenY, WindowLeft, WindowTop, (WindowLeft + WindowWidth), (WindowHeight), 0x4CA064, %ShakeTolerance%, Fast
        }
        if (GreenX != -1 and GreenY != -1) {  ; Fixed: != instead of "not ... ="
            PixelSearch, WhiteX, WhiteY, (GreenX - 10), (GreenY - 10), ClickShakeRight, WhiteBottom, 0xCAD3D4, %ShakeTolerance%, Fast
            if (IsInitialRun = True and ErrorLevel = 0) {
                WhiteBottom := WhiteY + 10
            }
        }
        PerfectCastSize := GreenY - WhiteBottom
        WhiteRatio := (WhiteY - WhiteBottom) / PerfectCastSize
        if (WhiteRatio > 0.95) {
            ; White touched green - release
            Send, {LButton up}
            return
        }
        ; End of perfect cast
        IsInitialRun := False
    }  ; Added missing closing brace
return

ShakeClick:
    PixelSearch, ClickX, ClickY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, %ShakeColor%, %ShakeTolerance%, Fast
    if (ErrorLevel = 0) {
        Click, %ClickX%, %ClickY%
    }
    ToolTip, Click X: %ClickX%, %ToolTipX%, %ToolTip9%, 9
    ToolTip, Click Y: %ClickY%, %ToolTipX%, %ToolTip10%, 10
    return

EnterMinigame:
    IsInitialRun := True
    LastFishX := 0
    LastLeftX := 0
    LastRightX := 0
    LastArrowX := 0
    LastBarCenter := 0
    LastBarSize := 0
    LastError := 0
    LastTime := 0
    CacheFailsafe := 0
    Error := 0
    InitialBarSize := (InitialControl + 0.3) * (FishBarRight - FishBarLeft)
    ToolTip, Current Task: Playing Bar Minigame, %ToolTipX%, %ToolTip6%, 6
    ToolTip, Bar Size: %InitialBarSize%, %ToolTipX%, %ToolTip7%, 7
    Loop {
        ; Detection + Calculations for right bar and arrow
        PixelSearch, FishX, FishY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %FishColor%, %FishTolerance%, Fast
        if (ErrorLevel = 0) {
            LastFishX := FishX
            CacheFailsafe := 0
        } else {
            FishX := LastFishX
            CacheFailsafe += 1
        }
        if (CacheFailsafe > 20) {
            break
        }
        PixelSearch, LeftX, LeftY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %LeftColor%, %BarTolerance%, Fast
        BarFound := ErrorLevel
        if (BarFound = 0) {
            ToolTip, Detection Source: Bar, %ToolTipX%, %ToolTip8%, 8
            RightX := LeftX + InitialBarSize
            LastLeftX := LeftX
            LastRightX := RightX
        } else {
            ToolTip, Detection Source: Arrows, %ToolTipX%, %ToolTip8%, 8
            PixelSearch, ArrowX, ArrowY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, %ArrowColor%, %ArrowTolerance%, Fast
            ArrowFound := ErrorLevel
            ; Direction: If bar moves right it's larger than 0 otherwise less than 0
            Direction := Error - LastError
            if (ArrowFound = 0) {
                ; Measure box size based on last bar and current bar state
                if (Error > 0 and LastError < 0) {
                    ; Error on RIGHT and last error on LEFT
                    LeftX := LastArrowX
                    RightX := ArrowX
                    InitialBarSize := ArrowX - LastArrowX
                } else if (Error < 0 and LastError > 0) {
                    ; Error on LEFT and last error on RIGHT
                    RightX := LastArrowX
                    LeftX := ArrowX
                    InitialBarSize := LastArrowX - ArrowX
                } else if (Direction > 0) {
                    ; Bar is moving RIGHT - set left to last box size
                    RightX := ArrowX - InitialBarSize
                    LeftX := ArrowX
                } else {
                    ; Bar is moving LEFT - set right to last box size
                    LeftX := ArrowX - InitialBarSize
                    RightX := ArrowX
                }
                LastArrowX := ArrowX
            }
        }
        ; Bar Center
        BarCenter := (LeftX + RightX) / 2
        ; ToolTips for bar and fish
        ToolTip, |, %LeftX%, %FishBarToolTipHeight%, 11
        ToolTip, |, %RightX%, %FishBarToolTipHeight%, 12
        ; PD control
        CurrentTime := A_TickCount
        TimeDelta := CurrentTime - LastTime
        LastTime := CurrentTime
        Error := FishX - BarCenter
        ToolTip, Distance: %Error%, %ToolTipX%, %ToolTip9%, 9
        if (IsInitialRun = True) {
            PDControl := 0
            LastError := Error
        } else {
            if (TimeDelta < 1) {
                TimeDelta := 1
            }
            PTerm := Error * KP
            DTerm := ((Error - LastError) / TimeDelta) * KD
            PDControl := PTerm + DTerm
            LastError := Error
        }
        ToolTip, Controller Output: %PDControl%, %ToolTipX%, %ToolTip10%, 10
        if (PDControl > 0) {
            ShouldHold := True
            ToolTip, <, %BarCenter%, %FishBarToolTipHeight%, 13
        } else {
            ShouldHold := False
            ToolTip, >, %BarCenter%, %FishBarToolTipHeight%, 13
        }
        if (ShouldHold = False) {
            Send, {LButton up}
        } else {
            Send, {LButton down}
        }
        ; Cleanup
        IsInitialRun := False
        Sleep, %ScanDelay%
    }
    return

StopMacro:
    ExitApp
return