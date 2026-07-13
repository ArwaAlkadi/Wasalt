# Wasalt

**Never miss your metro stop again.**

Wasalt is an iOS app that makes the Riyadh Metro accessible for people with hearing difficulties. Riders who can't rely on audio announcements pick their destination, and Wasalt tracks the trip with GPS and geofencing — then alerts them through **vibration patterns, flashlight strobes, and visual banners** as they approach and arrive at their station.

<br>
<img width="1920" height="1080" alt="Wasalt 3 34 19 AM" src="https://github.com/user-attachments/assets/0e5c10fc-b383-43e2-97c3-cb8536448dfd" />
<br>
<br>


## Features

- **All 6 Riyadh Metro lines** with official station coordinates and route paths
- **Live trip tracking** — ETA, remaining stations, upcoming stops, and progress in real time
- **Geofence-based detection** monitored by iOS itself, so alerts fire even in the background
- **Hearing-accessible alerts** — patterned vibration, flashlight strobe, and on-screen banners instead of sound
- **Wrong-direction detection** — warns you if the train is moving away from your destination
- **System notifications** as a fallback when the app isn't in the foreground
- **Automatic direction handling** — trips work the same whether you ride forward or backward along a line
- **Arabic & English localization** with an accessible, intuitive interface
<br>

## How It Works

The rider selects a metro line and a destination station. Wasalt finds the nearest station, determines the travel direction, and registers three circular geofence regions around key points of the trip:

| Geofence | Radius | What happens on entry |
|---|---|---|
| **Approaching** | 500 m | Banner + vibration pattern: "your station is next" |
| **Arrival** | 250 m | Banner + vibration + **flashlight strobe**: time to get off |
| **Wrong direction** | 500 m | Warns the rider they're moving away from the destination |

Because geofencing is handled by iOS rather than the app lifecycle, region entry fires reliably even when the phone is locked — system notifications cover the background case, while in-app banners with vibration/flash patterns cover the foreground. Every trip auto-expires after 2.5 hours to stop long-running geofences, save battery, and reset the app to a safe state.

Along the way, the trip engine continuously computes the nearest station, remaining stations, and ETA, and detects direction reversals by watching the rider's station order over time.

<br>


## Tech Stack

| Layer | Technology |
|---|---|
| Language / UI | Swift · SwiftUI |
| Location | CoreLocation · MapKit (geofencing, GeoJSON routes) |
| Alerts | AVFoundation (torch) · UserNotifications · haptics |
| Architecture | MVVM — no external dependencies |
| Localization | Arabic · English |
| Data | Official Riyadh Metro station coordinates + line GeoJSON |
