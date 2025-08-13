# netcup-updater

Automatisiertes Docker-Setup zum regelmäßigen Aktualisieren von DNS-Einträgen bei Netcup.

## Features
- Aktualisiert DNS-Einträge automatisch alle 30 Minuten per Cronjob
- Konfigurierbar über eine `.env` Datei
- Minimaler Docker-Container auf Basis von Alpine Linux

## Voraussetzungen
- Docker
- Netcup API Zugangsdaten

## Installation
1. Repository klonen:
   ```sh
   git clone git@github.com:NinjaEde/netcup-updater.git
   cd netcup-updater
   ```
2. `.env.example` kopieren und anpassen:
   ```sh
   cp .env.example .env
   # Trage deine Netcup-Zugangsdaten ein
   ```
3. Docker-Image bauen:
   ```sh
   docker build -t netcup-updater .
   ```
4. Container starten:
   ```sh
   docker run -d --env-file .env netcup-updater
   ```

## Dateien
- `update_netcup.sh` – Das Update-Skript
- `Dockerfile` – Docker-Konfiguration
- `.env.example` – Beispiel für Umgebungsvariablen
- `.gitignore` – Git Ignore Regeln

## Hinweise
- Die Log-Ausgabe des Cronjobs befindet sich im Container unter `/var/log/cron.log`.
- Die `.env` Datei sollte niemals ins Repository eingecheckt werden.

## Lizenz
MIT
