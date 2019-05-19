
Katie, I am sending you some instructions in case you have to restart the scripts to plot the data after a reboot. 

Like I said, the system automatically executes the scripts every day at 60 minutes intervals, starting at 00:30, then 01:30, 02:30 and so on. 
It should restart in case of a forced reboot such as in case of a power loss. However, the scripts are located in /home/pi/Scripts.

If you double click on the icon Terminal on the desktop, then you move to the directory Scripts by typing cd Scripts, then you can execute the 
main script by typing python3 control.py. This is the control script which first checks for an internet connection then calls three other python3 
scripts in sequence using subprocess (to keep the limited memory of the Pi available).

1)	clean_datastore.py simply removes data files that are older than four days
2)	getemaildata.py reads emails from geomagdata@gmail.com (pwd is same as vnc log on, i.e., G30m@gAPI), it will only pick up emails from 
        tanjap@toho.gns.cri.nz which are unread, it will then only download the datafile if the name is correct (is a date) and is less than 4 days old. 
        It then flags the email it took the datafile from as read (so it won’t read it again) and save the data in the data store.
3)	Plotgeomagdata.py is the script that grabs every file in the data store, removes duplicates (e.g. a fixed data file was sent later), and bad values
        (e.g. 99999.0) calculates the F diff, and then plots five data streams.

The system is now connected to the wireless network climate_5G, however, as a backup could be connected to the network using the plug 11 on the wall 
as per attached photo. Should you change the password of the wireless network in the future then the  small computer controlling the execution of the 
scripts should be updated correspondingly.

