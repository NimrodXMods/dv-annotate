@{
    Root = 'windows\dv-annotate.ps1' # Root script to package. This is the main entry point for the package.
    OutputPath = 'windows\build\' # The output directory for the packaging process.
    Package = @{
        Enabled = $false # Whether to package as an executable.
    }
    Bundle = @{
        Enabled = $true # Whether to bundle multiple PS1s into a single PS1. Always enabled when Package is enabled.
        Modules = $true # Whether to bundle modules into the package
    }
}
