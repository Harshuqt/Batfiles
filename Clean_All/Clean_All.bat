RD /S /Q "C:\Users\%Username%\AppData\Local\Temp"
RD /S /Q "C:\Windows\SoftwareDistribution\Download"
RD /S /Q "C:\Windows\Prefetch"
RD /S /Q "C:\Windows\temp"
RD /S /Q "C:\Windows\System32\sru\SRUDB.dat"
RD /S /Q "C:\Users\%Username%\AppData\Local\NVIDIA\GLCache"
RD /S /Q "C:\Users\%Username%\AppData\Local\Spotify\Data"
RD /S /Q "C:\Users\%Username%\Desktop\debug.log"
RD /S /Q "C:\Users\%Username%\AppData\Local\Packages\Microsoft.Windows.Search_cw5n1h2txyewy\LocalState\AppIconCache"
RD /S /Q "C:\Users\%Username%\AppData\Local\AMD\CN"
RD /S /Q "C:\Users\%Username%\AppData\Local\pip\cache"
RD /S /Q "C:\Users\%Username%\AppData\Local\Plex Media Server\Cache"
RD /S /Q "C:\Users\%Username%\AppData\Roaming\Adobe\Common\Media Cache Files"
RD /S /Q "C:\Users\%Username%\AppData\Local\Google\Nearby\Sharing\Logs"
RD /S /Q "C:\Users\%Username%\AppData\Local\SquirrelTemp"
call CleanForza4.bat
netsh winsock reset
netsh int ip reset
ipconfig /flushdns
::ipconfig /release
::ipconfig /renew

