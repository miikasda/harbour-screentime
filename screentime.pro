# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = screentime

CONFIG += sailfishapp_qml

DISTFILES += qml/screentime.qml \
    qml/cover/CoverPage.qml \
    qml/database.js \
    qml/qmldir \
    qml/LabelData.qml \
    qml/modules/GraphData/Axis.qml \
    qml/modules/GraphData/GraphData.qml \
    qml/pages/AboutPage.qml \
    qml/pages/FirstPage.qml \
    qml/pages/HistoryPage.qml \
    qml/pages/SettingsPage.qml \
    qml/pages/SecondPage.qml \
    rpm/screentime.changes.in \
    rpm/screentime.changes.run.in \
    rpm/screentime.spec \
    screentime.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
#TRANSLATIONS += translations/screentime-de.ts
