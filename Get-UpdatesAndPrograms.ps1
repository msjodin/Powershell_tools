function Get-UpdatesAndPrograms
{
    Param
    (
    [Parameter(Position=0,Mandatory=$false)]
    [string]$UpdateResults,

    [Parameter(Position=1,Mandatory=$false)]
    [string]$ProgramResults,

    [Parameter(Mandatory=$false)]
    [switch]$WriteToHost
    )
    
    #Gets DateStamp and ComputerName to be used for default file destinations 
    $datestamp = (Get-date -f 'yyyy-MM-dd')
    $filename = "C:\$env:COMPUTERNAME" + "_" + "$datestamp"
    
    #Check if Update Results Destination File was specified and set to default if not specified
    IF($UpdateResults -eq "")
        {$UpdateResults = "$filename"+"_Updates.csv"}
    
    #Gets update results and sends to destination file
    Get-WmiObject -Class Win32_QuickFixEngineering | Select-Object -Property HotFixID, InstalledOn, Description | `
    Sort-Object -Property InstalledOn | Export-Csv -Path "$UpdateResults" -NoTypeInformation -Append -Force
    
    #Check if Program Results Destination File was specified and set to default if not specified
    IF($ProgramResults -eq "")
            {$ProgramResults = "$filename"+"_Programs.csv"}
    
    #Gets update results and sends to destination file
    Get-WmiObject -Class Win32_Product | Select-Object -Property Description, InstallDate, Vendor, Version | `
    Sort-Object -Property InstallDate -Descending | Export-Csv -Path "$ProgramResults" -NoTypeInformation -Append
    IF($WriteToHost -eq $true)
        {Import-Csv -Path $UpdateResults; Import-Csv -Path $ProgramResults}
}


