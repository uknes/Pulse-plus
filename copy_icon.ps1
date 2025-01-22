$source = "assets/icons/app_logo_transparent.png"
$sizes = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

foreach ($size in $sizes.GetEnumerator()) {
    $dest = "android/app/src/main/res/mipmap-$($size.Key)/ic_launcher.png"
    Copy-Item $source $dest -Force
} 