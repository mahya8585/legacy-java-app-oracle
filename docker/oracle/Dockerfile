FROM gvenzl/oracle-xe:19-slim

ENV ORACLE_PASSWORD=oracle123
ENV APP_USER=DIVINGAPP
ENV APP_USER_PASSWORD=divingapp123

COPY init-scripts/ /container-entrypoint-initdb.d/
