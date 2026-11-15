#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in

  start)
    if systemctl is-active --quiet docker.service; then
      echo "[WORKSTATION] Traditional Docker is active."
      echo "Stop it with ws-docker stop before starting Rootless."
      exit 1
    fi

    echo "[WORKSTATION] Starting Docker Rootless..."
    systemctl --user start docker.service

    docker --context rootless info \
      --format 'Rootless Engine: {{.ServerVersion}}'
    ;;

  stop)
    echo "[WORKSTATION] Checking Rootless containers..."

    if systemctl --user is-active --quiet docker.service; then
      running="$(docker --context rootless ps -q)"

      if [ -n "$running" ]; then
        echo "Running containers detected."
        echo "Stop them before shutting down Rootless."
        docker --context rootless ps
        exit 1
      fi

      systemctl --user stop docker.service
    fi

    echo "[WORKSTATION] Docker Rootless stopped."
    ;;

  status)
    printf 'Rootless service: '
    systemctl --user is-active docker.service || true

    printf 'Automatic startup: '
    systemctl --user is-enabled docker.service || true

    printf 'Docker context: '
    docker context show
    ;;

  ps)
    docker --context rootless ps
    ;;

  images)
    docker --context rootless image ls
    ;;

  *)
    echo "WORKSTATION Rootless Control"
    echo "Usage: ws-rootless {start|stop|status|ps|images}"
    exit 1
    ;;
esac
