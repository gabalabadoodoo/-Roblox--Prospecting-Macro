#Requires AutoHotkey v2.0
#SingleInstance Force

global FIXED_TOOLTIP_X := 725
global FIXED_TOOLTIP_Y := 740
global cycleCount := 0
global autoSellEnabled := false
global autoSellCycles := 30
global showDebugTooltips := false
global walkTime := 100
global nextDigWait := 1000
global clickHoldTime := 400
global walkHoldTime := 4500
global mainGui := ""
global tooltipCheckbox := ""
global cycleText := ""
global autoSellCheckbox := ""
global autoSellInput := ""
global walkTimeInput := ""
global nextDigWaitInput := ""
global clickHoldInput := ""
global walkHoldInput := ""
global settingsFile := "settings.ini"

LoadSettings()
CreateMainGui()

F1::
{
    global cycleCount
    ShowDebugTooltip("starting macro")
    /*
    ResizeRobloxWindow()
    Sleep 1000
    SafeMoveRelative(0.565, 0.614) */
    

    ShowDebugTooltip("equipping shovel")
    Send "{2}"
    Sleep 200
    Send "{1}"
    Sleep 300

    Loop {
        ShowDebugTooltip("starting digging")
        Sleep 500
        
        ; Hold click for fixed duration
        Click("Down")
        ShowDebugTooltip("holding click")
        Sleep(clickHoldTime)
        Click("Up")
        ShowDebugTooltip("releasing click")
        
        Sleep(nextDigWait)

        checkColor := PixelGetColor(1198, 780)
        
        if (checkColor != 0x8C8C8C) {
            ShowDebugTooltip("digging done moving forward")

            Send("{w down}")
            Loop {
                currentColor := PixelGetColor(906, 887)
                if (currentColor = 0x353535) {
                    Sleep(walkTime)
                    Send("{w up}")
                    ShowDebugTooltip("forward position reached")
                    Sleep(500)
                    break
                }
                Sleep(1)
            }

            ShowDebugTooltip("pan start click")
            Click()
            Sleep(500)

            ShowDebugTooltip("holding click to pan")
            Click("Down")
            Loop {
                detectedColor := PixelGetColor(720, 785)
                
                if (detectedColor = 0x8C8C8C) {
                    ShowDebugTooltip("panning done moving back")
                    Click("Up")
                    Sleep 1800

                    ShowDebugTooltip("moving back")
                    Send("{s down}")
                    Loop {
                        currentColor := PixelGetColor(840, 890)
                        if (currentColor = 0x353535) {
                            Sleep(walkTime)
                            Send("{s up}")
                            ShowDebugTooltip("back position reached")
                            Sleep(500)
                            break
                        }
                        Sleep(1)
                    }
                    
                    ShowDebugTooltip("starting digging again")
                    Sleep 500
                    
                    ; Second dig with fixed duration
                    Click("Down")
                    ShowDebugTooltip("holding click")
                    Sleep(clickHoldTime)
                    Click("Up")
                    ShowDebugTooltip("releasing click to dig")
                    Sleep(nextDigWait)

                    cycleCount++
                    UpdateCycleDisplay()
                    SaveSettings()
                    ShowDebugTooltip("cycle #" . cycleCount . " completed")

                    if (autoSellEnabled && cycleCount >= autoSellCycles) {
                        ShowDebugTooltip("autosell triggered at cycle " . cycleCount)
                        AutoSell()
                        cycleCount := 0
                        UpdateCycleDisplay()
                        SaveSettings()
                        ShowDebugTooltip("autosell completed")
                    }
                    
                    break
                }
                Sleep(1)
            }
        }
    }
}

F2:: {
    global cycleCount
    cycleCount := 0
    ShowDebugTooltip("reloading")
    UpdateCycleDisplay()
    SaveSettings()
    Sleep(100)
    Reload
}

AutoSell() {
    ; Hold S for x seconds
    ShowDebugTooltip("starting autosell")
    Send("{s down}")
    Sleep(walkHoldTime)
    Send("{s up}")
    
    ; Press E and sleep for z seconds
    Send("e")
    Sleep(2000)
    
    ; Move mouse to x,y and sleep 200ms
    MouseMove(1045, 520)
    Sleep(200)
    Click("Left")
    
    ; Sleep for z seconds
    Sleep(3500)
    
    ; Move mouse to x,y and sleep 1500ms
    MouseMove(1015, 495)
    Sleep(1500)
    
    ; Left click
    Click("Left")
    
    ; Sleep for z seconds
    Sleep(3000)
    
    ; Hold W for z seconds
    Send("{w down}")
    Sleep(walkHoldTime)
    Send("{w up}")
}

