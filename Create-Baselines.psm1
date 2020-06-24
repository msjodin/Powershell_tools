function Create-UsersBaseline
    {
    Get-LocalUser | Select-Object -Property Name, Enabled, SID | Export-Csv -Path C:\Maintenance\Baselines\UserBaseline.csv -Force
    }

function Create-GroupsBaseline
    {
    Get-LocalGroup | Select-Object -Property Name, SID | Export-Csv -Path C:\Maintenance\Baselines\GroupsBaseline.csv -Force
    }

function Create-ServicesBaseline
    {
    Get-service | Select-Object -Property Name,Status,StartupType | Export-Csv -Path C:\Maintenance\Baselines\ServicesBaseline.csv -Force
    }

function Create-Baselines
    {
    New-Item -Path C:\Maintenance\Baselines -ItemType Directory -Force
    Create-UsersBaseline
    Create-GroupsBaseline
    Create-ServicesBaseline
    }

Export-ModuleMember Create-Baselines
