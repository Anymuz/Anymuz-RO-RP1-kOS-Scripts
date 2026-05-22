$ErrorActionPreference = 'Continue'
$src  = $PSScriptRoot
$out  = Join-Path $PSScriptRoot '..'
$names = @('boot-flow','layer-class','mission-sequence')

Add-Type -AssemblyName System.Drawing

foreach ($n in $names) {
    $infile = Join-Path $src ($n + '.mmd')
    if (-not (Test-Path $infile)) { Write-Host "MISSING $infile"; continue }
    $txt = Get-Content -Raw -Path $infile

    foreach ($fmt in @('png','svg')) {
        $outfile = Join-Path $out ($n + '.' + $fmt)
        try {
            Invoke-WebRequest -Uri ("https://kroki.io/mermaid/" + $fmt) -Method Post -Body $txt -ContentType 'text/plain' -OutFile $outfile -ErrorAction Stop -UseBasicParsing
        } catch {
            Write-Host ("FAIL {0,-20} {1}" -f ($n + '.' + $fmt), $_.Exception.Message)
            continue
        }

        # Force a white background so diagrams are readable in any theme.
        if ($fmt -eq 'png') {
            $img = [System.Drawing.Image]::FromFile($outfile)
            $bmp = New-Object System.Drawing.Bitmap $img.Width, $img.Height
            $g = [System.Drawing.Graphics]::FromImage($bmp)
            $g.Clear([System.Drawing.Color]::White)
            $g.DrawImage($img, 0, 0, $img.Width, $img.Height)
            $g.Dispose(); $img.Dispose()
            $tmp = "$outfile.tmp.png"
            $bmp.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
            $bmp.Dispose()
            Move-Item -Force $tmp $outfile
        } else {
            $c = Get-Content -Raw -Path $outfile
            if ($c -notmatch '<rect id="kos-bg"') {
                $c = $c -replace '(<svg[^>]*>)', '$1<rect id="kos-bg" width="100%" height="100%" fill="#ffffff"/>'
                Set-Content -Path $outfile -Value $c -NoNewline
            }
        }

        Write-Host ("OK   {0,-20} {1,6} bytes" -f ($n + '.' + $fmt), (Get-Item $outfile).Length)
    }
}