LoadSettings() {
    global settingsFile, showDebugTooltips, autoSellEnabled, autoSellCycles, walkTime, nextDigWait, clickHoldTime, walkHoldTime
    
    try {
        showDebugTooltips := IniRead(settingsFile, "General", "ShowTooltips", false)
        autoSellEnabled := IniRead(settingsFile, "AutoSell", "Enabled", false)
        autoSellCycles := IniRead(settingsFile, "AutoSell", "Cycles", 100)
        walkTime := IniRead(settingsFile, "Variables", "WalkTime", 100)
        nextDigWait := IniRead(settingsFile, "Variables", "NextDigWait", 2000)
        clickHoldTime := IniRead(settingsFile, "Variables", "ClickHoldTime", 400)
        walkHoldTime := IniRead(settingsFile, "AutoSell", "WalkHoldTime", 4500)

        showDebugTooltips := (showDebugTooltips = "true" || showDebugTooltips = "1")
        autoSellEnabled := (autoSellEnabled = "true" || autoSellEnabled = "1")
        autoSellCycles := Integer(autoSellCycles)
        walkTime := Integer(walkTime)
        nextDigWait := Integer(nextDigWait)
        clickHoldTime := Integer(clickHoldTime)
        walkHoldTime := Integer(walkHoldTime)
    } catch as e {
    }
}

SaveSettings() {
    global settingsFile, showDebugTooltips, autoSellEnabled, autoSellCycles, walkTime, nextDigWait, clickHoldTime, walkHoldTime
    
    try {
        IniWrite(showDebugTooltips ? "true" : "false", settingsFile, "General", "ShowTooltips")
        IniWrite(autoSellEnabled ? "true" : "false", settingsFile, "AutoSell", "Enabled")
        IniWrite(autoSellCycles, settingsFile, "AutoSell", "Cycles")
        IniWrite(walkHoldTime, settingsFile, "AutoSell", "WalkHoldTime")
        IniWrite(walkTime, settingsFile, "Variables", "WalkTime")
        IniWrite(nextDigWait, settingsFile, "Variables", "NextDigWait")
        IniWrite(clickHoldTime, settingsFile, "Variables", "ClickHoldTime")
    } catch as e {
    }
}

CreateMainGui() {
    global mainGui, tooltipCheckbox, cycleText, autoSellCheckbox, autoSellInput, walkTimeInput, nextDigWaitInput, clickHoldInput, walkHoldInput
    
    mainGui := Gui("+AlwaysOnTop -MinimizeBox -Resize", "ProspectingMacro ver. god knows what")
    mainGui.BackColor := "F0F0F0"

    ; Increase font size and set better spacing
    mainGui.SetFont("s9 Norm", "Segoe UI")
    mainGui.MarginX := 10
    mainGui.MarginY := 10

    ; Autosell Section - Made wider and taller
    mainGui.Add("GroupBox", "x10 y10 w130 h110 Section", "Autosell")
    autoSellCheckbox := mainGui.Add("Checkbox", "xs+10 ys+20 w110 h20 Checked" . (autoSellEnabled ? "1" : "0"), "Enable Autosell")
    autoSellCheckbox.OnEvent("Click", ToggleAutoSell)
    
    mainGui.Add("Text", "xs+10 ys+45 w60 h18 +0x200", "Sell After:")
    autoSellInput := mainGui.Add("Edit", "xs+75 ys+43 w40 h20 Number Limit3 Center", autoSellCycles)
    autoSellInput.OnEvent("Change", UpdateAutoSellCycles)
    
    mainGui.Add("Text", "xs+10 ys+70 w60 h18 +0x200", "Walk Hold:")
    walkHoldInput := mainGui.Add("Edit", "xs+75 ys+68 w40 h20 Number Limit5 Center", walkHoldTime)
    walkHoldInput.OnEvent("Change", UpdateWalkHoldTime)

    ; Other Section - Made wider and taller
    mainGui.Add("GroupBox", "x150 y10 w130 h110 Section", "Other")
    tooltipCheckbox := mainGui.Add("Checkbox", "xs+10 ys+20 w110 h20 Checked" . (showDebugTooltips ? "1" : "0"), "Debug Tooltips")
    tooltipCheckbox.OnEvent("Click", ToggleTooltips)

    mainGui.Add("Text", "xs+10 ys+50 w50 h18 +0x200", "Cycles:")
    cycleText := mainGui.Add("Text", "xs+65 ys+48 w50 h22 +Border +Center +0x200 BackgroundWhite c003366", cycleCount)
    cycleText.SetFont("s10 Bold", "Consolas")

    ; Variables Section - Made wider and with better spacing
    mainGui.Add("GroupBox", "x290 y10 w120 h110 Section", "Variables")
    
    mainGui.Add("Text", "xs+10 ys+20 w60 h15 +0x200", "Walk Time:")
    walkTimeInput := mainGui.Add("Edit", "xs+75 ys+18 w35 h18 Number Limit4 Center", walkTime)
    walkTimeInput.OnEvent("Change", UpdateWalkTime)
    
    mainGui.Add("Text", "xs+10 ys+40 w60 h15 +0x200", "Dig Intervals:")
    nextDigWaitInput := mainGui.Add("Edit", "xs+75 ys+38 w35 h18 Number Limit4 Center", nextDigWait)
    nextDigWaitInput.OnEvent("Change", UpdateNextDigWait)
    
    mainGui.Add("Text", "xs+10 ys+60 w60 h15 +0x200", "Hold Time:")
    clickHoldInput := mainGui.Add("Edit", "xs+75 ys+58 w35 h18 Number Limit4 Center", clickHoldTime)
    clickHoldInput.OnEvent("Change", UpdateClickHoldTime)

    mainGui.OnEvent("Close", GuiClose)
    mainGui.OnEvent("Escape", GuiClose)

    ; Adjusted window size to accommodate the larger sections
    mainGui.Show("x-7 y630 w420 h135")
    mainGui.Opt("+Border")
}

