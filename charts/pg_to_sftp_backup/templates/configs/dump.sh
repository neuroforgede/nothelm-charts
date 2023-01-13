#!/bin/bash

check_result () {
    ___RESULT=$?
    if [ $___RESULT -ne 0 ]; then
        echo $1
        exit 1
    fi
}

set -e -o pipefail

_PGPASSWORD=$(/bin/cat /run/secrets/postgres_pgdump_pgpassword)
_SFTP_PASSWORD=$(/bin/cat /run/secrets/storagebox_password)


echo "getting current date..."
DATE=`date '+%Y_%m_%d_%H_%M_%S'`

PATH_NEW_FILE="${SFTP_BASE_PATH}/${POSTGRES_DB}_${DATE}.sql"
echo "will dump to ${PATH_NEW_FILE}."

echo "starting dump."
pg_dump "postgresql://${POSTGRES_USER}:${_PGPASSWORD}@${POSTGRES_HOST}/${POSTGRES_DB}?target_session_attrs=${POSTGRES_TARGET_SESSION_ATTRS}" \
    | curl -u "${SFTP_USER}:${_SFTP_PASSWORD}" -T - "sftp://${SFTP_TARGET}:${SFTP_BASE_PATH}/${POSTGRES_DB}_${DATE}.sql"
check_result "failed to dump to sftp"

echo "files in dump path:"
curl --silent -u ${SFTP_USER}:${_SFTP_PASSWORD} -k "sftp://${SFTP_TARGET}:${SFTP_BASE_PATH}/"

OLD_FILES=$(
    curl --silent -u ${SFTP_USER}:${_SFTP_PASSWORD} -k "sftp://${SFTP_TARGET}:${SFTP_BASE_PATH}/" \
    | grep -o -E "${POSTGRES_DB}_[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}_[0-9]{2}.sql" \
    | sort -r \
    | tail -n +${KEEP_LAST_N_DUMPS} \
)

echo "cleaning up, but keeping last ${KEEP_LAST_N_DUMPS} dumps..."
for elem in $OLD_FILES;
do
    if [ "$elem" != "${POSTGRES_DB}_${DATE}.sql" ]; then
        echo "deleting old dump $elem."
        curl --silent -u ${SFTP_USER}:${_SFTP_PASSWORD} -k sftp://${SFTP_TARGET} -Q "rm ${SFTP_BASE_PATH}/$elem" > /dev/null
    fi
done

echo "files in dump path:"
curl --silent -u ${SFTP_USER}:${_SFTP_PASSWORD} -k "sftp://${SFTP_TARGET}:${SFTP_BASE_PATH}/"

echo "done."