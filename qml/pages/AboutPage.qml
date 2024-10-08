import QtQuick 2.0
import Sailfish.Silica 1.0 as S
import "../modules/Opal/About" as A

A.AboutPageBase {
    appName: "Screen Time"
    appIcon: Qt.resolvedUrl("../screentime-icon.png")
    appVersion: "1.0.2"
    description: "Application to track screen time usage"
    authors: "Miika Malin"
    licenses: A.License { spdxId: "GPL-3.0-or-later" }
    changelogItems: [
        // add new entries at the top
        A.ChangelogItem {
            version: "v1.0.2"
            date: "2024-08-09"
            paragraphs: "Improve efficiency when getting screen status"
        },
        A.ChangelogItem {
            version: "v1.0.1"
            date: "2024-03-20"
            paragraphs: "Fix license and url information from .spec file"
        },
        A.ChangelogItem {
            version: "v1.0.0"
            date: "2024-03-19"
            paragraphs: "Initial release"
        }
    ]
    attributions: [
        A.Attribution {
            name: "Graphs"
            entries: ["Basil Semuonov"]
            sources: "https://github.com/custodian/harbour-systemmonitor"
        },
        A.OpalAboutAttribution {}
    ]
    sourcesUrl: "https://github.com/miikasda/harbour-screentime"
    donations.text: "If you like Screen Time so much that you would like " +
                    "to buy me a cup of coffee, you can do so by GitHub " +
                    "Sponsors below"
    donations.services: [
        A.DonationService {
            name: "GitHub Sponsors"
            url: "https://github.com/sponsors/miikasda"
        }
    ]
}