GuiClose(*) {
    SaveSettings()
    ExitApp()
}

ToggleTooltips(*) {
    global showDebugTooltips, tooltipCheckbox
    showDebugTooltips := tooltipCheckbox.Value
    SaveSettings()
}

ToggleAutoSell(*) {
    global autoSellEnabled, autoSellCheckbox
    autoSellEnabled := autoSellCheckbox.Value
    SaveSettings()
}

UpdateAutoSellCycles(*) {
    global autoSellCycles, autoSellInput
    try {
        newValue := Integer(autoSellInput.Text)
        if (newValue > 0) {
            autoSellCycles := newValue
            SaveSettings()
        }
    } catch {
        autoSellInput.Text := autoSellCycles
    }
}

UpdateWalkTime(*) {
    global walkTime, walkTimeInput
    try {
        newValue := Integer(walkTimeInput.Text)
        if (newValue >= 0) {
            walkTime := newValue
            SaveSettings()
        }
    } catch {
        walkTimeInput.Text := walkTime
    }
}

UpdateNextDigWait(*) {
    global nextDigWait, nextDigWaitInput
    try {
        newValue := Integer(nextDigWaitInput.Text)
        if (newValue >= 0) {
            nextDigWait := newValue
            SaveSettings()
        }
    } catch {
        nextDigWaitInput.Text := nextDigWait
    }
}

UpdateClickHoldTime(*) {
    global clickHoldTime, clickHoldInput
    try {
        newValue := Integer(clickHoldInput.Text)
        if (newValue >= 0) {
            clickHoldTime := newValue
            SaveSettings()
        }
    } catch {
        clickHoldInput.Text := clickHoldTime
    }
}

UpdateWalkHoldTime(*) {
    global walkHoldTime, walkHoldInput
    try {
        newValue := Integer(walkHoldInput.Text)
        if (newValue >= 0) {
            walkHoldTime := newValue
            SaveSettings()
        }
    } catch {
        walkHoldInput.Text := walkHoldTime
    }
}

UpdateCycleDisplay() {
    global cycleText, cycleCount
    if (cycleText) {
        cycleText.Text := cycleCount
    }
}

ShowDebugTooltip(message) {
    global showDebugTooltips, FIXED_TOOLTIP_X, FIXED_TOOLTIP_Y
    
    if (!showDebugTooltips) {
        return
    }

    ToolTip()
    ToolTip(message, FIXED_TOOLTIP_X, FIXED_TOOLTIP_Y)
    SetTimer(() => ToolTip(), -2000)
}

SafeMoveRelative(xRatio, yRatio) {
    robloxTitles := ["ahk_exe RobloxPlayerBeta.exe", "ahk_exe RobloxPlayer.exe", "Roblox"]
    
    for title in robloxTitles {
        if WinExist(title) {
            try {
                WinGetPos(&winX, &winY, &winW, &winH, title)
                MouseMove 480, 165
                return
            } catch as e {
            }
        }
    }
}