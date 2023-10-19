function Set-CIPPGDAPAutoExtend {
    [CmdletBinding()]
    param (
        $RelationShipid,
        [switch]$All,
        $APIName = "Set GDAP Auto Exension",
        $ExecutingUser
    )

    $ReturnedData = if ($All -eq $true) {
        $Relationships = New-GraphGetRequest -uri "https://graph.microsoft.com/beta/tenantRelationships/delegatedAdminRelationships" -tenantid $env:tenantid -NoAuthCheck $true | Where-Object -Property autoExtendDuration -eq "PT0S"
        foreach ($Relation in $Relationships) {
            try {
                $AddedHeader = @{"If-Match" = $Relation."@odata.etag" }
                $GraphRequest = New-GraphPostRequest -uri "https://graph.microsoft.com/beta/tenantRelationships/delegatedAdminRelationships/$($Relation.id)" -tenantid $env:tenantid -type PATCH -body '{"autoExtendDuration":"P180D"}' -Verbose -NoAuthCheck $true -AddedHeaders $AddedHeader
                write-LogMessage -user $ExecutingUser -API $APIName -message "Successfully set auto renew for tenant $($Relation.customer.displayName) with ID $($RelationShipid)" -Sev "Info"
                @("Successfully set auto renew for tenant $($Relation.customer.displayName) with ID $($Relation.id)" )
    
            }
            catch {
                $ErrorMessage = $_.Exception.Message
                $CleanError = Get-NormalizedError -message $ErrorMessage
                "Could not set auto renewal for $($Relation.id): $CleanError"
            }

        }
    }
    else {
        try {
            $Relationship = New-GraphGetRequest -uri "https://graph.microsoft.com/beta/tenantRelationships/delegatedAdminRelationships" -tenantid $env:tenantid -NoAuthCheck $true | Where-Object -Property id -EQ $RelationShipid

            $GraphRequest = New-GraphPostRequest -uri "https://graph.microsoft.com/beta/tenantRelationships/delegatedAdminRelationships/$($RelationShipid)" -tenantid $env:tenantid -type PATCH -body '{"autoExtendDuration":"P180D"}' -Verbose -NoAuthCheck $true
            write-LogMessage -user $ExecutingUser -API $APIName -message "Successfully set auto renew for tenant $($Relationship.customer.displayName) with ID $($RelationShipid)" -Sev "Info"
            @("Successfully set auto renew for tenant $($Relationship.customer.displayName) with ID $($RelationShipid)" )
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            $CleanError = Get-NormalizedError -message $ErrorMessage
            "Could not set auto renewal for $($RelationShipid): $CleanError"
        }
    }

    return $ReturnedData

}