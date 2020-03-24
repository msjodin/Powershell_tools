        #Function to log any changes made to a Reg Setting to a text file
        function LogChanges
        {
        Param(
        [Parameter(Mandatory=$true)]
        [string]$RegPath,
        [string]$RegSettingName,
        [string]$RegSettingValue
        )
        Out-File "C:\ChangeLog $env:COMPUTERNAME $datestamp.txt" -Append -InputObject `
        "Key Modified: $RegPath Setting Name: $RegSettingName Setting Value: $RegSettingValue"
        Write-Host "Key Modified: $RegPath Setting Name: $RegSettingName Setting Value: $RegSettingValue"
        }

    #Extract the Registry Settings, Type, and Value from the expected outcome of PerformRegistryChanges's Output Variable $RegSetting
    #Example Input:"SecureProtocols"=dword:00002560
    #Example Output: $RegSettingName = SecureProtocols, $RegSettingValue = 00002560, $RegSettingType = DWORD
    function ParseSetting 
    {
    Param(
    [Parameter(Mandatory=$true)]
    [string]$RegSetting
    )
        $char = [char]0x022
        $RegexPattern = "$char*$char*$char*$char" 
        $RegSettingName = $RegSetting.split('"').GetValue(1)
        $Settings = $RegSetting.split('"').GetValue(2)
        IF($Settings -match "dword")
            {
            $RegSettingValue = $Settings.replace("=dword:","")
            $global:RegSettingType = "DWORD"
            $global:RegSettingName  = $RegSettingName 
            $global:RegSettingValue = $RegSettingValue
            Write-Host "Outputting Type: $RegSettingType, Name: $RegSettingName, Value: $RegSettingValue" 
            }
        ElseIf($RegSetting -match "$RegexPattern")
            {
            Write-Host "String identified" 
            $global:RegSettingType = "STRING"
            $global:RegSettingName = $RegSetting.Split("=").GetValue(0)
            $global:RegSettingValue = $RegSetting.Split("=").GetValue(1)
            Write-Host "Returning Type: $RegSettingType, Name: $RegSettingName, Value: $RegSettingValue" 
            }
        Else{Write-Host $RegexPattern}
    }



    #Test for reg values and set reg value
    function TestSetRegSettingValue
    {
        Param(
        [Parameter(Mandatory=$true)]
        [string]$RegPath,
        [string]$RegSettingName,
        [string]$RegSettingType,
        [string]$RegSettingValue
        )
        Write-Host "Testing to see if the registry value of $RegSettingName is configured correctly."
        Try{
            IF((Get-ItemPropertyValue $RegPath -Name $RegSettingName) -eq $RegSettingValue)
                {
                Write-Host 'Configured Correctly'
                return
                }
            Else
                {
                Write-Host 'The registry setting value was not configured correctly. Configuring value.'
                (Set-ItemProperty $RegPath -Name $RegSettingName -value $RegSettingValue)
                Write-Host 'Registry value configured'
                LogChanges -RegPath $RegPath -RegSettingName $RegSettingName -RegSettingValue $RegSettingValue
                }
            }
        Catch{
            Write-Host 'This registry setting did not exist. Creating and defining Reg value.'
            New-ItemProperty -Path $RegPath -name $RegSettingName -Value $RegSettingValue -PropertyType $RegSettingType -Force
            LogChanges -RegPath $RegPath -RegSettingName $RegSettingName -RegSettingValue $RegSettingValue
            }
    }

    #Test for Reg Key (Path to reg setting) and Set value if not correct
    function TestSetRegSetting
    {
        Param(
        [Parameter(Mandatory=$true)]
        [string]$RegPath,
        [string]$RegSettingName,
        [string]$RegSettingType,
        [string]$RegSettingValue
        )
        Write-Host $RegPath
        IF(!(Test-Path $RegPath))
            {
            #Extracts the Parent and Leaf (Child) of the Registry path
            $ParentPath = Split-Path -Path $RegPath -Parent
            $ChildPath  = Split-Path -Path $RegPath -Leaf
            Write-Host 'Creating New Reg Key'
            New-Item -Path $ParentPath -Name $ChildPath 
            Write-Host 'Creating and defining Reg value'
            New-ItemProperty -Path $RegPath -name $RegSettingName -Value $RegSettingValue -PropertyType $RegSettingType -Force
            LogChanges -RegPath $RegPath -RegSettingName $RegSettingName -RegSettingValue $RegSettingValue
            }
        ELSE
            {
            Write-Host 'Registry Key Path does exist. Performing Test to ensure Reg Value is correct'
            TestSetRegSettingValue -RegPath $RegPath -RegSettingName $RegSettingName -RegSettingValue $RegSettingValue -RegSettingType $RegSettingType
            }
    }

#Main Loop
function PerformRegistryChanges ($RegFile)
{
    #Gets the contents of The supplied filepath $RegPath. the %{} starts a foreach loop that Performs all tasks required to parse a raw registry setting to a usable format and then test, correct, and log the registry value
    Get-Content $RegFile | `
    %{Write-Host "$_ is what I am evaluating"
        IF($_ -match "Registry Editor"){}
        ElseIF($_ -eq "")
            {Write-Host "Blank Space"}
        ElseIF($_ -match "HKEY")
            {
            Write-Host $_
            #Cleans up Raw Registry path and Produces a usable result (ex: HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\Internet Settings)
            $RegPath = $_.replace("[HKEY_LOCAL_MACHINE", "HKLM:").replace("#","").replace("]","")
            return $RegPath
            }
         ElseIF($_ -match "=")
            { 
            Write-Host "$_ has been identified as a match for a reg setting, type, and value"
            $RegSetting = $_
            Write-Host "Path is $RegPath"
            ParseSetting($RegSetting)
            Write-Host "Name is $RegSettingName, Value is $RegSettingValue, Type is $RegSettingType"
            TestSetRegSetting -RegPath $RegPath -RegSettingName $RegSettingName -RegSettingValue $RegSettingValue -RegSettingType $RegSettingType`
             ; $RunNum++ ; Write-Host "Run $RunNum"
            }
         Else{Write-Host "An Error Occurred"; Write-Host $RegPath}
       }
}


PerformRegistryChanges("C:\Directory_Of_Reg_Settings\RegSettingsExport.reg")
