ConvertFrom-StringData -StringData @'
AskSelectMethod                        = Please select an import method
AskTemplateDirectory                   = Please select a template Directory
AskTemplateGithubURI                   = Please select a template Github URI
AskDestinationRoot                     = Please select a root destination for the project
AskRepositoryName                      = Please select a repository name
ErrorCannotFindJson                    = Cannot find templator.json where the terms to replace should be located
ErrorMustSelectMethod                  = No import method
ErrorProjectAlreadyExist               = Project already exist
ErrorNoTemplate                        = Template does not exist
ErrorCantDownload                      = Template cannot be downloaded
ErrorTemplateCopy                      = An error occured during the copy
ErrorFilesCountNotMatch                = The number of files does not match ({0}={1})
ErrorProjectStillContainsTerms         = The project still contains generic terms
WarningFileStillContainsTerms          = The file {0} still contains generic terms
SuccessCopy                            = The copy succeeded ({0} files)
'@
