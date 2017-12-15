#!/bin/sh

set -e

### WWW ###

WWW_DIR=/var/www

mkdir -p $WWW_DIR

# Set up skeleton of plugin repo, to be overlaid with httpd-data volume

for subdir in 'qgis' 'qgis-dev' 'qgis-beta'; do
  mkdir -p $WWW_DIR/$subdir/plugins/packages
  mkdir -p $WWW_DIR/$subdir/.well-known
  mkdir -p $WWW_DIR/$subdir/plugins/packages-auth
  touch $WWW_DIR/$subdir/index.html
  touch $WWW_DIR/$subdir/plugins/index.html
  ln -sf plugins/plugins.xml $WWW_DIR/$subdir/plugins.xml
done

chmod -R 0755 $WWW_DIR
chown -R ${SSH_USER}:users $WWW_DIR

### Repo update script ###

REPO_UPDATER=/opt/repo-updater
PLUGINS_XML=$REPO_UPDATER/plugins-xml
UPDATE_SCRIPT=$PLUGINS_XML/plugins-xml.py
UPDATE_WRAPPER=$PLUGINS_XML/plugins-xml.sh
SETTINGS_FILE=$PLUGINS_XML/settings.py
PY_VENV=/opt/venv

mkdir -p $REPO_UPDATER/uploads

mv /opt/setup/plugins-xml $PLUGINS_XML

# Save the settings in /opt/repo-updater/plugins-xml/settings.py
# overwrite existing settings.py
echo "# This file was auto-generated by setup-repo.sh" > ${SETTINGS_FILE}
echo "" >> ${SETTINGS_FILE}
echo "conf = {" >> ${SETTINGS_FILE}
echo "  'WEB_BASE': '${WWW_DIR}'," >> ${SETTINGS_FILE}
echo "  'UPLOAD_BASE': '${REPO_UPDATER}'," >> ${SETTINGS_FILE}
echo "  'UPLOADED_BY': '${UPLOADED_BY}'," >> ${SETTINGS_FILE}
echo "  'DOMAIN_TLD': '${DOMAIN_TLD}'," >> ${SETTINGS_FILE}
echo "  'DOMAIN_TLD_DEV': '${DOMAIN_TLD_DEV}'," >> ${SETTINGS_FILE}
echo "  'DOMAIN_TLD_BETA': '${DOMAIN_TLD_BETA}'," >> ${SETTINGS_FILE}
echo "}">> ${SETTINGS_FILE}


sed -i "s@venv@${PY_VENV}@g" ${UPDATE_WRAPPER}

chown -R ${SSH_USER}:users $REPO_UPDATER


### Copy flask app main.py ###
FLASK_APP_FOLDER=$PLUGINS_XML/flask_app
cp $FLASK_APP_FOLDER/main.py $WWW_DIR

chown ${SSH_USER}:users $WWW_DIR/main.py
