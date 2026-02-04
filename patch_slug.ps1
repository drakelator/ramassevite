$files = @("c:\Users\mickf\.gemini\ramassevite\generate_pages.ps1", "c:\Users\mickf\.gemini\ramassevite\generate_pages_en.ps1", "c:\Users\mickf\.gemini\ramassevite\generate_locations_hub.ps1")

$slug_function_replacement = @'
function Get-Slug {
    param ([string]$text)
    
    # Pre-replace common accents MANUALLY to ensure safety
    $text = $text -replace [char]0xE9, 'e' # é
    $text = $text -replace [char]0xE8, 'e' # è
    $text = $text -replace [char]0xEA, 'e' # ê
    $text = $text -replace [char]0xEB, 'e' # ë
    $text = $text -replace [char]0xE0, 'a' # à
    $text = $text -replace [char]0xE2, 'a' # â
    $text = $text -replace [char]0xF4, 'o' # ô
    $text = $text -replace [char]0xCE, 'i' # Î
    $text = $text -replace [char]0xEF, 'i' # ï
    $text = $text -replace [char]0xEE, 'i' # î
    $text = $text -replace [char]0xE7, 'c' # ç
    $text = $text -replace [char]0xF9, 'u' # ù
    $text = $text -replace [char]0xFB, 'u' # û
    
    # Normalize string to decompose characters (e.g. é -> e + ')
    $text = $text.Normalize([System.Text.NormalizationForm]::FormD)
    $builder = New-Object System.Text.StringBuilder
    
    foreach ($c in $text.ToCharArray()) {
        if ([System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c) -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append($c)
        }
    }
    
    $slug = $builder.ToString().Normalize([System.Text.NormalizationForm]::FormC)
    $slug = $slug.ToLower()
    $slug = $slug -replace '[^a-z0-9\s-]', '' 
    $slug = $slug -replace '\s+', '-'         
    $slug = $slug -replace '-+', '-'          
    
    return $slug
}
'@

foreach ($file in $files) {
    if (Test-Path $file) {
        $content = [System.IO.File]::ReadAllText($file, [System.Text.Encoding]::UTF8)
        
        # Regex to find the Get-Slug function
        $content = $content -replace 'function Get-Slug \{[\s\S]*?return \$slug\r?\n\}', $slug_function_replacement
        
        [System.IO.File]::WriteAllText($file, $content, [System.Text.Encoding]::UTF8)
        Write-Host "Updated Get-Slug in $file"
    } else {
        Write-Host "File $file not found"
    }
}
