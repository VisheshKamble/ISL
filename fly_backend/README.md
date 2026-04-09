# Fly.io Backup Backend (VANI ISL)

This folder is a standalone backup deployment target for Fly.io.

It is intentionally separate from `isl_backend` so your Railway backend remains unchanged.

## 1) Prerequisites

- Install Fly CLI: https://fly.io/docs/hands-on/install-flyctl/
- Login:

```bash
fly auth login
```

## 2) Deploy From This Folder

Run from inside this folder:

```bash
cd fly_backend
fly launch --no-deploy
fly deploy
```

If the app name `vani-isl-backup` is taken, update `app` in `fly.toml` and run `fly deploy` again.

## 3) Optional Secrets

If you rotate model ID or want stricter CORS, set Fly secrets:

```bash
fly secrets set MODEL_FILE_ID="1TcCNyM1MtbixlN3wZgFttOlvuJutTPqB"
fly secrets set VANI_CORS_ORIGINS="https://your-frontend-domain.com"
fly secrets set VANI_CORS_ORIGIN_REGEX="^(https?://(localhost|127\\.0\\.1)(:\\d+)?|https://.*\\.fly\\.dev)$"
```

## 4) Health Check

```bash
fly status
fly logs
```

Endpoint:

- Health: `/health`
- WebSocket: `/ws`

## 5) Flutter Fallback Usage

Use your Fly URL as backup websocket endpoint in your app runtime config when Railway is unavailable.

Example URL format:

```text
wss://<your-fly-app-name>.fly.dev/ws
```
