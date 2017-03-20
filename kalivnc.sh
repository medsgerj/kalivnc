
uid=$(id -u)
if [ $uid != 0 ]
then
	echo "Error: Must run as root."
	exit 1
fi

echo "[*] Adding vncserver user."
useradd vncserver -m

echo "[*] Set a password for vncserver user:"
passwd vncserver

echo "[*] Set a password for vncserver access:"
/usr/bin/vncpasswd vncserver

echo "[*] Creating .Xresources file."
xresources=/home/vncserver/.Xresources
touch $xresources
chown vncserver:vncserver $xresources

echo "[*] Creating .xstartup file."
xstartup=/home/vncserver/.vnc/xstartup
touch $xstartup
chown vncserver:vncserver $xstartup
chmod 755 $xstartup

echo "#!/bin/sh" >> $xstartup
echo "" >> $xstartup
echo "xrdb \$HOME/.Xresources" >> $xstartup
echo "xsetroot -solid grey" >> $xstartup
echo "export XKL_XMODMAP_DISABLE=1" >> $xstartup
echo "/usr/bin/xfce4-session" >> $xstartup

echo "[*] Creating vncserver.service file."
vcs=/etc/systemd/system/vncserver.service

rm -f $vcs
touch $vcs
chmod 644 $vcs

echo "[Unit]" >> $vcs
echo "Description=vncserver" >> $vcs
echo "After=network.target" >> $vcs
echo "" >> $vcs
echo "[Service]" >> $vcs
echo "Type=oneshot" >> $vcs
echo "ExecStart=/usr/bin/vncserver :1 -localhost" >> $vcs
echo "ExecStop=/usr/bin/vncserver -kill :1" >> $vcs
echo "User=vncserver" >> $vcs
echo "" >> $vcs
echo "[Install]" >> $vcs
echo "WantedBy=multi-user.target" >> $vcs

echo "[*] Enabling vncserver service."
systemctl enable vncserver

echo "[*] Starting vncserver service."
systemctl start vncserver
