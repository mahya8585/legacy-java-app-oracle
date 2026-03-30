FROM gvenzl/oracle-xe:19-slim

ENV ORACLE_PASSWORD=oracle123
ENV APP_USER=DIVINGAPP
ENV APP_USER_PASSWORD=divingapp123

# 初期化スクリプト（01: ユーザー作成, 02: スキーマ＋サンプルデータ投入）
# DBスクリプト本体は docker-compose.yml のボリュームマウントで /opt/oracle/scripts/ に配置
COPY init-scripts/ /container-entrypoint-initdb.d/
