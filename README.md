
<p align="center">
  <img src="qml/screentime-icon.png?" />
</p>

# Screen Time (harbour-screentime)

Screen Time is the app to track screen time usage and monitor your digital wellbeing on Sailfish OS. Your privacy is protected, with all data securely stored on-device in an SQLite database. Easily monitor usage and access historical data.

**Note: Keep the app running in the background for continuous screen usage monitoring.**

<p align="center">
    <img src="screenshots/mainScreen.png?" width="400">
</p>

## Automatic launch with Partnerspace

The app can be configured to run continuously in the background and automatically launch using Partnerspace. Access the app in Partnerspace by swiping left on your home screen.

### Enabling Partnerspace for Screen Time:
```
dconf write /desktop/lipstick-jolla-home/partnerspace/applications "['/usr/share/applications/harbour-screentime.desktop']"
```

### Disabling Partnerspace
```
dconf write /desktop/lipstick-jolla-home/partnerspace/applications "@as []"
```

## Acknowledgements

Screen Time uses slightly modified version of graphs from [systemmonitor](https://github.com/custodian/harbour-systemmonitor), and about page has been done by using [Opal](https://github.com/Pretty-SFOS/opal-about).

## License

Screen Time is licensed under GPL-3.0. License is provided [here](LICENSE).


## Local data location

The screen on / off events are stored in local SQLite database. The database is located at `~/.local/share/org.malmi/harbour-screentime/QML/OfflineStorage/Databases/` . For example if your phone IP is 192.168.1.98, the database can be pulled with rsync:

```
rsync defaultuser@192.168.1.98:~/.local/share/org.malmi/harbour-screentime/QML/OfflineStorage/Databases/*.sqlite ./
```