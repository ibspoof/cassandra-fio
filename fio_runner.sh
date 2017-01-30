#!/bin/sh

## Helper script to run fio tests and generate reports

DATA_DIR=./data
LOG_DIR=./logs
REPORT_DIR=./reports

# check if fio is installed
if ! type "fio" > /dev/null; then
    echo "ERROR: fio is not installed. Exiting"
    exit 1
fi

case $1 in
    64k)
        echo 'Only running 64k fio tests...'
        LS_CMD="*64k.fio"
        ;;
    32k)
        echo 'Only running 32k fio tests...'
        LS_CMD="*32k.fio"
        ;;
    stcs)
        echo 'Only running STCS fio tests...'
        LS_CMD="stcs*.fio"
        ;;
    lcs)
        echo 'Only running LCS fio tests...'
        LS_CMD="lcs*.fio"
        ;;
    all)
        echo 'Running all *.fio tests...'
        LS_CMD="*.fio"
        ;;
    *)
        echo "Running all *.fio tests..."
        LS_CMD="*.fio"
esac

FIO_BIN=fio
if [ "${2}x" != "x" ]; then
    FIO_BIN=${2}
fi

FIOS_LIST=$(ls ${LS_CMD})
NOW_EPOCH=$(date +"%s")
LOG_DIR_READS=${LOG_DIR}/reads
LOG_DIR_WRITES=${LOG_DIR}/writes

# create required directories
mkdir -p ${DATA_DIR}

if [ -d "${REPORT_DIR}" ]; then
    echo "Report directory exists, archiving using current timestamp: ${NOW_EPOCH}"
    mv ${REPORT_DIR} ${REPORT_DIR}_${NOW_EPOCH}
fi
mkdir -p ${REPORT_DIR}

if [ -d "${LOG_DIR}" ]; then
    echo "Log directory exists, archiving using current timestamp: ${NOW_EPOCH}"
    mv ${LOG_DIR} ${LOG_DIR}_${NOW_EPOCH}
fi
mkdir -p ${LOG_DIR_WRITES}
mkdir -p ${LOG_DIR_READS}

# run all fios in sequential order
for i in $(echo ${FIOS_LIST} | tr " " "\n")
do
    echo "\nStarting fio test ${i}..."
    ${FIO_BIN} ./${i} --output ${REPORT_DIR}/${i}.out

    mv *read*.log ${LOG_DIR_READS}/
    mv *write*.log ${LOG_DIR_WRITES}/

    rm -f data/*   # delete created fio files after each run

    echo "Completed fio test ${i}."
done

# plot reports to svg
if type "fio_generate_plots" > /dev/null; then

    echo "fio_generate_plots is installed generating svg reports based on fio logs"

    ( cd ${LOG_DIR_READS} && fio_generate_plots "All-Reads" )
    ( cd ${LOG_DIR_WRITES} && fio_generate_plots "All-Writes" )

    mv ${LOG_DIR_READS}/*.svg ${REPORT_DIR}/
    mv ${LOG_DIR_WRITES}/*.svg ${REPORT_DIR}/
fi
