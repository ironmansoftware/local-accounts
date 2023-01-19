New-UDDashboard -Title 'Local Accounts' -Pages @(
    New-UDPage -Name 'Local Accounts' -Content {

        New-UDStack -Direction column -Content {
            New-UDDynamic -Id 'users' -Content {
                $Accounts = Get-LocalUser 

                New-UDTable -Title '    Users' -Icon (New-UDIcon -Icon 'User') -Data $Accounts -Columns @(
                    New-UDTableColumn -Property Name
                    New-UDTableColumn -Property FullName -Title 'Full Name'
                    New-UDTableColumn -Property PrincipalSource -Title 'Principal Source'
                ) -ToolbarContent {
                    New-UDButton -Text 'Add User' -Icon (New-UDIcon -Icon PlusSquare) -OnClick {
                        Show-UDModal -Header {
                            New-UDTypography -Variant h2 -Text "Add User"
                        } -Content {
                            New-UDForm -Content {
                                New-UDTextbox -Label 'Name' -Id 'Name'
                                New-UDTextbox -Label 'Full Name' -Id 'FullName'
                                New-UDTextbox -Label 'Password' -Id 'Password' -Type password
                            } -OnValidate {
                                if ([string]::IsNullOrWhiteSpace($EventData.Name))
                                {
                                    New-UDValidationResult -ValidationError 'Name is required'
                                }
                                elseif ([string]::IsNullOrWhiteSpace($EventData.FullName))
                                {
                                    New-UDValidationResult -ValidationError 'Full Name is required'
                                }
                                elseif ([string]::IsNullOrWhiteSpace($EventData.Password))
                                {
                                    New-UDValidationResult -ValidationError 'Password is required'
                                }
                                else {
                                    New-UDValidationResult -Valid
                                }
                            } -OnSubmit {
                                $Password = $EventData.Password | ConvertTo-SecureString -AsPlainText
                                New-LocalUser -Name $EventData.Name -FullName $EventData.FullName -Password $Password
                                Sync-UDElement -Id 'users'
                            }
                        }
                    }
                }
            }
            

            $Groups = Get-LocalGroup 

            New-UDTable -Title '    Groups' -Icon (New-UDIcon -Icon 'Users') -Data $Groups -Columns @(
                New-UDTableColumn -Property Name
                New-UDTableColumn -Property Description -Width 400
                New-UDTableColumn -Property PrincipalSource -Title 'Principal Source'
                New-UDTableColumn -Property Actions -Render {
                    $Group = $EventData.Name
                    New-UDButton -Icon (New-UDIcon -Icon User) -Text 'View Members' -OnClick {
                        Show-UDModal -Content {
                            $Members = Get-LocalGroupMember -Group $Group

                            if ($Members.Length -eq 0) {
                                New-UDAlert -Text "No members" -Severity warning
                            }
                            else 
                            {
                                New-UDTable -Data $Members -Columns @(
                                    New-UDTableColumn -Property Name
                                    New-UDTableColumn -Property ObjectClass -Title 'Object Class'
                                )
                            }

                        } -FullWidth
                    }
                }
            )
        }

    }
)