; ============================================================
; Fisch Macro V13.5
; ============================================================
#SingleInstance Force
SetKeyDelay(-1)
SetMouseDelay(-1)
; V1toV2: Removed setbatchlines, -1
SetTitleMatchMode(2)

CoordMode("ToolTip", "Window")
CoordMode("Pixel", "Window")
CoordMode("Mouse", "Window")

if (InStr(A_ScriptDir, ".zip\") || InStr(A_ScriptDir, ".rar\") || InStr(A_ScriptDir, ".7z\")) {
    MsgBox("You must extract the files from the ZIP archive first!`n`nThe macro cannot save settings while running from inside a ZIP file.`n`nPlease:`n1. Right-click the ZIP file`n2. Select `"Extract All`"`n3. Run the macro from the extracted folder", "Extract Files Required", 262192)
    ExitApp()
}

FileAppend("", A_ScriptDir "\test_write.tmp")
if (ErrorLevel) {
    if (InStr(A_ScriptDir, "Downloads") && (InStr(A_ScriptDir, "Compressed") || InStr(A_ScriptDir, "Temp"))) {
        MsgBox("It appears you're running from a compressed/temporary folder.`n`nPlease extract all files to a regular folder (like Desktop or Documents) before running the macro.`n`nCurrent location: " A_ScriptDir, "Extract Files Required", 262192)
        ExitApp()
    } else {
        MsgBox("Cannot write to current directory: " A_ScriptDir "`n`nTry:`n1. Moving the files to Desktop or Documents`n2. Running as Administrator`n3. Extracting from ZIP if compressed", "Permission Error", 262192)
        ExitApp()
    }
} else {
    FileDelete(A_ScriptDir "\test_write.tmp")
}

; ======
; GUI
; ======

myGui := Gui()
myGui.OnEvent("Close", GuiClose)
myGui.SetFont("s9 cWhite", "Segoe UI")
myGui.Opt("+AlwaysOnTop")
myGui.Opt("+Resize +MinSize")
myGui.Opt("+LastFound -Theme")  ; Disable Windows theming so text colors can apply to Edit boxes
myGui.SetFont("c0xFFFFFF")
Tab := myGui.Add("Tab2", "w850 h620", ["General Settings", "Shake Settings", "Minigame Settings", "Other Settings"])
myGui.BackColor := "0x1D1D1D Bold"

; Buttons
Tab.UseTab()
myGui.SetFont("s9 cWhite", "Segoe UI")
myGui.Add("Text", "x30 y565", "Active Configuration")
ogcComboBoxDropItem := myGui.Add("ComboBox", "x30 y580 w160 h100 vDropItem")
ogcComboBoxDropItem.OnEvent("DoubleClick", SelectItem.Bind("DoubleClick"))
ogcButtonSave := myGui.Add("Button", "x200 y580 w100 h30", "💾 Save")
ogcButtonSave.OnEvent("Click", SaveSettings.Bind("Normal"))
ogcButtonLoad := myGui.Add("Button", "x310 y580 w100 h30", "📂 Load")
ogcButtonLoad.OnEvent("Click", LoadSettings.Bind("Normal"))
ogcButtonExit := myGui.Add("Button", "x420 y580 w100 h30", "❌ Exit")
ogcButtonExit.OnEvent("Click", ExitScript.Bind("Normal"))
ogcButtonStart := myGui.Add("Button", "x530 y580 w100 h30", "▶️ Start")
ogcButtonStart.OnEvent("Click", Launch.Bind("Normal"))
myGui.Add("Text", "x820 y600", "V13.5")

; The GUI section below uses 0xRRGGBB instead of 0xBBGGRR unlike the other sections
; ====== General Tab ======
Tab.UseTab("General")
myGui.SetFont("s9 cWhite", "Segoe UI")
myGui.SetFont("c0x00FF00")
myGui.Add("Text", "x30 y40", "General Settings")
myGui.SetFont("cWhite Norm")

myGui.SetFont("c0x00FF00 Bold")
myGui.Add("GroupBox", "x20 y60 w380 h230", "Automation")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x40 y90", "Auto Lower Graphics:")
ogcCheckboxAutoLowerGraphics := myGui.Add("Checkbox", "x220 y90 vAutoLowerGraphics", "Enable")
myGui.Add("Text", "x40 y130", "Auto Zoom In:")
ogcCheckboxAutoZoomInCamera := myGui.Add("Checkbox", "x220 y130 vAutoZoomInCamera", "Enable")
myGui.Add("Text", "x40 y170", "Auto Enable Camera Mode:")
ogcCheckboxAutoEnableCameraMode := myGui.Add("Checkbox", "x220 y170 vAutoEnableCameraMode", "Enable")
myGui.Add("Text", "x40 y210", "Auto Look Down:")
ogcCheckboxAutoLookDownCamera := myGui.Add("Checkbox", "x220 y210 vAutoLookDownCamera", "Enable")
myGui.Add("Text", "x40 y250", "Auto Blur:")
ogcCheckboxAutoBlurCamera := myGui.Add("Checkbox", "x220 y250 vAutoBlurCamera", "Enable")

myGui.SetFont("c0x00FF00 Bold")
myGui.Add("GroupBox", "x440 y60 w380 h160", "Timing and pacing")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x460 y90", "Restart Delay (ms):")
ogcEditRestartDelay := myGui.Add("Edit", "x640 y90 w100 vRestartDelay cBlack", "1500")
myGui.Add("Text", "x460 y130", "Wait for Bobber to Land (ms):")
ogcEditWaitForBobberDelay := myGui.Add("Edit", "x640 y130 w100 vWaitForBobberDelay cBlack", "1000")
myGui.Add("Text", "x460 y170", "Bait Delay (ms):")
ogcEditBaitDelay := myGui.Add("Edit", "x640 y170 w100 vBaitDelay cBlack", "0")

myGui.SetFont("c0x00FF00 Bold")
myGui.Add("GroupBox", "x440 y240 w380 h250", "Casting")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x460 y270", "Perfect Cast (slower):")
ogcCheckboxPerfectCast := myGui.Add("Checkbox", "x640 y270 vPerfectCast", "Enable")
myGui.Add("Text", "x460 y310", "Hold Rod Cast Duration (ms):")
ogcEditHoldRodCastDuration := myGui.Add("Edit", "x640 y310 w100 vHoldRodCastDuration cBlack", "600")
myGui.Add("Text", "x460 y350", "Perfect Cast Tolerance:")
ogcEditPerfectCastTolerance := myGui.Add("Edit", "x640 y350 w100 vPerfectCastTolerance cBlack", "15")

myGui.SetFont("c0x00FF00 Bold")
myGui.Add("GroupBox", "x20 y310 w380 h210", "Resources")
myGui.SetFont("cWhite Norm")
myGui.Add("Link", "x40 y340", "<a href=`"https://discord.gg/aMZY8yrF8r`">Join I Can't Automate Discord</a>")
myGui.Add("Link", "x40 y370", "<a href=`"https://sites.google.com/view/icf-automation-network/`">Update to ICF V2</a>")
myGui.Add("Link", "x40 y400", "<a href=`"https://docs.google.com/document/d/1WwWWMR-eN-R-GO42IioToHpWTgiXkLoiNE_4NeE-GsU/edit?usp=sharing`">Future Macro Plans</a>")

myGui.Add("Text", "x40 y430", "If it’s your first time, check all boxes.")
myGui.Add("Text", "x40 y460", "Click the top-right camera icon if not working.")
myGui.Add("Text", "x40 y490", "Run as Admin if you can’t save or load settings.")

; ====== Shake Tab ======
Tab.UseTab("Shake")
myGui.SetFont("s9 cWhite", "Segoe UI")
myGui.SetFont("c0x87CEEB Bold")
myGui.Add("Text", "x30 y40", "Shake Settings")
myGui.SetFont("cWhite Norm")

; === Shake Configuration ===
myGui.SetFont("c0x87CEEB Bold")
myGui.Add("GroupBox", "x20 y60 w370 h420", "Shake Configuration")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x40 y90", "Navigation Key:")
ogcEditNavigationKey := myGui.Add("Edit", "x200 y87 w100 vNavigationKey cBlack", "\")
myGui.Add("Text", "x40 y125", "Shake Mode:")
ogcComboBoxShakeMode := myGui.Add("ComboBox", "x200 y120 w100 vShakeMode cBlack", ["Click", "Navigation", "Wait"])
myGui.Add("Text", "x40 y160", "Shake Failsafe (sec):")
ogcEditShakeFailsafe := myGui.Add("Edit", "x200 y157 w100 vShakeFailsafe cBlack", "20")

; --- Click Shake Settings ---
myGui.SetFont("c0x87CEEB Bold")
myGui.Add("GroupBox", "x40 y190 w320 h90", "Click Mode")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x60 y215", "Color Tolerance:")
ogcEditShakeTolerance := myGui.Add("Edit", "x200 y215 w100 vShakeTolerance cBlack", "3")
myGui.Add("Text", "x60 y245", "Scan Delay (ms):")
ogcEditClickScanDelay := myGui.Add("Edit", "x200 y245 w100 vClickScanDelay cBlack", "10")

; --- Navigation Settings ---
myGui.SetFont("c0x87CEEB Bold")
myGui.Add("GroupBox", "x40 y290 w320 h70", "Navigation Mode")
myGui.SetFont("cWhite Norm")
myGui.SetFont("cWhite")
myGui.Add("Text", "x60 y315", "Spam Delay (ms):")
ogcEditNavigationSpamDelay := myGui.Add("Edit", "x200 y315 w100 vNavigationSpamDelay cBlack", "10")

; --- Wait Settings ---
myGui.SetFont("c0x87CEEB Bold")
myGui.Add("GroupBox", "x40 y370 w320 h90", "Wait Mode")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x60 y395", "Wait Until Clicking (ms):")
ogcEditWaitUntilClicking := myGui.Add("Edit", "x200 y392 w100 vWaitUntilClicking cBlack", "9000")

; === Notes ===
myGui.SetFont("c0x87CEEB Bold")
myGui.Add("GroupBox", "x420 y60 w400 h380", "Notes")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x440 y90", "- Set correct Navigation Key in Roblox")
myGui.Add("Text", "x440 y120", "- Choose a Shake Mode that matches your style")
myGui.Add("Text", "x440 y150", "- Adjust delay values for your latency")
myGui.Add("Text", "x440 y180", "- Load → Save → Start for reliability")
myGui.Add("Text", "x440 y210", "- Click = pixel shake | Nav = key spam | Wait = timer-based")
myGui.SetFont()

; ====== Minigame Tab ======
Tab.UseTab("Minigame")
myGui.SetFont("s9 cWhite", "Segoe UI")
myGui.SetFont("c0xE87B07 Bold")
myGui.Add("Text", "x30 y40", "Minigame Settings")
myGui.SetFont("cWhite Norm")

; === Control Stats ===
myGui.SetFont("c0xE87B07 Bold")
myGui.Add("GroupBox", "x20 y60 w350 h190", "Control Stats")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x40 y90", "Resilience:")
ogcEditResilience := myGui.Add("Edit", "x180 y87 w100 vResilience cBlack", "0")
myGui.Add("Text", "x40 y125", "Control:")
ogcEditControl := myGui.Add("Edit", "x180 y122 w100 vControl cBlack", "0")
ogcCheckboxNegativeControl := myGui.Add("Checkbox", "x40 y160 vNegativeControl", "Negative Control")
ogcButtonGeneratevalues := myGui.Add("Button", "x180 y160 w100 h25", "Generate values")
ogcButtonGeneratevalues.OnEvent("Click", GenerateResillience.Bind("Normal"))

; === Control Loop ===
myGui.SetFont("c0xE87B07 Bold")
myGui.Add("GroupBox", "x400 y60 w370 h190", "Side Bar Settings")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x420 y90", "Scan Delay:")
ogcEditScanDelay := myGui.Add("Edit", "x600 y87 w100 vScanDelay cBlack", "10")
myGui.Add("Text", "x420 y125", "Side Bar Ratio:")
ogcEditSideBarRatio := myGui.Add("Edit", "x600 y122 w100 vSideBarRatio cBlack", "0.7")
myGui.Add("Text", "x420 y160", "Side Bar Delay:")
ogcEditSideDelay := myGui.Add("Edit", "x600 y157 w100 vSideDelay cBlack", "400")

; === Detection Tolerance ===
myGui.SetFont("c0xE87B07 Bold")
myGui.Add("GroupBox", "x20 y270 w350 h140", "Detection Tolerance")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x40 y300", "Fish Bar Tolerance:")
ogcEditFishLeftColorTolerance := myGui.Add("Edit", "x180 y297 w100 vFishLeftColorTolerance cBlack", "5")
myGui.Add("Text", "x40 y335", "White Bar Tolerance:")
ogcEditWhiteLeftColorTolerance := myGui.Add("Edit", "x180 y332 w100 vWhiteLeftColorTolerance cBlack", "15")
myGui.Add("Text", "x40 y370", "Arrow Tolerance:")
ogcEditArrowColorTolerance := myGui.Add("Edit", "x180 y367 w100 vArrowColorTolerance cBlack", "6")
myGui.Add("Link", "x420 y190", "<a href=`"https://docs.google.com/document/d/17qkxS2nzCXO8k-tvT_s-w4UF_GiqZbgOzAWNFsbUZI8/edit?usp=sharing`">Open Minigame Guide</a>")

; === Bar Stability ===
myGui.SetFont("c0xE87B07 Bold")
myGui.Add("GroupBox", "x400 y270 w370 h280", "Stability Profiles")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x420 y295", "Stable Right Multiplier:")
ogcEditStableRightMultiplier := myGui.Add("Edit", "x600 y292 w100 vStableRightMultiplier cBlack", "2.36")
myGui.Add("Text", "x420 y325", "Stable Right Division:")
ogcEditStableRightDivision := myGui.Add("Edit", "x600 y322 w100 vStableRightDivision cBlack", "1.55")
myGui.Add("Text", "x420 y355", "Stable Left Multiplier:")
ogcEditStableLeftMultiplier := myGui.Add("Edit", "x600 y352 w100 vStableLeftMultiplier cBlack", "1.211")
myGui.Add("Text", "x420 y385", "Stable Left Division:")
ogcEditStableLeftDivision := myGui.Add("Edit", "x600 y382 w100 vStableLeftDivision cBlack", "1.12")
myGui.Add("Text", "x420 y415", "Unstable Right Multiplier:")
ogcEditUnstableRightMultiplier := myGui.Add("Edit", "x600 y412 w100 vUnstableRightMultiplier cBlack", "2.665")
myGui.Add("Text", "x420 y445", "Unstable Right Division:")
ogcEditUnstableRightDivision := myGui.Add("Edit", "x600 y442 w100 vUnstableRightDivision cBlack", "1.5")
myGui.Add("Text", "x420 y475", "Unstable Left Multiplier:")
ogcEditUnstableLeftMultiplier := myGui.Add("Edit", "x600 y472 w100 vUnstableLeftMultiplier cBlack", "2.19")
myGui.Add("Text", "x420 y505", "Unstable Left Division:")
ogcEditUnstableLeftDivision := myGui.Add("Edit", "x600 y502 w100 vUnstableLeftDivision cBlack", "1")
myGui.SetFont("cWhite")

; === Ankle Settings ===
myGui.SetFont("c0xE87B07 Bold")
myGui.Add("GroupBox", "x20 y420 w350 h90", "Ankle Settings")
myGui.SetFont("cWhite Norm")
myGui.Add("Text", "x40 y450", "Right Ankle Break Multiplier:")
ogcEditRightAnkleBreakMultiplier := myGui.Add("Edit", "x250 y447 w100 vRightAnkleBreakMultiplier cBlack", "0.75")
myGui.Add("Text", "x40 y480", "Left Ankle Break Multiplier:")
ogcEditLeftAnkleBreakMultiplier := myGui.Add("Edit", "x250 y477 w100 vLeftAnkleBreakMultiplier cBlack", "0.45")

myGui.SetFont()

; ====== Other Tab ======
Tab.UseTab("Other")
myGui.SetFont("s9 cWhite", "Segoe UI")
myGui.SetFont("c0xFF0000 Bold")
myGui.Add("Text", "x30 y40", "Other Settings")
myGui.SetFont("cWhite Norm")
myGui.SetFont("c0xFF0000 Bold")
myGui.Add("GroupBox", "x20 y60 w370 h250", "Custom Rod Options")
myGui.SetFont("cWhite Norm")
; Custom rod options
myGui.Add("Text", "x40 y90", "Seraphic Rod Check:")
ogcCheckboxSera := myGui.Add("Checkbox", "x220 y90 vSera", "Enable")
myGui.Add("Text", "x40 y130", "Seraphic Rod Cycles:")
ogcEditSeraCycles := myGui.Add("Edit", "x220 y127 w100 vSeraCycles cBlack", "25")
myGui.Add("Text", "x40 y170", "Random Rod Check:")
ogcCheckboxRandomRod := myGui.Add("Checkbox", "x220 y170 vRandomRod", "Enable")

myGui.SetFont("c0xFF0000 Bold")
myGui.Add("GroupBox", "x420 y60 w360 h290", "Bar Colors")
myGui.SetFont("cWhite Norm")

myGui.Add("Text", "x440 y90", "Bar Color (in 0xBBGGRR):")
ogcEditLeftColor := myGui.Add("Edit", "x600 y90 w100 vLeftColor cBlack", "0xFFFFFF")

myGui.Add("Text", "x440 y130", "Bar Color 2 (in 0xBBGGRR):")
ogcEditLeftColor2 := myGui.Add("Edit", "x600 y130 w100 vLeftColor2 cBlack", "0x00FC43")

myGui.Add("Text", "x440 y170", "Arrow Color (in 0xBBGGRR):")
ogcEditArrowColor := myGui.Add("Edit", "x600 y170 w100 vArrowColor cBlack", "0x878584")

myGui.Add("Text", "x440 y210", "Arrow Color 2 (in 0xBBGGRR):")
ogcEditArrowColor2 := myGui.Add("Edit", "x600 y210 w100 vArrowColor2 cBlack", "0x878584")

myGui.Add("Text", "x440 y250", "Fish Color (in 0xBBGGRR):")
ogcEditFishColor := myGui.Add("Edit", "x600 y250 w100 vFishColor cBlack", "0x5B4B43")

myGui.SetFont()

; show GUI
myGui.Show()

Loop Files, A_ScriptDir "\*.ini"
{
    fileName := SubStr(A_LoopFileName, 1, -1*(4))
    ogcComboBoxDropItem.Add([fileName])
}

SettingsFileName := A_ScriptDir . "\" . SettingsFileName . ".ini"

SelectItem(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    oSaved := myGui.Submit("0")
    DropItem := oSaved.DropItem
    AutoLowerGraphics := oSaved.AutoLowerGraphics
    AutoZoomInCamera := oSaved.AutoZoomInCamera
    AutoEnableCameraMode := oSaved.AutoEnableCameraMode
    AutoLookDownCamera := oSaved.AutoLookDownCamera
    AutoBlurCamera := oSaved.AutoBlurCamera
    RestartDelay := oSaved.RestartDelay
    WaitForBobberDelay := oSaved.WaitForBobberDelay
    BaitDelay := oSaved.BaitDelay
    PerfectCast := oSaved.PerfectCast
    HoldRodCastDuration := oSaved.HoldRodCastDuration
    PerfectCastTolerance := oSaved.PerfectCastTolerance
    NavigationKey := oSaved.NavigationKey
    ShakeMode := oSaved.ShakeMode
    ShakeFailsafe := oSaved.ShakeFailsafe
    ShakeTolerance := oSaved.ShakeTolerance
    ClickScanDelay := oSaved.ClickScanDelay
    NavigationSpamDelay := oSaved.NavigationSpamDelay
    WaitUntilClicking := oSaved.WaitUntilClicking
    Resilience := oSaved.Resilience
    Control := oSaved.Control
    NegativeControl := oSaved.NegativeControl
    ScanDelay := oSaved.ScanDelay
    SideBarRatio := oSaved.SideBarRatio
    SideDelay := oSaved.SideDelay
    FishLeftColorTolerance := oSaved.FishLeftColorTolerance
    WhiteLeftColorTolerance := oSaved.WhiteLeftColorTolerance
    ArrowColorTolerance := oSaved.ArrowColorTolerance
    StableRightMultiplier := oSaved.StableRightMultiplier
    StableRightDivision := oSaved.StableRightDivision
    StableLeftMultiplier := oSaved.StableLeftMultiplier
    StableLeftDivision := oSaved.StableLeftDivision
    UnstableRightMultiplier := oSaved.UnstableRightMultiplier
    UnstableRightDivision := oSaved.UnstableRightDivision
    UnstableLeftMultiplier := oSaved.UnstableLeftMultiplier
    UnstableLeftDivision := oSaved.UnstableLeftDivision
    RightAnkleBreakMultiplier := oSaved.RightAnkleBreakMultiplier
    LeftAnkleBreakMultiplier := oSaved.LeftAnkleBreakMultiplier
    Sera := oSaved.Sera
    SeraCycles := oSaved.SeraCycles
    RandomRod := oSaved.RandomRod
    LeftColor := oSaved.LeftColor
    LeftColor2 := oSaved.LeftColor2
    ArrowColor := oSaved.ArrowColor
    ArrowColor2 := oSaved.ArrowColor2
    FishColor := oSaved.FishColor
    SettingsFileName := A_ScriptDir . "\" . DropItem . ".ini"
Return
} ; V1toV2: Added Bracket before label

GenerateResillience(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    oSaved := myGui.Submit("0")
    DropItem := oSaved.DropItem
    AutoLowerGraphics := oSaved.AutoLowerGraphics
    AutoZoomInCamera := oSaved.AutoZoomInCamera
    AutoEnableCameraMode := oSaved.AutoEnableCameraMode
    AutoLookDownCamera := oSaved.AutoLookDownCamera
    AutoBlurCamera := oSaved.AutoBlurCamera
    RestartDelay := oSaved.RestartDelay
    WaitForBobberDelay := oSaved.WaitForBobberDelay
    BaitDelay := oSaved.BaitDelay
    PerfectCast := oSaved.PerfectCast
    HoldRodCastDuration := oSaved.HoldRodCastDuration
    PerfectCastTolerance := oSaved.PerfectCastTolerance
    NavigationKey := oSaved.NavigationKey
    ShakeMode := oSaved.ShakeMode
    ShakeFailsafe := oSaved.ShakeFailsafe
    ShakeTolerance := oSaved.ShakeTolerance
    ClickScanDelay := oSaved.ClickScanDelay
    NavigationSpamDelay := oSaved.NavigationSpamDelay
    WaitUntilClicking := oSaved.WaitUntilClicking
    Resilience := oSaved.Resilience
    Control := oSaved.Control
    NegativeControl := oSaved.NegativeControl
    ScanDelay := oSaved.ScanDelay
    SideBarRatio := oSaved.SideBarRatio
    SideDelay := oSaved.SideDelay
    FishLeftColorTolerance := oSaved.FishLeftColorTolerance
    WhiteLeftColorTolerance := oSaved.WhiteLeftColorTolerance
    ArrowColorTolerance := oSaved.ArrowColorTolerance
    StableRightMultiplier := oSaved.StableRightMultiplier
    StableRightDivision := oSaved.StableRightDivision
    StableLeftMultiplier := oSaved.StableLeftMultiplier
    StableLeftDivision := oSaved.StableLeftDivision
    UnstableRightMultiplier := oSaved.UnstableRightMultiplier
    UnstableRightDivision := oSaved.UnstableRightDivision
    UnstableLeftMultiplier := oSaved.UnstableLeftMultiplier
    UnstableLeftDivision := oSaved.UnstableLeftDivision
    RightAnkleBreakMultiplier := oSaved.RightAnkleBreakMultiplier
    LeftAnkleBreakMultiplier := oSaved.LeftAnkleBreakMultiplier
    Sera := oSaved.Sera
    SeraCycles := oSaved.SeraCycles
    RandomRod := oSaved.RandomRod
    LeftColor := oSaved.LeftColor
    LeftColor2 := oSaved.LeftColor2
    ArrowColor := oSaved.ArrowColor
    ArrowColor2 := oSaved.ArrowColor2
    FishColor := oSaved.FishColor

    ; Use GUI values directly
    stable_right_multiplier := 2.36 + (Control * 0.05) + (Resilience * 0.02)  ; Fixed Resilience spelling
    stable_left_multiplier  := 1.211 + (Control * 0.04) + (Resilience * 0.02) ; Fixed Resilience spelling
    unstable_right_multiplier := 2.665 + (Control * 0.06) + (Resilience * 0.03) ; Fixed Resilience spelling
    unstable_left_multiplier  := 2.19 + (Control * 0.05) + (Resilience * 0.025) ; Fixed Resilience spelling

    stable_right_division := 1.55 - (Control * 0.02) - (Resilience * 0.005) ; Fixed Resilience spelling
    unstable_right_division := 1.5 - (Control * 0.03) - (Resilience * 0.01) ; Fixed Resilience spelling
    stable_left_division := 1.12 - (Control * 0.015) - (Resilience * 0.005) ; Fixed Resilience spelling
    unstable_left_division := 1.0 - (Control * 0.02) - (Resilience * 0.01) ; Fixed Resilience spelling

    right_ankle_multiplier := 0.25 + (Control / 30) + (Resilience / 60) ; Fixed Resilience spelling
    left_ankle_multiplier  := 0.25 + (Control / 40) + (Resilience / 80) ; Fixed Resilience spelling

    ; Clamp values
    if (right_ankle_multiplier > 0.45)
        right_ankle_multiplier := 0.45
    if (left_ankle_multiplier > 0.35)
        left_ankle_multiplier := 0.35

    ; Update GUI fields with calculated values
    ogcEditStableRightMultiplier.Value := stable_right_multiplier
    ogcEditStableLeftMultiplier.Value := stable_left_multiplier
    ogcEditUnstableRightMultiplier.Value := unstable_right_multiplier
    ogcEditUnstableLeftMultiplier.Value := unstable_left_multiplier

    ogcEditStableRightDivision.Value := stable_right_division
    ogcEditStableLeftDivision.Value := stable_left_division
    ogcEditUnstableRightDivision.Value := unstable_right_division
    ogcEditUnstableLeftDivision.Value := unstable_left_division

    ogcEditRightAnkleBreakMultiplier.Value := right_ankle_multiplier
    ogcEditLeftAnkleBreakMultiplier.Value := left_ankle_multiplier
Return

; Save settings
} ; V1toV2: Added bracket before function
SaveSettings(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    oSaved := myGui.Submit("0")
    DropItem := oSaved.DropItem
    AutoLowerGraphics := oSaved.AutoLowerGraphics
    AutoZoomInCamera := oSaved.AutoZoomInCamera
    AutoEnableCameraMode := oSaved.AutoEnableCameraMode
    AutoLookDownCamera := oSaved.AutoLookDownCamera
    AutoBlurCamera := oSaved.AutoBlurCamera
    RestartDelay := oSaved.RestartDelay
    WaitForBobberDelay := oSaved.WaitForBobberDelay
    BaitDelay := oSaved.BaitDelay
    PerfectCast := oSaved.PerfectCast
    HoldRodCastDuration := oSaved.HoldRodCastDuration
    PerfectCastTolerance := oSaved.PerfectCastTolerance
    NavigationKey := oSaved.NavigationKey
    ShakeMode := oSaved.ShakeMode
    ShakeFailsafe := oSaved.ShakeFailsafe
    ShakeTolerance := oSaved.ShakeTolerance
    ClickScanDelay := oSaved.ClickScanDelay
    NavigationSpamDelay := oSaved.NavigationSpamDelay
    WaitUntilClicking := oSaved.WaitUntilClicking
    Resilience := oSaved.Resilience
    Control := oSaved.Control
    NegativeControl := oSaved.NegativeControl
    ScanDelay := oSaved.ScanDelay
    SideBarRatio := oSaved.SideBarRatio
    SideDelay := oSaved.SideDelay
    FishLeftColorTolerance := oSaved.FishLeftColorTolerance
    WhiteLeftColorTolerance := oSaved.WhiteLeftColorTolerance
    ArrowColorTolerance := oSaved.ArrowColorTolerance
    StableRightMultiplier := oSaved.StableRightMultiplier
    StableRightDivision := oSaved.StableRightDivision
    StableLeftMultiplier := oSaved.StableLeftMultiplier
    StableLeftDivision := oSaved.StableLeftDivision
    UnstableRightMultiplier := oSaved.UnstableRightMultiplier
    UnstableRightDivision := oSaved.UnstableRightDivision
    UnstableLeftMultiplier := oSaved.UnstableLeftMultiplier
    UnstableLeftDivision := oSaved.UnstableLeftDivision
    RightAnkleBreakMultiplier := oSaved.RightAnkleBreakMultiplier
    LeftAnkleBreakMultiplier := oSaved.LeftAnkleBreakMultiplier
    Sera := oSaved.Sera
    SeraCycles := oSaved.SeraCycles
    RandomRod := oSaved.RandomRod
    LeftColor := oSaved.LeftColor
    LeftColor2 := oSaved.LeftColor2
    ArrowColor := oSaved.ArrowColor
    ArrowColor2 := oSaved.ArrowColor2
    FishColor := oSaved.FishColor
    if (DropItem = "")
        SettingsFileName := A_ScriptDir . "\default.ini"
    else
        SettingsFileName := A_ScriptDir . "\" . DropItem . ".ini"
    
    FileAppend("", SettingsFileName)  ; Create the file if it doesn't exist

    IniWrite(AutoLowerGraphics, SettingsFileName, "General", "AutoLowerGraphics")
    IniWrite(AutoZoomInCamera, SettingsFileName, "General", "AutoZoomInCamera")
    IniWrite(AutoEnableCameraMode, SettingsFileName, "General", "AutoEnableCameraMode")
    IniWrite(AutoLookDownCamera, SettingsFileName, "General", "AutoLookDownCamera")
    IniWrite(AutoBlurCamera, SettingsFileName, "General", "AutoBlurCamera")

    IniWrite(RestartDelay, SettingsFileName, "General", "RestartDelay")
    IniWrite(HoldRodCastDuration, SettingsFileName, "General", "HoldRodCastDuration")
    IniWrite(PerfectCastTolerance, SettingsFileName, "General", "PerfectCastTolerance")
    IniWrite(WaitForBobberDelay, SettingsFileName, "General", "WaitForBobberDelay")
    IniWrite(BaitDelay, SettingsFileName, "General", "BaitDelay")
    IniWrite(Sera, SettingsFileName, "General", "Sera")
    IniWrite(RandomRod, SettingsFileName, "General", "RandomRod")

    IniWrite(NavigationKey, SettingsFileName, "Shake", "NavigationKey")
    IniWrite(ShakeMode, SettingsFileName, "Shake", "ShakeMode")
    IniWrite(ShakeFailsafe, SettingsFileName, "Shake", "ShakeFailsafe")

    IniWrite(ShakeTolerance, SettingsFileName, "Shake", "ShakeTolerance")
    IniWrite(ClickScanDelay, SettingsFileName, "Shake", "ClickScanDelay")
    IniWrite(NavigationSpamDelay, SettingsFileName, "Shake", "NavigationSpamDelay")
    IniWrite(WaitUntilClicking, SettingsFileName, "Shake", "WaitUntilClicking")
    IniWrite(PerfectCast, SettingsFileName, "Shake", "PerfectCast")

    IniWrite(Resilience, SettingsFileName, "Minigame", "Resilience")  ; Fixed spelling
    IniWrite(Control, SettingsFileName, "Minigame", "Control")
    IniWrite(NegativeControl, SettingsFileName, "Minigame", "NegativeControl") ; FIXED
    IniWrite(FishLeftColorTolerance, SettingsFileName, "Minigame", "FishLeftColorTolerance")
    IniWrite(WhiteLeftColorTolerance, SettingsFileName, "Minigame", "WhiteLeftColorTolerance")
    IniWrite(ArrowColorTolerance, SettingsFileName, "Minigame", "ArrowColorTolerance")

    IniWrite(ScanDelay, SettingsFileName, "Minigame", "ScanDelay")
    IniWrite(SideBarRatio, SettingsFileName, "Minigame", "SideBarRatio")
    IniWrite(SideDelay, SettingsFileName, "Minigame", "SideDelay")

    IniWrite(StableRightMultiplier, SettingsFileName, "Minigame", "StableRightMultiplier")
    IniWrite(StableRightDivision, SettingsFileName, "Minigame", "StableRightDivision")
    IniWrite(StableLeftMultiplier, SettingsFileName, "Minigame", "StableLeftMultiplier")
    IniWrite(StableLeftDivision, SettingsFileName, "Minigame", "StableLeftDivision")

    IniWrite(UnstableRightMultiplier, SettingsFileName, "Minigame", "UnstableRightMultiplier")
    IniWrite(UnstableRightDivision, SettingsFileName, "Minigame", "UnstableRightDivision")
    IniWrite(UnstableLeftMultiplier, SettingsFileName, "Minigame", "UnstableLeftMultiplier")
    IniWrite(UnstableLeftDivision, SettingsFileName, "Minigame", "UnstableLeftDivision")
    
    IniWrite(RightAnkleBreakMultiplier, SettingsFileName, "Minigame", "RightAnkleBreakMultiplier")
    IniWrite(LeftAnkleBreakMultiplier, SettingsFileName, "Minigame", "LeftAnkleBreakMultiplier")

    IniWrite(LeftColor, SettingsFileName, "Others", "LeftColor")
    IniWrite(LeftColor2, SettingsFileName, "Others", "LeftColor2")
    IniWrite(ArrowColor, SettingsFileName, "Others", "ArrowColor")
    IniWrite(ArrowColor2, SettingsFileName, "Others", "ArrowColor2")
    IniWrite(FishColor, SettingsFileName, "Others", "FishColor")
    IniWrite(SeraCycles, SettingsFileName, "Others", "SeraCycles")

    ; Done
    myGui.Opt("-AlwaysOnTop")
    MsgBox("Settings saved successfully as " SettingsFileName " !", "Saved", "0x40040 T0.8")
    myGui.Opt("+AlwaysOnTop")
Return

} ; V1toV2: Added bracket before function
LoadSettings(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    lAutoLowerGraphics := IniRead(SettingsFileName, "General", "AutoLowerGraphics")
    lAutoZoomInCamera := IniRead(SettingsFileName, "General", "AutoZoomInCamera")
    lAutoEnableCameraMode := IniRead(SettingsFileName, "General", "AutoEnableCameraMode")
    lAutoLookDownCamera := IniRead(SettingsFileName, "General", "AutoLookDownCamera")
    lAutoBlurCamera := IniRead(SettingsFileName, "General", "AutoBlurCamera")

    lRestartDelay := IniRead(SettingsFileName, "General", "RestartDelay")
    lHoldRodCastDuration := IniRead(SettingsFileName, "General", "HoldRodCastDuration")
    lWaitForBobberDelay := IniRead(SettingsFileName, "General", "WaitForBobberDelay")
    lBaitDelay := IniRead(SettingsFileName, "General", "BaitDelay")
    lSera := IniRead(SettingsFileName, "General", "Sera")
    lRandomRod := IniRead(SettingsFileName, "General", "RandomRod")
    lPerfectCastTolerance := IniRead(SettingsFileName, "General", "PerfectCastTolerance")

    lNavigationKey := IniRead(SettingsFileName, "Shake", "NavigationKey")
    lShakeMode := IniRead(SettingsFileName, "Shake", "ShakeMode")
    lShakeFailsafe := IniRead(SettingsFileName, "Shake", "ShakeFailsafe")

    lShakeTolerance := IniRead(SettingsFileName, "Shake", "ShakeTolerance")
    lClickScanDelay := IniRead(SettingsFileName, "Shake", "ClickScanDelay")
    lNavigationSpamDelay := IniRead(SettingsFileName, "Shake", "NavigationSpamDelay")
    lWaitUntilClicking := IniRead(SettingsFileName, "Shake", "WaitUntilClicking")
    lPerfectCast := IniRead(SettingsFileName, "Shake", "PerfectCast")

    lResilience := IniRead(SettingsFileName, "Minigame", "Resilience")    ; Fixed spelling
    lControl := IniRead(SettingsFileName, "Minigame", "Control")
    lNegativeControl := IniRead(SettingsFileName, "Minigame", "NegativeControl")
    lFishLeftColorTolerance := IniRead(SettingsFileName, "Minigame", "FishLeftColorTolerance")
    lWhiteLeftColorTolerance := IniRead(SettingsFileName, "Minigame", "WhiteLeftColorTolerance")
    lArrowColorTolerance := IniRead(SettingsFileName, "Minigame", "ArrowColorTolerance")

    lScanDelay := IniRead(SettingsFileName, "Minigame", "ScanDelay")
    lSideBarRatio := IniRead(SettingsFileName, "Minigame", "SideBarRatio")
    lSideDelay := IniRead(SettingsFileName, "Minigame", "SideDelay")

    lStableRightMultiplier := IniRead(SettingsFileName, "Minigame", "StableRightMultiplier")
    lStableRightDivision := IniRead(SettingsFileName, "Minigame", "StableRightDivision")
    lStableLeftMultiplier := IniRead(SettingsFileName, "Minigame", "StableLeftMultiplier")
    lStableLeftDivision := IniRead(SettingsFileName, "Minigame", "StableLeftDivision")

    lUnstableRightMultiplier := IniRead(SettingsFileName, "Minigame", "UnstableRightMultiplier")
    lUnstableRightDivision := IniRead(SettingsFileName, "Minigame", "UnstableRightDivision")
    lUnstableLeftMultiplier := IniRead(SettingsFileName, "Minigame", "UnstableLeftMultiplier")
    lUnstableLeftDivision := IniRead(SettingsFileName, "Minigame", "UnstableLeftDivision")

    lRightAnkleBreakMultiplier := IniRead(SettingsFileName, "Minigame", "RightAnkleBreakMultiplier")
    lLeftAnkleBreakMultiplier := IniRead(SettingsFileName, "Minigame", "LeftAnkleBreakMultiplier")

    lLeftColor := IniRead(SettingsFileName, "Others", "LeftColor")
    lLeftColor2 := IniRead(SettingsFileName, "Others", "LeftColor2")
    lArrowColor := IniRead(SettingsFileName, "Others", "ArrowColor")
    lArrowColor2 := IniRead(SettingsFileName, "Others", "ArrowColor2")
    lFishColor := IniRead(SettingsFileName, "Others", "FishColor")

    lSeraCycles := IniRead(SettingsFileName, "Others", "SeraCycles")
    
    ; Update GUI
    if FileExist(SettingsFileName) {
    oSaved := myGui.Submit("0")
    DropItem := oSaved.DropItem
    AutoLowerGraphics := oSaved.AutoLowerGraphics
    AutoZoomInCamera := oSaved.AutoZoomInCamera
    AutoEnableCameraMode := oSaved.AutoEnableCameraMode
    AutoLookDownCamera := oSaved.AutoLookDownCamera
    AutoBlurCamera := oSaved.AutoBlurCamera
    RestartDelay := oSaved.RestartDelay
    WaitForBobberDelay := oSaved.WaitForBobberDelay
    BaitDelay := oSaved.BaitDelay
    PerfectCast := oSaved.PerfectCast
    HoldRodCastDuration := oSaved.HoldRodCastDuration
    PerfectCastTolerance := oSaved.PerfectCastTolerance
    NavigationKey := oSaved.NavigationKey
    ShakeMode := oSaved.ShakeMode
    ShakeFailsafe := oSaved.ShakeFailsafe
    ShakeTolerance := oSaved.ShakeTolerance
    ClickScanDelay := oSaved.ClickScanDelay
    NavigationSpamDelay := oSaved.NavigationSpamDelay
    WaitUntilClicking := oSaved.WaitUntilClicking
    Resilience := oSaved.Resilience
    Control := oSaved.Control
    NegativeControl := oSaved.NegativeControl
    ScanDelay := oSaved.ScanDelay
    SideBarRatio := oSaved.SideBarRatio
    SideDelay := oSaved.SideDelay
    FishLeftColorTolerance := oSaved.FishLeftColorTolerance
    WhiteLeftColorTolerance := oSaved.WhiteLeftColorTolerance
    ArrowColorTolerance := oSaved.ArrowColorTolerance
    StableRightMultiplier := oSaved.StableRightMultiplier
    StableRightDivision := oSaved.StableRightDivision
    StableLeftMultiplier := oSaved.StableLeftMultiplier
    StableLeftDivision := oSaved.StableLeftDivision
    UnstableRightMultiplier := oSaved.UnstableRightMultiplier
    UnstableRightDivision := oSaved.UnstableRightDivision
    UnstableLeftMultiplier := oSaved.UnstableLeftMultiplier
    UnstableLeftDivision := oSaved.UnstableLeftDivision
    RightAnkleBreakMultiplier := oSaved.RightAnkleBreakMultiplier
    LeftAnkleBreakMultiplier := oSaved.LeftAnkleBreakMultiplier
    Sera := oSaved.Sera
    SeraCycles := oSaved.SeraCycles
    RandomRod := oSaved.RandomRod
    LeftColor := oSaved.LeftColor
    LeftColor2 := oSaved.LeftColor2
    ArrowColor := oSaved.ArrowColor
    ArrowColor2 := oSaved.ArrowColor2
    FishColor := oSaved.FishColor
    ogcCheckboxAutoLowerGraphics.Value := lAutoLowerGraphics
    ogcCheckboxAutoZoomInCamera.Value := lAutoZoomInCamera
    ogcCheckboxAutoEnableCameraMode.Value := lAutoEnableCameraMode
    ogcCheckboxAutoLookDownCamera.Value := lAutoLookDownCamera
    ogcCheckboxAutoBlurCamera.Value := lAutoBlurCamera
    ogcEditPerfectCastTolerance.Value := lPerfectCastTolerance

    ogcEditRestartDelay.Value := lRestartDelay
    ogcEditHoldRodCastDuration.Value := lHoldRodCastDuration
    ogcEditWaitForBobberDelay.Value := lWaitForBobberDelay
    ogcEditBaitDelay.Value := lBaitDelay
    ogcCheckboxSera.Value := lSera
    ogcCheckboxRandomRod.Value := lRandomRod

    ogcEditNavigationKey.Value := lNavigationKey
    ogcComboBoxShakeMode.Value := lShakeMode
    ogcEditShakeFailsafe.Value := lShakeFailsafe

    ogcEditShakeTolerance.Value := lShakeTolerance
    ogcEditClickScanDelay.Value := lClickScanDelay
    ogcEditNavigationSpamDelay.Value := lNavigationSpamDelay
    ogcEditWaitUntilClicking.Value := lWaitUntilClicking
    ogcCheckboxPerfectCast.Value := lPerfectCast

    ogcCheckboxNegativeControl.Value := lNegativeControl
    ogcEditFishLeftColorTolerance.Value := lFishLeftColorTolerance
    ogcEditWhiteLeftColorTolerance.Value := lWhiteLeftColorTolerance
    ogcEditArrowColorTolerance.Value := lArrowColorTolerance

    ogcEditScanDelay.Value := lScanDelay
    ogcEditSideBarRatio.Value := lSideBarRatio
    ogcEditSideDelay.Value := lSideDelay

    ogcEditStableRightMultiplier.Value := lStableRightMultiplier
    ogcEditStableRightDivision.Value := lStableRightDivision
    ogcEditStableLeftMultiplier.Value := lStableLeftMultiplier
    ogcEditStableLeftDivision.Value := lStableLeftDivision

    ogcEditUnstableRightMultiplier.Value := lUnstableRightMultiplier
    ogcEditUnstableRightDivision.Value := lUnstableRightDivision
    ogcEditUnstableLeftMultiplier.Value := lUnstableLeftMultiplier
    ogcEditUnstableLeftDivision.Value := lUnstableLeftDivision

    ogcEditRightAnkleBreakMultiplier.Value := lRightAnkleBreakMultiplier
    ogcEditLeftAnkleBreakMultiplier.Value := lLeftAnkleBreakMultiplier
    

    ogcEditLeftColor.Value := lLeftColor
    ogcEditLeftColor2.Value := lLeftColor2
    ogcEditArrowColor.Value := lArrowColor
    ogcEditArrowColor2.Value := lArrowColor2
    ogcEditFishColor.Value := lFishColor

    ogcEditSeraCycles.Value := lSeraCycles

    ; Done
        myGui.Opt("-AlwaysOnTop")
        MsgBox("Loaded " SettingsFileName " !", "Loaded", "0x40040 T0.8")
        myGui.Opt("+AlwaysOnTop")
        Goto(SaveSettings)
    } else {
        myGui.Opt("-AlwaysOnTop")
        MsgBox("Settings failed to load.", "Loaded", 262192)
        myGui.Opt("+AlwaysOnTop")
    }
Return
} ; V1toV2: Added Bracket before label

ExitScript(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    ExitApp()
Return
} ; V1toV2: Added bracket before function

GuiClose(*)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
ExitApp()

;====================================================================================================;
} ; V1toV2: Added bracket
Launch(A_GuiEvent := "", GuiCtrlObj := "", Info := "", *)
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
myGui.Hide()
    lAutoLowerGraphics := IniRead(SettingsFileName, "General", "AutoLowerGraphics")
    lAutoZoomInCamera := IniRead(SettingsFileName, "General", "AutoZoomInCamera")
    lAutoEnableCameraMode := IniRead(SettingsFileName, "General", "AutoEnableCameraMode")
    lAutoLookDownCamera := IniRead(SettingsFileName, "General", "AutoLookDownCamera")
    lAutoBlurCamera := IniRead(SettingsFileName, "General", "AutoBlurCamera")

    lRestartDelay := IniRead(SettingsFileName, "General", "RestartDelay")
    lHoldRodCastDuration := IniRead(SettingsFileName, "General", "HoldRodCastDuration")
    lWaitForBobberDelay := IniRead(SettingsFileName, "General", "WaitForBobberDelay")
    lBaitDelay := IniRead(SettingsFileName, "General", "BaitDelay")
    lSera := IniRead(SettingsFileName, "General", "Sera")
    lRandomRod := IniRead(SettingsFileName, "General", "RandomRod")
    lPerfectCastTolerance := IniRead(SettingsFileName, "General", "PerfectCastTolerance")

    lNavigationKey := IniRead(SettingsFileName, "Shake", "NavigationKey")
    lShakeMode := IniRead(SettingsFileName, "Shake", "ShakeMode")
    lShakeFailsafe := IniRead(SettingsFileName, "Shake", "ShakeFailsafe")

    lShakeTolerance := IniRead(SettingsFileName, "Shake", "ShakeTolerance")
    lClickScanDelay := IniRead(SettingsFileName, "Shake", "ClickScanDelay")
    lNavigationSpamDelay := IniRead(SettingsFileName, "Shake", "NavigationSpamDelay")
    lWaitUntilClicking := IniRead(SettingsFileName, "Shake", "WaitUntilClicking")
    lPerfectCast := IniRead(SettingsFileName, "Shake", "PerfectCast")

    lResilience := IniRead(SettingsFileName, "Minigame", "Resilience")    ; Fixed spelling
    lControl := IniRead(SettingsFileName, "Minigame", "Control")
    lNegativeControl := IniRead(SettingsFileName, "Minigame", "NegativeControl")
    lFishLeftColorTolerance := IniRead(SettingsFileName, "Minigame", "FishLeftColorTolerance")
    lWhiteLeftColorTolerance := IniRead(SettingsFileName, "Minigame", "WhiteLeftColorTolerance")
    lArrowColorTolerance := IniRead(SettingsFileName, "Minigame", "ArrowColorTolerance")

    lScanDelay := IniRead(SettingsFileName, "Minigame", "ScanDelay")
    lSideBarRatio := IniRead(SettingsFileName, "Minigame", "SideBarRatio")
    lSideDelay := IniRead(SettingsFileName, "Minigame", "SideDelay")

    lStableRightMultiplier := IniRead(SettingsFileName, "Minigame", "StableRightMultiplier")
    lStableRightDivision := IniRead(SettingsFileName, "Minigame", "StableRightDivision")
    lStableLeftMultiplier := IniRead(SettingsFileName, "Minigame", "StableLeftMultiplier")
    lStableLeftDivision := IniRead(SettingsFileName, "Minigame", "StableLeftDivision")

    lUnstableRightMultiplier := IniRead(SettingsFileName, "Minigame", "UnstableRightMultiplier")
    lUnstableRightDivision := IniRead(SettingsFileName, "Minigame", "UnstableRightDivision")
    lUnstableLeftMultiplier := IniRead(SettingsFileName, "Minigame", "UnstableLeftMultiplier")
    lUnstableLeftDivision := IniRead(SettingsFileName, "Minigame", "UnstableLeftDivision")

    lRightAnkleBreakMultiplier := IniRead(SettingsFileName, "Minigame", "RightAnkleBreakMultiplier")
    lLeftAnkleBreakMultiplier := IniRead(SettingsFileName, "Minigame", "LeftAnkleBreakMultiplier")

    lLeftColor := IniRead(SettingsFileName, "Others", "LeftColor")
    lLeftColor2 := IniRead(SettingsFileName, "Others", "LeftColor2")
    lArrowColor := IniRead(SettingsFileName, "Others", "ArrowColor")
    lArrowColor2 := IniRead(SettingsFileName, "Others", "ArrowColor2")
    lFishColor := IniRead(SettingsFileName, "Others", "FishColor")

    lSeraCycles := IniRead(SettingsFileName, "Others", "SeraCycles")
    SeraCycles := lSeraCycles

if (ShakeMode != "Navigation" and ShakeMode != "Click" and ShakeMode != "Wait") {
    MsgBox("Shake Mode wasn't saved, and was automatically corrected to click.", "Error", 16)
    ShakeMode := "Click"
    IniWrite(ShakeMode, SettingsFileName, "Shake", "ShakeMode")
}


;====================================================================================================;

WinActivate("Roblox")
if WinActive("ahk_exe RobloxPlayerBeta.exe") || WinActive("ahk_exe eurotruck2.exe")
    {
    WinMaximize("Roblox")
    }
else
    {
    MsgBox("Make sure that roblox is launched and opened.", "Error", 262192)
    Reload()
    }

if (A_ScreenDPI != 96) {
    MsgBox("Display Scale is not set to 100.`nPress the Windows key > Find `"Change the resolution of the display`" > Set the Scale to 100", "Error", 262192)
    Reload()
}
;====================================================================================================;

Send("{LButton up}")
Send("{rbutton up}")
Send("{shift up}")

;====================================================================================================;

Calculations() { ; V1toV2: Added bracket
    global ; V1toV2: Made function global
    Title := WinGetTitle("A")
    WinGetPos(&WindowLeft, &WindowTop, &WindowWidth, &WindowHeight, "A")

    CameraCheckLeft := WindowWidth/2.8444 ; action 1
    CameraCheckRight := WindowWidth/1.5421 ; action 3
    CameraCheckTop := WindowHeight/1.28 ; action 2
    CameraCheckBottom := WindowHeight ; action 4

    CameraClickX := WindowWidth / 1.0164
    CameraClickY := WindowHeight / 

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

    ; Thanks Lunar and AsphaltCake V1toV2 res calculation
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

    Navigation := "Off"

    ToolTip("Made By Longest", ToolTipX, ToolTip1, 1)
    ToolTip("Fisch Macro V13 - Jul 30th", ToolTipX, ToolTip2, 2)
    ToolTip("Runtime: 0h 0m 0s", ToolTipX, ToolTip3, 3)

    ToolTip("Press `"F5`" to Start", ToolTipX, ToolTip4, 4)
    ToolTip("Press `"F6`" to Reload", ToolTipX, ToolTip5, 5)
    ToolTip("Press `"F7`" to Exit", ToolTipX, ToolTip6, 6)
    ToolTip("Press `"F8`" to Generate Bar Colors", ToolTipX, ToolTip8, 8)

    if (AutoLowerGraphics = true)
        {
        ToolTip("AutoLowerGraphics: true", ToolTipX, ToolTip9, 9)
        }
    else
        {
        ToolTip("AutoLowerGraphics: false", ToolTipX, ToolTip9, 9)
        }
        
    if (AutoEnableCameraMode = true)
        {
        ToolTip("AutoEnableCameraMode: true", ToolTipX, ToolTip10, 10)
        }
    else
        {
        ToolTip("AutoEnableCameraMode: false", ToolTipX, ToolTip10, 10)
        }
        
    if (AutoZoomInCamera = true)
        {
        ToolTip("AutoZoomInCamera: true", ToolTipX, ToolTip11, 11)
        }
    else
        {
        ToolTip("AutoZoomInCamera: false", ToolTipX, ToolTip11, 11)
        }
        
    if (AutoLookDownCamera = true)
        {
        ToolTip("AutoLookDownCamera: true", ToolTipX, ToolTip12, 12)
        }
    else
        {
        ToolTip("AutoLookDownCamera: false", ToolTipX, ToolTip12, 12)
        }
    ToolTip("Navigation Key: `"" NavigationKey "`"", ToolTipX, ToolTip14, 14)

    if (ShakeMode = "Click")
        {
        ToolTip("Shake Mode: `"Click`"", ToolTipX, ToolTip16, 16)
        }
    else if (ShakeMode = "Navigation")
        {
        ToolTip("Shake Mode: `"Navigation`"", ToolTipX, ToolTip16, 16)
        }
    else
        {
        ToolTip("Shake Mode: `"Wait`"", ToolTipX, ToolTip16, 16)
        }
    return
}
;====================================================================================================;

CloseInviteButton:
; Close invite if detected
InviteX := 0
InviteY := 0
ErrorLevel := !PixelSearch(&InviteX, &InviteY, InviteAreaLeft, InviteAreaTop, InviteAreaRight, InviteAreaBottom, 0x121215) ; V1toV2: Converted colour to RGB format
if !ErrorLevel {
    Click(CloseInviteX, CloseInviteY)
}
return

; Thanks Lunar and AsphaltCake V1toV2
runtime()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
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

    ToolTip("Runtime: " runtimeH "h " runtimeM "m " runtimeS "s", ToolTipX, ToolTip3, 3)

    if (WinExist("ahk_exe RobloxPlayerBeta.exe") || WinExist("ahk_exe eurotruck2.exe")) {
        if (!WinActive("ahk_exe RobloxPlayerBeta.exe") || !WinActive("ahk_exe eurotruck2.exe")) {
            WinActivate()
        }
    }
    else {
        ExitApp()
    }
return

;====================================================================================================;

} ; V1toV2: Added Bracket before hotkey or Hotstring
} ; V1toV2: Added Bracket before hotkey or Hotstring
$F6::Reload()
$F7::ExitApp()
$F5::Goto(StartCalculation)
$F8::Goto(CalculateControl)
#HotIf !WinActive(, )


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
    CurrentLeftColor := PixelGetColor(LeftColorX, LeftColorY) ; V1toV2: Now returns RGB instead of BGR
    ToolTip("Bar Color: " CurrentLeftColor, ToolTipX, ToolTip10, 10)

    ; Arrow 1 (left arrow) detection
    ArrowColorY := WindowHeight / 1.1663
    ArrowColorX := HalfScreenWidth - HalfBarSize + 30 + (28.5714 * Control * ResolutionScalingX)
    ArrowColor := PixelGetColor(ArrowColorX, ArrowColorY) ; V1toV2: Now returns RGB instead of BGR
    ToolTip("Arrow Color 1: " ArrowColor, ToolTipX, ToolTip11, 11)

    ; Arrow 2 (right arrow) detection
    Send("{LButton down}")
    Sleep(50)
    ArrowColor2X := WhiteBarSize - ArrowColorX
    ArrowColor2 := PixelGetColor(ArrowColor2X, ArrowColorY) ; V1toV2: Now returns RGB instead of BGR
    ToolTip("Arrow Color 2: " ArrowColor2, ToolTipX, ToolTip12, 12)
    Send("{LButton up}")

    ; Fish color detection
    FishColorX := HalfScreenWidth
    FishColorY := WindowHeight / 1.1701
    FishColor := PixelGetColor(FishColorX, FishColorY) ; V1toV2: Now returns RGB instead of BGR
    ToolTip("Fish Color: " FishColor, ToolTipX, ToolTip13, 13)

;======================== Save Colors ==========================
; Read existing settings but exclude color lines
SettingsContent := FileRead(SettingsFileName)
CleanSettings := ""

Loop Parse, SettingsContent, "`n", "`r"
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
FileDelete(SettingsFileName)
FileAppend(NewSettingsContent, SettingsFileName)

; Update GUI controls
ogcEditLeftColor.Value := CurrentLeftColor
ogcEditArrowColor.Value := ArrowColor
ogcEditArrowColor2.Value := ArrowColor2
ogcEditFishColor.Value := FishColor

ToolTip("Bar colors saved to " SettingsFileName, ToolTipX, ToolTip14, 14)
return


StartCalculation() {
    ;====================================================================================================;

    Calculations()
    SetTimer(runtime,1000)

    ToolTip("Press `"F6`" to Reload", ToolTipX, ToolTip4, 4)
    ToolTip("Press `"F7`" to Exit", ToolTipX, ToolTip5, 5)
    ToolTip("Do NOT use Roblox in Fullscreen", ToolTipX, ToolTip6, 6)
    ToolTip(, , , 10)
    ToolTip(, , , 11)
    ToolTip(, , , 12)
    ToolTip(, , , 14)
    ToolTip(, , , 16)

    ; removed minigame detection method because if it detect the fish it can detect it even in blox fruits and duskwire
    DetectionColor := FishColor

    ToolTip("Current Task: AutoLowerGraphics", ToolTipX, ToolTip7, 7)
    ToolTip("F10 Count: 0/20", ToolTipX, ToolTip9, 9)
    f10counter := 0
    if (AutoLowerGraphics = true)
        {
        Send("{shift}")
        ToolTip("Action: Press Shift", ToolTipX, ToolTip8, 8)
        Sleep(50)
        Send("{shift down}")
        ToolTip("Action: Hold Shift", ToolTipX, ToolTip8, 8)
        Sleep(50)
        Loop 20
            {
            f10counter++
            ToolTip("F10 Count: " f10counter "/20", ToolTipX, ToolTip9, 9)
            Send("{f10}")
            ToolTip("Action: Press F10", ToolTipX, ToolTip8, 8)
            Sleep(50)
            }
        Send("{shift up}")
        ToolTip("Action: Release Shift", ToolTipX, ToolTip8, 8)
        Sleep(50)
        }

    ToolTip("Current Task: AutoZoomInCamera", ToolTipX, ToolTip7, 7)
    ToolTip("Scroll In: 0/20", ToolTipX, ToolTip9, 9)
    ToolTip("Scroll Out: 0/1", ToolTipX, ToolTip10, 10)
    scrollcounter := 0
    if (AutoZoomInCamera = true)
        {
        Sleep(50)
        Loop 20
            {
            scrollcounter++
            ToolTip("Scroll In: " scrollcounter "/20", ToolTipX, ToolTip9, 9)
            Send("{wheelup}")
            ToolTip("Action: Scroll In", ToolTipX, ToolTip8, 8)
            Sleep(50)
            }
        Send("{wheeldown}")
        ToolTip("Scroll Out: 1/1", ToolTipX, ToolTip10, 10)
        ToolTip("Action: Scroll Out", ToolTipX, ToolTip8, 8)
        AutoZoomDelay := AutoZoomDelay*5
        Sleep(50)
        }
}
RestartMacro:
; Removed auto blur because the game disable blur in minigame
ToolTip(, , , 10)

ToolTip("Current Task: AutoEnableCameraMode", ToolTipX, ToolTip7, 7)
ToolTip("Right Count: 0/10", ToolTipX, ToolTip9, 9)
rightcounter := 0

if (AutoEnableCameraMode = true) {
    ErrorLevel := !PixelSearch(&LevelCheckX, &LevelCheckY, LevelCheckLeft, LevelCheckTop, LevelCheckRight, LevelCheckBottom, 0xFFDCAC) ; V1toV2: Converted colour to RGB format
    if !ErrorLevel {
        Sleep(50)
        Send("{2}")
        ToolTip("Action: Press 2", ToolTipX, ToolTip8, 8)
        Sleep(50)
        Send("{1}")
        ToolTip("Action: Press 1", ToolTipX, ToolTip8, 8)
        Sleep(50)

        if (NavigationFail = true)
        {
            Send("{esc}")
            Sleep(50)
            Send("{esc}")
            Sleep(50)
            Send("{" NavigationKey "}")
            Sleep(50)
            NavigationFail := false
        }

        Sleep(50)
        Send("{" NavigationKey "}")
        Navigation := "On"
        ToolTip("Action: Press " NavigationKey, ToolTipX, ToolTip8, 8)
        Sleep(50)

        Loop 10
        {
            rightcounter++
            ToolTip("Right Count: " rightcounter "/10", ToolTipX, ToolTip9, 9)
            Send("{right}")
            ToolTip("Action: Press Right", ToolTipX, ToolTip8, 8)
            Sleep(90)
        }

        Send("{enter}")
        ToolTip("Action: Press Enter", ToolTipX, ToolTip8, 8)
        Sleep(50)

        if (ShakeMode = "Click")
        {
            Send("{" NavigationKey "}")
            Navigation := "Off"
        }
    }
}

ToolTip(, , , 9)
ToolTip("Current Task: AutoLookDownCamera", ToolTipX, ToolTip7, 7)
if (AutoLookDownCamera = true)
    {
    Send("{rbutton up}")
    Sleep(50)
    MouseMove(LookDownX, LookDownY)

    ToolTip("Action: Position Mouse", ToolTipX, ToolTip8, 8)
    Sleep(50)
    Send("{rbutton down}")
    ToolTip("Action: Hold Right Click", ToolTipX, ToolTip8, 8)
    Sleep(50)
    DllCall("mouse_event", "Int", 0x01, "Int", 0, "Int", 10000)
    ToolTip("Action: Move Mouse Down", ToolTipX, ToolTip8, 8)
    Sleep(50)
    Send("{rbutton up}")
    ToolTip("Action: Release Right Click", ToolTipX, ToolTip8, 8)
    Sleep(50)
    MouseMove(LookDownX, LookDownY)

    ToolTip("Action: Position Mouse", ToolTipX, ToolTip8, 8)
    Sleep(50)
}
    
ToolTip("Current Task: Press Navigation Key", ToolTipX, ToolTip7, 7)
if (ShakeMode = "Navigation") and (Navigation := "Off") {
    Send("{" NavigationKey "}")
    Navigation := "On"
}

if (PerfectCast = true) {
    ToolTip("Current Task: Zoom out (Perfect Cast)", ToolTipX, ToolTip7, 7)
    
    ; Zoom out
    Loop 4 {
        Send("{wheeldown}")
        Sleep(50)
    }

    Send("{rbutton up}")
    Sleep(50)
    MouseMove(LookDownX, LookDownY)

    Zoom(0, -1000)
    MouseMove(LookDownX, LookDownY)

    Sleep(50)

    ; Start holding left click to charge cast
    Send("{LButton down}")

    ; Look for perfect cast (white touching green)
    Loop 300 {
        ; Look for green area first
        ErrorLevel := !PixelSearch(&GreenX, &GreenY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0x61AB4A) ; V1toV2: Converted colour to RGB format
        if (ErrorLevel) {
            Send("{rbutton up}")
            Sleep(50)
            MouseMove(LookDownX, LookDownY)

	    Zoom(20, 0)
            MouseMove(LookDownX, LookDownY)

            Sleep(50) ; Small delay to prevent excessive CPU usage
            continue
        }

        ; Look for white area
        ErrorLevel := !PixelSearch(&WhiteX, &WhiteY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0xE2E2D8) ; V1toV2: Converted colour to RGB format
        if (ErrorLevel) {
            Sleep(10)
            continue
        }

        ; Clear ToolTips when both colors are found
        ToolTip(, , , 8)

        ; Check if white and green areas touch (within 60 pixels)
        if (Abs(WhiteX - GreenX) <= 60 && Abs(WhiteY - GreenY) <= 60) {
            break
        }
        
        ; Small delay to prevent excessive CPU usage
        Sleep(10)
    }
    Send("{LButton up}")
    ; Zoom back in
    Loop 4 {
        Send("{wheelup}")
        Sleep(50)
    }
    
    ; Clear final ToolTip
    ToolTip(, , , 7)
    Send("{rbutton up}")
    Sleep(50)
    MouseMove(LookDownX, LookDownY)

    Sleep(50)
    Send("{rbutton down}")
    Zoom(0, 1000)
    Send("{rbutton up}")
    Sleep(50)
    MouseMove(LookDownX, LookDownY)

    Sleep(50)
} else {
    ToolTip("Current Task: Casting Rod", ToolTipX, ToolTip7, 7)
    Send("{LButton down}")
    ToolTip("Action: Casting For " HoldRodCastDuration "ms", ToolTipX, ToolTip8, 8)
    Sleep(HoldRodCastDuration)
    Send("{LButton up}")
}
; This section is not related to the holding cast mechanic
ToolTip("Action: Waiting For Bobber (" WaitForBobberDelay "ms)", ToolTipX, ToolTip8, 8)
Sleep(WaitForBobberDelay)
if (ShakeMode = "Click")
    Goto("ClickShakeMode")
else if (ShakeMode = "Navigation")
    Goto("NavigationShakeMode")
else if (ShakeMode = "Wait")
    Goto("WaitShakeMode")

;====================================================================================================;

ClickShakeMode:

ShakeStartTime := A_TickCount

ToolTip("Current Task: Shaking", ToolTipX, ToolTip7, 7)
ToolTip("Click X: None", ToolTipX, ToolTip8, 8)
ToolTip("Click Y: None", ToolTipX, ToolTip9, 9)
ToolTip("Click Count: 0", ToolTipX, ToolTip11, 11)
ToolTip("Bypass Count: 0/10", ToolTipX, ToolTip12, 12)
ToolTip("Failsafe: 0/" ShakeFailsafe, ToolTipX, ToolTip14, 14)

ClickFailsafeCount := 0
ClickCount := 0
ClickShakeRepeatBypassCounter := 0
MemoryX := 0
MemoryY := 0
ForceReset := false

SetTimer(ClickShakeFailsafe, 1000)

ClickShakeModeRedo:
if (ForceReset)
{
    ToolTip(, , 11)
    ToolTip(, , 12)
    ToolTip(, , 14)
    RestartMacro()
}

Sleep(ClickScanDelay)

; --- Detect minigame trigger color ---
ErrorLevel := !PixelSearch(&DetectionX, &DetectionY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, DetectionColor) ; V1toV2: Converted colour to RGB format
if !ErrorLevel
{
    SetTimer(ClickShakeFailsafe,0)
    ToolTip(, , 9)
    ToolTip(, , 11)
    ToolTip(, , 12)
    ToolTip(, , 14)
    Goto("BarMinigame")
}

; --- Detect shake click color ---
ErrorLevel := !PixelSearch(&ClickX, &ClickY, ClickShakeLeft, ClickShakeTop, ClickShakeRight, ClickShakeBottom, 0xFFFFFF) ; V1toV2: Converted colour to RGB format
if !ErrorLevel
{
    ToolTip("Click X: " ClickX, ToolTipX, ToolTip8, 8)
    ToolTip("Click Y: " ClickY, ToolTipX, ToolTip9, 9)

    if (ClickX != MemoryX || ClickY != MemoryY)
    {
        ClickShakeRepeatBypassCounter := 0
        ToolTip("Bypass Count: " ClickShakeRepeatBypassCounter "/10", ToolTipX, ToolTip12, 12)
        ClickCount++
        Click(ClickX ", " ClickY)
        ToolTip("Click Count: " ClickCount, ToolTipX, ToolTip11, 11)
        MemoryX := ClickX
        MemoryY := ClickY
        Goto("ClickShakeModeRedo")
    }
    else
    {
        ClickShakeRepeatBypassCounter++
        ToolTip("Bypass Count: " ClickShakeRepeatBypassCounter "/10", ToolTipX, ToolTip12, 12)
        if (ClickShakeRepeatBypassCounter >= 10)
        {
            MemoryX := 0
            MemoryY := 0
        }
        Goto("ClickShakeModeRedo")
    }
}

Goto("ClickShakeModeRedo")
return

;====================================================================================================;

ClickShakeFailsafe()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    ClickFailsafeCount++
    ToolTip("Failsafe: " ClickFailsafeCount "/" ShakeFailsafe, ToolTipX, ToolTip14, 14)
    if (ClickFailsafeCount >= ShakeFailsafe)
    {
        SetTimer(ClickShakeFailsafe,0)
        ForceReset := true
    }
return
} ; V1toV2: Added Bracket before label

NavigationShakeFailsafe()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
ShakeStartTime := A_TickCount
NavigationFailsafeCount++
ToolTip("Failsafe: " NavigationFailsafeCount "/" ShakeFailsafe, ToolTipX, ToolTip10, 10)
if (NavigationFailsafeCount >= ShakeFailsafe)
    {
    SetTimer(NavigationShakeFailsafe,0)
    ForceReset := true
    }
return
} ; V1toV2: Added Bracket before label

NavigationShakeMode:

ToolTip("Current Task: Shaking", ToolTipX, ToolTip7, 7)
ToolTip("Attempt Count: 0", ToolTipX, ToolTip8, 8)
ToolTip("Failsafe: 0/" ShakeFailsafe, ToolTipX, ToolTip10, 10)

NavigationFailsafeCount := 0
NavigationCounter := 0
ForceReset := false

SetTimer(NavigationShakeFailsafe,1000)

NavigationShakeModeRedo:
if (ForceReset)
{
    ToolTip(, , 10)
    NavigationFail := true
    RestartMacro()
}

Sleep(NavigationSpamDelay)

; --- Minigame trigger detection ---
ErrorLevel := !PixelSearch(&DetectionX, &DetectionY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, DetectionColor) ; V1toV2: Converted colour to RGB format
if !ErrorLevel
{
    SetTimer(NavigationShakeFailsafe,0)
    Goto("BarMinigame")
}

NavigationCounter++
ToolTip("Attempt Count: " NavigationCounter, ToolTipX, ToolTip8, 8)
Send("{Enter}")
Goto("NavigationShakeModeRedo")

WaitShakeFailsafe()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
WaitFailsafeCount++
ToolTip("Failsafe: " WaitFailsafeCount "/" ShakeFailsafe, ToolTipX, ToolTip15, 15)
if (WaitFailsafeCount >= ShakeFailsafe)
    {
    SetTimer(WaitShakeFailsafe,0)
    ForceReset := true
    }
return
} ; V1toV2: Added Bracket before label

WaitShakeMode:

ToolTip("Current Task: Waiting", ToolTipX, ToolTip7, 7)
ToolTip("Wait Time: " WaitUntilClicking " ms", ToolTipX, ToolTip8, 8)
ToolTip("Click Status: Pending", ToolTipX, ToolTip9, 9)
ToolTip("Failsafe: 0/" ShakeFailsafe, ToolTipX, ToolTip15, 15)

WaitFailsafeCount := 0
ForceReset := false

SetTimer(WaitShakeFailsafe,1000)

Sleep(WaitUntilClicking)

Click()
ToolTip("Click Status: Forced Click", ToolTipX, ToolTip9, 9)

WaitShakeModeRedo:
if (ForceReset)
{
    ToolTip(, , 15)
    RestartMacro()
}

; --- Detect minigame trigger (same as others) ---
ErrorLevel := !PixelSearch(&DetectionX, &DetectionY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, DetectionColor) ; V1toV2: Converted colour to RGB format
if !ErrorLevel
{
    SetTimer(WaitShakeFailsafe,0)
    ToolTip(, , 7)
    ToolTip(, , 8)
    ToolTip(, , 9)
    ToolTip(, , 15)
    Goto("BarMinigame")
}

; If color not found, keep waiting for it
Sleep(50)
Goto("WaitShakeModeRedo")

; ==========Bar Minigame Code==========

BarMinigame:
Sleep(BaitDelay)

; Try first color
ErrorLevel := !PixelSearch(&FoundX, &FoundY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, LeftColor2) ; V1toV2: Converted colour to RGB format
if (!ErrorLevel) {
    CurrentLeftColor := PixelGetColor(FoundX, FoundY) ; V1toV2: Now returns RGB instead of BGR
    CurrentLeftColor := LeftColor2
} else {
    ; Try second color
    ErrorLevel := !PixelSearch(&FoundX, &FoundY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, LeftColor) ; V1toV2: Converted colour to RGB format
    if (!ErrorLevel) {
        CurrentLeftColor := PixelGetColor(FoundX, FoundY) ; V1toV2: Now returns RGB instead of BGR
        CurrentLeftColor := LeftColor
    }
}


if (Sera = true) {
        ToolTip("Current Task: Stablizing Seraphic", ToolTipX, ToolTip7, 7)
        ToolTip(, , , 8)
        Loop SeraCycles
        {
            Send("{LButton down}")
            Sleep(50)
            Send("{LButton up}")
            Sleep(30)
        }
        Send("{LButton down}")
        Sleep(800)
        Send("{LButton up}")
}

if (RandomRod = true) {
    ErrorLevel := !PixelSearch(&BarAreaX, &BarAreaY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, ArrowColor2) ; V1toV2: Converted colour to RGB format
    ; Hold left click for 100 ms
    Send("{LButton down}")
    Sleep(50)

    ; While holding left click, find the arrow color
    ErrorLevel := !PixelSearch(&ArrowAreaX, &ArrowAreaY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, ArrowColor2) ; V1toV2: Converted colour to RGB format
    Sleep(50)

    ; Release right click
    Send("{LButton up}")
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

; Thanks Lunar and AsphaltCake V1toV2 Bar Calculations
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

Sleep(50)
Goto("BarMinigameSingle")


;====================================================================================================;

BarMinigameSingle:

    EndMinigame := false
    ToolTip("Current Task: Playing Bar Minigame", ToolTipX, ToolTip7, 7)
    ToolTip("Bar Size: " WhiteBarSize, ToolTipX, ToolTip8, 8)
    ToolTip("Looking for Bar", ToolTipX, ToolTip10, 10)
    HalfBarSize := WhiteBarSize/2
    Deadzone := WhiteBarSize*0.1
    Deadzone2 := HalfBarSize*0.75

    MaxLeftBar := FishBarLeft+(WhiteBarSize*SideBarRatio)
    MaxRightBar := FishBarRight-(WhiteBarSize*SideBarRatio)
    SetTimer(BarMinigame2,ScanDelay)

BarMinigameAction:
    Loop{
        if (EndMinigame = true)
        {
            Sleep(RestartDelay)
            RestartMacro()
        }
        if (Action = 0)
        {
            SideToggle := false
            Send("{LButton down}")
            Sleep(10)
            Send("{LButton up}")
            Sleep(10)
        }
        else if (Action = 1)
        {
            SideToggle := false
            Send("{LButton up}")
            if (AnkleBreak = false)
            {
                Sleep(AnkleBreakDuration)
                AnkleBreakDuration := 0
            }
            AdaptiveDuration := 0.5 + 0.5 * (DistanceFactor ** 1.2)
            if (DistanceFactor < 0.2)
                AdaptiveDuration := 0.15 + 0.15 * DistanceFactor
            Duration := Abs(Direction) * StableLeftMultiplier * PixelScaling * AdaptiveDuration
            Sleep(Duration)
            Send("{LButton down}")
            CounterStrafe := Duration/StableLeftDivision
            Sleep(CounterStrafe)
            AnkleBreak := true
            AnkleBreakDuration := AnkleBreakDuration+(Duration-CounterStrafe)*LeftAnkleBreakMultiplier
        }
        else if (Action = 2)
        {
            SideToggle := false
            Send("{LButton down}")
            if (AnkleBreak = true)
            {
                Sleep(AnkleBreakDuration)
                AnkleBreakDuration := 0
            }
            AdaptiveDuration := 0.5 + 0.5 * (DistanceFactor ** 1.2)
            if (DistanceFactor < 0.2)
                AdaptiveDuration := 0.15 + 0.15 * DistanceFactor
            Duration := Abs(Direction) * StableRightMultiplier * PixelScaling * AdaptiveDuration
            Sleep(Duration)
            Send("{LButton up}")
            CounterStrafe := Duration/StableRightDivision
            Sleep(CounterStrafe)
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
                Send("{LButton up}")
                Sleep(SideDelay)
            }
            Sleep(ScanDelay)
        }
        else if (Action = 4)
        {
            if (SideToggle = false)
            {
                AnkleBreak := false
                AnkleBreakDuration := 0
                SideToggle := true
                Send("{LButton down}")
                Sleep(SideDelay)
            }
            Sleep(ScanDelay)
        }
        else if (Action = 5)
        {
            SideToggle := false
            Send("{LButton up}")
            if (AnkleBreak = false)
            {
                Sleep(AnkleBreakDuration)
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
            Sleep(Duration)
            Send("{LButton down}")
            CounterStrafe := Duration/UnstableLeftDivision
            Sleep(CounterStrafe)
            AnkleBreak := true
            AnkleBreakDuration := AnkleBreakDuration+(Duration-CounterStrafe)*LeftAnkleBreakMultiplier
        }
        else if (Action = 6)
        {
            SideToggle := false
            Send("{LButton down}")
            if (AnkleBreak = true)
            {
                Sleep(AnkleBreakDuration)
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
            Sleep(Duration)
            Send("{LButton up}")
            CounterStrafe := Duration/UnstableRightDivision
            Sleep(CounterStrafe)
            AnkleBreak := false
            AnkleBreakDuration := AnkleBreakDuration+(Duration-CounterStrafe)*RightAnkleBreakMultiplier
        }
        else
        {
            Sleep(ScanDelay)
        }
}

BarMinigame2()
{ ; V1toV2: Added bracket
global ; V1toV2: Made function global
    Sleep(1)
    ErrorLevel := !PixelSearch(&FishX, &FishY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, FishColor) ; V1toV2: Converted colour to RGB format
    if !ErrorLevel
    {
        ToolTip("+", FishX, FishBarToolTipHeight, 20)
        if (FishX < MaxLeftBar)
        {
            Action := 3
            ToolTip("|", MaxLeftBar, FishBarToolTipHeight, 19)
            ToolTip("Direction: Max Left", ToolTipX, ToolTip10, 10)
            ErrorLevel := !PixelSearch(&ArrowX, &ArrowY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, ArrowColor) ; V1toV2: Converted colour to RGB format
            if !ErrorLevel
            {
                ToolTip("<-", ArrowX, FishBarToolTipHeight, 18)
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
            ToolTip("|", MaxRightBar, FishBarToolTipHeight, 19)
            ToolTip("Direction: Max Right", ToolTipX, ToolTip10, 10)
            ErrorLevel := !PixelSearch(&ArrowX, &ArrowY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, ArrowColor2) ; V1toV2: Converted colour to RGB format
            if !ErrorLevel
            {
                ToolTip("->", ArrowX, FishBarToolTipHeight, 18)
                if (MaxRightBar > ArrowX)
                {
                    SideToggle := false
                }
            }
            return
        }
        ErrorLevel := !PixelSearch(&BarX, &BarY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, LeftColor) ; V1toV2: Converted colour to RGB format
        if !ErrorLevel
        {
            ToolTip(, , , 18)
            BarX := BarX + HalfBarSize
            Direction := BarX - FishX
            DistanceFactor := Abs(Direction) / HalfBarSize
            DistanceFactor := Max(0.01, DistanceFactor)

            Ratio2 := Deadzone2/WhiteBarSize
            if (Direction > Deadzone && Direction < Deadzone2)
            {
                Action := 1
                ToolTip("Tracking direction: <", ToolTipX, ToolTip10, 10)
                ToolTip("<", BarX, FishBarToolTipHeight, 19)
            }
            else if (Direction < -Deadzone && Direction > -Deadzone2)
            {
                Action := 2
                ToolTip("Tracking direction: >", ToolTipX, ToolTip10, 10)
                ToolTip(">", BarX, FishBarToolTipHeight, 19)
            }
            else if (Direction > Deadzone2)
            {
                Action := 5
                ToolTip("Tracking direction: < (Fast)", ToolTipX, ToolTip10, 10)
                ToolTip("<", BarX, FishBarToolTipHeight, 19)
            }
            else if (Direction < -Deadzone2)
            {
                Action := 6
                ToolTip("Tracking direction: > (Fast)", ToolTipX, ToolTip10, 10)
                ToolTip(">", BarX, FishBarToolTipHeight, 19)
            }
            else
            {
                Action := 0
                ToolTip("Stabilizing", ToolTipX, ToolTip10, 10)
                ToolTip(".", BarX, FishBarToolTipHeight, 19)
            }
        }
        else
        {
            Direction := (ArrowX > 0) ? HalfBarSize : -HalfBarSize
            ErrorLevel := !PixelSearch(&ArrowX, &ArrowY, FishBarLeft, FishBarTop, FishBarRight, FishBarBottom, ArrowColor) ; V1toV2: Converted colour to RGB format
            ArrowX := ArrowX-FishX
            if (ArrowX > 0)
            {
                Action := 5
                BarX := FishX+HalfBarSize
                ToolTip("Tracking direction: < (Fast)", ToolTipX, ToolTip10, 10)
                ToolTip("<", BarX, FishBarToolTipHeight, 19)
            }
            else
            {
                Action := 6
                BarX := FishX-HalfBarSize
                ToolTip("Tracking direction: > (Fast)", ToolTipX, ToolTip10, 10)
                ToolTip(">", BarX, FishBarToolTipHeight, 19)
            }
        }
    }
else
{
    Click(CloseInviteX, CloseInviteY)

    ToolTip(, , , 10)
    ToolTip(, , , 11)
    ToolTip(, , , 12)
    ToolTip(, , , 13)
    ToolTip(, , , 14)
    ToolTip(, , , 15)
    ToolTip(, , , 17)
    ToolTip(, , , 18)
    ToolTip(, , , 19)
    ToolTip(, , , 20)
    EndMinigame := true
    SetTimer(BarMinigame2,0)
}
} ; V1toV2: Added bracket before function
Zoom(X, Y) {
	Sleep(50)
	X := X / 30
	Y := Y / 30
	LookDownX := 1920/2
	LookDownY := 1080/4
    	Loop 30 {
		Send("{rbutton down}")
        	DllCall("mouse_event", "uint", 1, "int", X, "int", Y, "uint", 0, "int", 0)
        	Sleep(10)
		Send("{rbutton up}")
        	Sleep(10)
		MouseMove(LookDownX, LookDownY)

    	}
    	Sleep(50)
}