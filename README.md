# ArgSplitPS

Convert-ToPwnCommand
-------------------
This function converts a string into a series of variable assignments that, when executed,
will reconstruct the original string in a variable named 'Pwn'.

Parameters:
-----------
[text]       : The string you want to split into variables (can be provided directly after the command)
-Terminal    : The terminal type to generate code for. Options: cmd, powershell, ps (Default: cmd)
-Clipboard   : Switch to copy the output to clipboard (Optional)
-Help        : Display this help message

Aliases:
--------
-t, -term   : Aliases for -Terminal
-cb         : Alias for -Clipboard
-h, -?      : Aliases for -Help

Examples:
---------
1. Basic CMD usage (all these work the same):
   Convert-ToPwnCommand test
   Convert-ToPwnCommand -InputString "test"
   Convert-ToPwnCommand "test"

2. PowerShell usage (all these work the same):
   Convert-ToPwnCommand test -Terminal ps
   Convert-ToPwnCommand test -t ps
   Convert-ToPwnCommand test -term ps

3. Copy output to clipboard:
   Convert-ToPwnCommand test -cb

4. Combined example:
   Convert-ToPwnCommand test -t ps -cb

Notes:
------
- CMD output will use environment variables with SET commands
- PowerShell output will use standard PowerShell variables
- All generated variable names are random
- The final string will always be stored in a variable named 'Pwn'
