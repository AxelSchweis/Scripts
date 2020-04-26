param ($hostsfile = "telemetry-daten.csv", $DNSServer = "dc") 


function new-dnsentry {
    param ($FQDN, $IPAddr, $Computername )

    $ExitCode = 0

    $Zonename = $FQDN.Substring($FQDN.Indexof(".") + 1)
    $Hostname = $FQDN.split(".")[0]

    if (Get-DnsServerZone $Zonename -ComputerName $Computername -ErrorAction Ignore) {
        "Zone ""$Zonename"" already exists" | Write-Host
    } else {
        $ExitCode = Add-DnsServerPrimaryZone -Name $ZoneName -ReplicationScope Forest -ComputerName $ComputerName
        if ($ExitCode) {
            return $ExitCode
        }
        "Successfully created new DNS Zone ""$Zonename""" | Write-Host
    }

    if (Get-DnsServerResourceRecord -ZoneName $Zonename -name $Hostname -ComputerName $Computername -ErrorAction Ignore)  {
        "DNS-Resolution for ""$FQDN"" already in Place, skip ..!" | Write-Host
    } else {
        $ExitCode = Add-DnsServerResourceRecordA -IPv4Address $IPAddr -ZoneName $Zonename -Name $Hostname -ComputerName $Computername
        if ($ExitCode) {
            return $ExitCode
        }
        "Successfullly created new Hosts Entry ""$Hostname"" in Zone ""$Zonename""" | Write-Host
    }

}

$List = get-content $hostsfile

$ExitCode = 0 
foreach ($Entry in $List) {
    if ($Entry) {
        
        $IPAddr, $FQDN = $Entry -split "\s+"
        $ExitCode = new-dnsentry -FQDN $FQDN -IPAddr $IPAddr -Computername $DNSServer
        if ($ExitCode) {
            return $ExitCode
        }
    }
}