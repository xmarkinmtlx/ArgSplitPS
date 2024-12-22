function Convert-ToPwnCommand {
    [CmdletBinding(DefaultParameterSetName='Help', PositionalBinding=$false)]
    param(
        [Parameter(Position=0, ParameterSetName='Execute')]
        [string]
        $InputString,

        [Parameter(ParameterSetName='Execute')]
        [Alias('t','term')]
        [ValidateSet('cmd','powershell','ps')]
        [string]
        $Terminal = 'cmd',

        [Parameter(ParameterSetName='Execute')]
        [Alias('cb')]
        [switch]
        $Clipboard,

        [Parameter(ParameterSetName='Help')]
        [Alias('h','?')]
        [switch]
        $Help
    )

    $helpText = @"
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
"@

    # Show help if explicitly requested or if no parameters are provided
    if ($Help -or ($PSCmdlet.ParameterSetName -eq 'Help' -and -not $InputString)) {
        Write-Output $helpText
        return
    }

    if ([string]::IsNullOrEmpty($InputString)) {
        Write-Output "Error: No input string provided.`n"
        Write-Output $helpText
        return
    }

    $assignments = @()
    $random = [System.Random]::new()
    $alphabetAll   = 'abcdefghijklmnopqrstuvwxyz0123456789'
    $alphabetFirst = 'abcdefghijklmnopqrstuvwxyz'

    if ($Terminal -eq 'ps') {
        $Terminal = 'powershell'
    }

    for ($i = 0; $i -lt $InputString.Length; $i++) {
        $thisChar = $InputString[$i]

        switch ($Terminal) {
            'cmd' {
                $varName = -join (1..2 | ForEach-Object {
                    $alphabetAll[$random.Next(0, $alphabetAll.Length)]
                })
            }

            'powershell' {
                $varNameFirst = $alphabetFirst[$random.Next(0, $alphabetFirst.Length)]
                $varNameSecond = $alphabetAll[$random.Next(0, $alphabetAll.Length)]
                $varName = "$varNameFirst$varNameSecond"
            }
        }

        $assignments += [PSCustomObject]@{
            Char    = $thisChar
            VarName = $varName
        }
    }

    $lines = New-Object System.Collections.Generic.List[string]

    if ($Terminal -eq 'cmd') {
        foreach ($item in $assignments) {
            $lines.Add("set `"$($item.VarName)=$($item.Char)`"")
        }

        $allVarRefs = ($assignments | ForEach-Object { "%$($_.VarName)%" }) -join ''
        $lines.Add("set `"Pwn=$allVarRefs`"")

    } elseif ($Terminal -eq 'powershell') {
        foreach ($item in $assignments) {
            $lines.Add('$' + $item.VarName + ' = "' + $item.Char + '"')
        }

        $allVarRefs = ($assignments | ForEach-Object { '$' + $_.VarName }) -join ' + '
        $lines.Add('$Pwn = ' + $allVarRefs)
    }

    $output = $lines -join "`r`n"
    
    if ($Clipboard) {
        $output | Set-Clipboard
    }

    $output
}
