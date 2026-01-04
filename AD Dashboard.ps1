<#
Name: Tanner Raine
Date Created: 12/29/2025
Last Edit: 12/30/2025
Description: This is a script to take data from the local Domain Controller (DC) and output this data
to an HTML webpage. The purpose is to allow faster viewing of information in a centralized area versus
needing to view several different applications.

This project is inspired by "JackedProgrammer" on YouTube.
#>

$forestName = "#Insert-Forest-Name"

$forest=Get-ADForest -Identity $forestName

$domains=$forest.Domains
$GlobalCatalog=$forest.GlobalCatalogs

$allDomainInfo =[system.collections.arraylist]@()

foreach($domain in $domains){
    $domainControllers=Get-ADDomainController -Server $domain -Filter *
    $defaultPasswordPolicy = Get-ADDefaultDomainPasswordPolicy -Server $domain
    $FineGrainedPolicies = Get-ADFIneGrainedPasswordPolicy -Server $domain -Filter *
    $UserProperties = @('accountexpirationdate', 'accountlockouttime', 'created', 'department', 'description', 'displayname', 'emailaddress', 'employeeid', 'enabled', 'lastlogondate', 'lockedout', 'office', 'passwordlastset', 'samaccountname', 'title')
    $ComputerProperties = @('createTimeStamp','Description', 'DistinguishedName', 'DNSHostName','Enabled', 'IPV4Address', 'name', 'operatingsystem', 'operatingsystemservicepack', 'Operatingsystemversion')

    $users=Get-ADUser -filter * -Properties $UserProperties -Server $domain
    $computers = Get-ADComputer -Filter * -Properties $ComputerProperties -Server $domain

    

    $entry=New-Object -TypeName PSCustomObject
    Add-Member -InputObject $entry -MemberType NoteProperty -Name "Domain" -Value $domain
    Add-Member -InputObject $entry -MemberType NoteProperty -Name "DomainControllers" -value $domainControllers
    Add-Member -InputObject $entry -MemberType NoteProperty -Name "DefaultDomainPasswordPolicy" -Value $defaultPasswordPolicy
    Add-Member -InputObject $entry -MemberType NoteProperty -Name "DomainFineGrainedPasswordPolicies" -Value $FineGrainedPolicies
    Add-Member -InputObject $entry -MemberType NoteProperty -Name "Users" -Value $users
    Add-Member -InputObject $entry -MemberType NoteProperty -Name "Computers" -Value $computers

    $allDomainInfo.add($entry)
}

$allDomainCtrollersTable = $allDomainInfo.domainControllers | select name,IPv4Address,domain,hostname,enabled,operatingsystem,forest

new-HTML -Online -TitleText "Active Directory Dashboard" -FilePath "Insert-Output-Path-Here!!!" -ShowHTML{
    New-HTMLTab -Name "Forest" {
        New-HTMLSection -Invisible{
            New-HTMLSection -HeaderText "Forest Information"{
                New-HTMLPanel -Margin "10px" {
                "<p>Forest : $forestName</p>"
                "<p>Forest Functional Level : $($forest.ForestMode)</p>"
                "<p>Domains :</p>"
                "<ul>"
                foreach($domain in $domains){
                    "<li>$($domain)</li>"
                }
                "</ul>"
                "<p>Root Domain : $($forest.RootDomain)</p>"
                "<p>Global Catalogs :</p>"
                "<ul>"
                foreach($catalog in $globalcatalog){
                    "<li>$($catalog)</li>"
                }
                "</ul>"
                }
                }
        }
        New-HTMLSection -HeaderText "Domain Controllers"{
            New-HTMLPanel{
                Table -DataTable $allDomainCtrollersTable
          }
        }
    }
    foreach($domain in $allDomainInfo){
        New-HTMLTab -Name "$($domain.Domain)" {
            New-HTMLSection -HeaderText "Domain Controllers" {
                New-HTMLPanel -Invisible {
                    table -DataTable $($domain | select -ExpandProperty DomainControllers) -HideFooter -HideButtons
                }
            }
            New-HTMLSection -HeaderText "Password Policies" -Invisible {
                New-HtmlSection -HeaderText "Default Domain Password Poliy" {
                    New-HTMLPanel {
                        $defaultPasswordPolicyTable = @{}
                        $($domain | select -ExpandProperty DefaultDomainPasswordPolicy | select ComplexityEnabled,LockoutDuration,LockoutObservationWindow,LockoutThreshold,MaxPasswordAge,MinPasswordAge,MinPasswordLength,PasswordHistoryCount,ReversibleEncryptionEnabled).psobject.properties | foreach{$defaultPasswordPolicyTable[$_.Name]=$_.value}
                        
                        Table -DataTable $defaultPasswordPolicyTable -DefaultSortOrder Ascending -DefaultSortColumn name -HideFooter -HideButtons
                    }
                }
                New-HtmlSection -HeaderText "Domain Fine Grained Password Policies" {
                    New-HTMLPanel {
                        Table -DataTable $($domain | select -ExpandProperty DomainFineGrainedPasswordPolicies)
                    }
                }
            }
            New-HTMLSection -HeaderText "Users" -Invisible {
                $disabledUsers = $Domain.Users | where-object enabled -eq $false
                
                $Lockedoutusers = $Domain.Users | where-object lockedout -eq $true
                $Lockedoutuserstable = $Lockedoutusers | select-object name,accountlockouttime,title,office,samaccountname,enabled,lastlogondate,distingushedname

                $expiredUsers = $Domain.Users | Where-Object {
                    $_.AccountExpirationDate -ne $null -and
                    $_.AccountExpirationDate -lt (Get-Date)
                }

                $expiredUsersTable = $expiredUsers | select-object name,accountlockouttime,title,office,samaccountname,enabled,lastlogondate,distingushedname

                $disabledUserstable = $disabledUsers | Select-Object name,accountexpirationdate, title,samaccountname,enabled,lastlogondate,distingushedname
                
                new-HTMLSection -HeaderText "Disabled Users"{
                    New-HTMLPanel -Invisible{
                        Table -DataTable $disabledUserstable -HideFooter -HideButtons
                    }
                    }

                new-HTMLSection -HeaderText "Locked Out Users"{
                    New-HTMLPanel -Invisible{
                        Table -DataTable $lockedoutuserstable -HideFooter -HideButtons
                    }
                    }

                new-HTMLSection -HeaderText "Expired Users"{
                    New-HTMLPanel -Invisible{
                        Table -DataTable $expireduserstable -HideFooter -HideButtons
                    }
                    
                }

            
            }
            new-HTMLSection -HeaderText "Computers"{
                New-HTMLPanel -Invisible{
                    $computerstable = $computers | select 'Name', 'OperatingSystem', 'OperatingSystemServicePack','CreateTimeStamp','Description','IPV4Address'
                    Table -DataTable $computerstable -HideFooter
                }
                    
            }
        }
    }
    
}