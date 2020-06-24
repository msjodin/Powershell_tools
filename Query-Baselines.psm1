function Query-BaselineServices
{
Param
(
[Parameter(Position=0,Mandatory=$false)]
[string]$ServicesBaselineFile="C:\Maintenance\Baselines\ServicesBaseline.csv",

[Parameter(Position=1,Mandatory=$true)]
[switch]$CorrectServices,

[Parameter(Position=2,Mandatory=$false)]
[switch]$LogBadServices
)

    $BaselineServices = Import-Csv -Path $ServicesBaselineFile
    $CurrentServices = Get-Service 
    $Global:BadServices = @{}
    foreach($service in $CurrentServices)
    {
    IF($BaselineServices.Name.Contains($service.name))
        {
        $BService = $BaselineServices | Where-Object -Property Name -EQ $service.Name
        IF($service.Status -eq $BService.Status)
            {Write-host $BService.name "status: " $Bservice.Status}
        Else
            {
            Write-Host "`n" $service.Name "is different from the baseline! `n" 
            $Global:BadServices.Add($service.Name, $service.Status)
            IF($CorrectServices -ne $false){Set-Service $Service.Name -Status $BService.Status}
            IF($LogBadServices -eq $true){Out-File -FilePath "C:\Maintenance\Baselines\BadServices.txt" -InputObject $BadServices.Name, $BadServices.status -Append -Force}
            }
        }
    }
}

Export-ModuleMember Query-BaselineServices
