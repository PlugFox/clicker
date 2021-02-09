# Clicker

## How to build exe

### CMD

```cmd
start "" ^
      "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" ^
      /in "C:\git\ahk\clicker\Clicker.ahk" ^
      /out "C:\git\ahk\clicker\Clicker.exe"
```

### POWERSHELL

```powershell
Start-Process `
      -FilePath "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" `
      -WorkingDirectory "C:\git\ahk\clicker\" `
      -ArgumentList "/in Clicker.ahk /out Clicker.exe"
```
