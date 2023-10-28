$exclusions = @(
    "C:\Users\Foo\Foo"
    # "C:\Downloads",
)

foreach ($exclusion in $exclusions) {
    Add-MpPreference -ExclusionPath $exclusion
}
