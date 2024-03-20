Name:       harbour-screentime

Summary:    Application to track screen time usage
Version:    1.0.0
Release:    1
License:    GPLv3
BuildArch:  noarch
URL:        https://github.com/miikasda/harbour-screentime
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
Requires:   libsailfishapp-launcher
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.3
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5DBus)
BuildRequires:  pkgconfig(Qt5Sql)
BuildRequires:  desktop-file-utils

%description
Screen Time is the app to track screen time usage and monitor your digital wellbeing on
Sailfish OS. Your privacy is protected, with all data securely stored on-device in an
SQLite database. Easily monitor usage and access historical data.

Note: Keep the app running in the background for continuous screen usage monitoring.

# This section includes metadata for SailfishOS:Chum, see
# https://github.com/sailfishos-chum/main/blob/main/Metadata.md
%if 0%{?_chum}
Title: Screen Time
Type: desktop-application
DeveloperName: Miika Malin
Categories:
 - System
Custom:
  Repo: https://github.com/miikasda/harbour-screentime
PackageIcon: https://github.com/miikasda/harbour-screentime/raw/main/icons/172x172/harbour-screentime.png
Screenshots:
 - https://github.com/miikasda/harbour-screentime/raw/main/screenshots/mainScreen.png
Links:
  Homepage: https://github.com/miikasda/harbour-screentime
  Bugtracker: https://github.com/miikasda/harbour-screentime/issues
  Donation: https://github.com/sponsors/miikasda
%endif

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5 

%make_build


%install
%qmake5_install


desktop-file-install --delete-original         --dir %{buildroot}%{_datadir}/applications                %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%defattr(0644,root,root,-)
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png

# This block is needed for Opal not to provide anything which is not allowed in harbour
# >> macros
%define __provides_exclude_from ^%{_datadir}/.*$
# << macros
