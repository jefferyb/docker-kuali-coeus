#!/bin/bash

# Settings
CURRENT_WORKING_DIR=$(pwd)

KC_DB_USERNAME="kcusername"
KC_DB_PASSWORD="kcpassword"
KC_DB_NAME="kualicoeusdb"

KC_PROJECT_LINK="https://github.com/kuali/kc.git"
MYSQL_SQL_FILES_FOLDER="${CURRENT_WORKING_DIR}/kc/coeus-db/coeus-db-sql/src/main/resources/co/kuali/coeus/data/migration/sql/mysql"

# FUNCTIONS
function fix_some_sql_database_scripts {
	sed -i -e '/---------------/d' ${MYSQL_SQL_FILES_FOLDER}/kc/bootstrap/V602_010__RESKC-204.sql
	
}

function exec_sql_scripts() {
	echo
	git clone ${KC_PROJECT_LINK}
	fix_some_sql_database_scripts
	cd ${MYSQL_SQL_FILES_FOLDER}
	INSTALL_SQL_VERSION=( $(ls -v *.sql | grep -v INSTALL_TEMPLATE | sed 's/_.*//g' | uniq ) )
	for version in ${INSTALL_SQL_VERSION[@]:${1}}
	do
		# INSTALL THE MYSQL FILES
		echo "Installing/upgrading to version ${version}"
		if [ -f ${version}_mysql_rice_server_upgrade.sql ]; then
			mysql -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} ${KC_DB_NAME} < ${version}_mysql_rice_server_upgrade.sql > ${CURRENT_WORKING_DIR}/SQL_LOGS/${version}_MYSQL_RICE_SERVER_UPGRADE.log 2>&1
		fi
		if [ -f ${version}_mysql_rice_client_upgrade.sql ]; then
			mysql -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} ${KC_DB_NAME} < ${version}_mysql_rice_client_upgrade.sql > ${CURRENT_WORKING_DIR}/SQL_LOGS/${version}_MYSQL_RICE_CLIENT_UPGRADE.log 2>&1
		fi
		if [ -f ${version}_mysql_kc_rice_server_upgrade.sql ]; then
			mysql -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} ${KC_DB_NAME} < ${version}_mysql_kc_rice_server_upgrade.sql > ${CURRENT_WORKING_DIR}/SQL_LOGS/${version}_MYSQL_KC_RICE_SERVER_UPGRADE.log 2>&1
		fi
		if [ -f ${version}_mysql_kc_upgrade.sql ]; then
			mysql -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} ${KC_DB_NAME} < ${version}_mysql_kc_upgrade.sql > ${CURRENT_WORKING_DIR}/SQL_LOGS/${version}_MYSQL_KC_UPGRADE.log 2>&1
		fi
		# INSTALL THE DEMO FILES
		# 		if [ -f ${version}_mysql_rice_demo.sql ]; then
		# 			mysql -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} ${KC_DB_NAME} < ${version}_mysql_rice_demo.sql > ${CURRENT_WORKING_DIR}/SQL_LOGS/${version}_MYSQL_RICE_DEMO.log 2>&1
		# 		fi
		# 		if [ -f ${version}_mysql_kc_demo.sql ]; then
		# 			mysql -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} ${KC_DB_NAME} < ${version}_mysql_kc_demo.sql > ${CURRENT_WORKING_DIR}/SQL_LOGS/${version}_MYSQL_KC_DEMO.log 2>&1
		# 		fi
	done
	# THIS IS TO FIX THE "JASPER_REPORTS_ENABLED" ISSUE BECAUSE THIS SCRIPT DIDN'T RUN IN VERSION 1506
	if [ $(mysql -N -s -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} -D ${KC_DB_NAME} -e "select VAL from KRCR_PARM_T where PARM_NM='JASPER_REPORTS_ENABLED';" | wc -l) -eq 0 ]; then
		mysql -u${KC_DB_USERNAME} -p${KC_DB_PASSWORD} ${KC_DB_NAME} < grm/V602_011__jasper_feature_flag.sql > ${CURRENT_WORKING_DIR}/SQL_LOGS/V602_011__JASPER_FEATURE_FLAG.log 2>&1
	fi
	sleep 2
}

# Check for errors
function check_sql_errors {
	mkdir -p ${CURRENT_WORKING_DIR}/SQL_LOGS
	cp ${CURRENT_WORKING_DIR}/get_*_errors ${CURRENT_WORKING_DIR}/SQL_LOGS
	cd ${CURRENT_WORKING_DIR}/SQL_LOGS
	chmod +x get_*_errors
	./get_mysql_errors
	grep ERROR ${CURRENT_WORKING_DIR}/SQL_LOGS/UPGRADE_ERRORS*

	if [ $? -eq 0 ]; then
		echo
		echo "There were some errors during the install/upgrade. Check ${CURRENT_WORKING_DIR}/SQL_LOGS to make sure"
		sleep 2
		echo "Your database has NOT been upgraded correctly"
	else
		echo
		echo "There were no errors during the install/upgrade. Check ${CURRENT_WORKING_DIR}/SQL_LOGS to make sure"
		sleep 2
		echo "Your database has been upgraded"
	fi
	echo
}

function setup_kuali_database {
	mkdir -p ${CURRENT_WORKING_DIR}/SQL_LOGS
	# Run the SQL Scripts
	exec_sql_scripts
	# Check for errors
	check_sql_errors
}

# Run the Kuali SQL files 
setup_kuali_database

