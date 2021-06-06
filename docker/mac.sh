#!/bin/bash
# mac を前提としています。

# envを生成する
if [ ! -e '.env' ]; then
    echo envファイルを生成します。
    cp .env.local .env
    echo envファイルが生成されました。
fi

# ループバックIPを設定する
LOCAL_IP=$(grep LOCAL_IP .env | cut -d '=' -f2)

# sudo ifconfig lo0 alias を叩く
if ifconfig | grep -i "$LOCAL_IP"  >/dev/null; then
    echo "$LOCAL_IP" は有効です。
else
    echo "$LOCAL_IP"のエイリアスを生成します。お使いのマシンのパスワードを設定してください
    sudo ifconfig lo0 alias "$LOCAL_IP" up
fi

# プロジェクト名定義
COMPOSE_PROJECT_NAME=$(grep PROJECT_NAME .env | cut -d '=' -f2 | head -1)

# プリフィックス定義
HTTPS_PREFIX=$(grep HTTPS_PREFIX .env | cut -d '=' -f2 | head -1)
NGINX_PREFIX=$(grep NGINX_PREFIX .env | cut -d '=' -f2 | head -1)
APP_PREFIX=$(grep APP_PREFIX .env | cut -d '=' -f2 | head -1)
DB_PREFIX=$(grep DB_PREFIX .env | cut -d '=' -f2 | head -1)
DB_PORT=$(grep DB_PORT .env | cut -d '=' -f2 | head -1)
SCHEMA_PREFIX=$(grep SCHEMASPY_PREFIX .env | cut -d '=' -f2 | head -1)

# コンテナ名定義
HTTPS="${HTTPS_PREFIX}-${COMPOSE_PROJECT_NAME}"
WEB="${NGINX_PREFIX}-${COMPOSE_PROJECT_NAME}"
APP="${APP_PREFIX}-${COMPOSE_PROJECT_NAME}"
DB="${DB_PREFIX}-${COMPOSE_PROJECT_NAME}"
SCHEMA="${SCHEMA_PREFIX}-${COMPOSE_PROJECT_NAME}"

# その他値設定
DB_USER="${DB_PREFIX}-${COMPOSE_PROJECT_NAME}"
DB_PORT=$(grep DB_PORT .env | cut -d '=' -f2 | head -1)
DB_DATABASE="${DB_PREFIX}-${COMPOSE_PROJECT_NAME}"
DB_PASSWORD="${DB_PREFIX}-${COMPOSE_PROJECT_NAME}"

# コマンド定義
RUN_APP="docker exec -it ${APP}"
RUN_SCHEMA="docker exec -it ${SCHEMA}"

# コンテナ内のパス定義
REMOTE_APP_DIR="/${COMPOSE_PROJECT_NAME}"
REMOTE_VENDOR_DIR="${REMOTE_APP_DIR}/vendor"
REMOTE_NODE_DIR="${REMOTE_APP_DIR}/node_modules"

# ローカルのパス定義
LOCAL_APP_DIR="../src"
LOCAL_VENDOR_DIR="${LOCAL_APP_DIR}/vendor"
LOCAL_NODE_DIR="${LOCAL_APP_DIR}/node_modules"

case "$1" in
"create")
  # イメージ、データボリュームの全消し。最初からやり直す場合に使用する。
  docker-compose down --rmi all --volumes --remove-orphans

  rm -rf ${LOCAL_VENDOR_DIR}
  rm -rf ${LOCAL_NODE_DIR}

  docker compose up -d --build

  ${RUN_APP} dockerize -timeout 60s -wait tcp://"${DB}":"${DB_PORT}"

  ${RUN_APP} chmod 777 -R storage
  ${RUN_APP} composer install
  ${RUN_APP} composer dump-autoload

  ${RUN_APP} ./artisan migrate:refresh --seed
  ${RUN_APP} ./artisan ide-helper:generate
  ${RUN_APP} ./artisan ide-helper:models --nowrite

  ${RUN_APP} npm install
  ${RUN_APP} npm run dev

  docker cp "${APP}:${REMOTE_VENDOR_DIR}" ${LOCAL_APP_DIR}
  docker cp "${APP}:${REMOTE_NODE_DIR}" ${LOCAL_APP_DIR}
  docker cp "${APP}:${REMOTE_APP_DIR}/_ide_helper.php" ${LOCAL_APP_DIR}
  docker cp "${APP}:${REMOTE_APP_DIR}/_ide_helper_models.php" ${LOCAL_APP_DIR}

  ${RUN_SCHEMA} java -jar schemaspy.jar \
      -o /output -t pgsql \
      -u "${DB_USER}" \
      -dp /app \
      -host "${DB}" \
      -port "${DB_PORT}" \
      -db "${DB_DATABASE}" \
      -p "${DB_PASSWORD}" \
      -s public

  docker container prune -f
  docker image prune -f
  docker images
  docker ps -a
  ;;

"up")
# docker composeの単純な再起動
  docker compose down
  docker compose up -d
  docker ps -a
  ;;

"down")
# docker compose down を行う処理
  docker compose down
  docker container prune -f
  docker image prune -f
  docker images
  docker ps -a
  ;;

"composer")
  # composer周りの処理で使うコマンド
  rm -rf ${LOCAL_VENDOR_DIR}
  ${RUN_APP} composer "${@:2}"
  docker cp ${APP}:${REMOTE_VENDOR_DIR} ${LOCAL_APP_DIR}
  ;;

"logs")
  # ログを出力するコマンド
  docker-compose logs -f
  ;;

"app")
  # PHPコンテナに入るためのコマンド
  docker exec -it ${APP} sh
  ;;

"web")
  # NGINXコンテナに入るためのコマンド
  docker exec -it ${WEB} sh
  ;;

"ide")
  # laravel ide のファイルを出力するためのコマンド
  ${RUN_APP} ./artisan ide-helper:generate
  ${RUN_APP} ./artisan ide-helper:models --nowrite
  docker cp ${APP}:${REMOTE_APP_DIR}/_ide_helper.php ${LOCAL_APP_DIR}
  docker cp ${APP}:${REMOTE_APP_DIR}/_ide_helper_models.php ${LOCAL_APP_DIR}
  ;;

"schema")
  # schemaspyを更新するためのコマンド
  ${RUN_SCHEMA} java -jar schemaspy.jar \
      -o /output -t pgsql \
      -u "${DB_USER}" \
      -dp /app \
      -host "${DB}" \
      -port "${DB_PORT}" \
      -db "${DB_DATABASE}" \
      -p "${DB_PASSWORD}" \
      -s public
  ;;
esac
