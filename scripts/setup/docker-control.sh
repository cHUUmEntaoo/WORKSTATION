#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in

  start)
    echo "[WORKSTATION] Starting Docker..."
    sudo systemctl start docker.service
    sudo docker info --format 'Docker Engine: {{.ServerVersion}}'
    ;;

  stop)
    echo "[WORKSTATION] Checking running containers..."

    if systemctl is-active --quiet docker.service; then
      running="$(sudo docker ps -q)"

      if [ -n "$running" ]; then
        echo "Running containers detected."
        echo "Stop your containers before shutting down Docker."
        sudo docker ps
        exit 1
      fi
    fi

    sudo systemctl stop \
      docker.service \
      docker.socket \
      containerd.service

    echo "[WORKSTATION] Docker stopped."
    ;;

  status)
    for unit in docker.service docker.socket containerd.service; do
      printf '%-22s ' "$unit"
      systemctl is-active "$unit" || true
    done
    ;;

  ps)
    sudo docker ps
    ;;

  images)
    sudo docker image ls
    ;;

  *)
    echo "WORKSTATION Docker Control"
    echo "Usage: ws-docker {start|stop|status|ps|images}"
    exit 1
    ;;
esac
