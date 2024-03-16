import QtQuick 2.0
import Sailfish.Silica 1.0 as S
import "../modules/Opal/About" as A

A.AboutPageBase {
    appName: "Screen Time"
    appIcon: Qt.resolvedUrl("../../icons/172x172/screentime.png")
    appVersion: "1.0.0"
    description: "Application to track screen time usage"
    authors: "Miika Malin"
    licenses: A.License { spdxId: "GPL-3.0-or-later" }
    changelogItems: [
        // add new entries at the top
        A.ChangelogItem {
            version: "v1.0.0"
            date: "2024-03-16"
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
