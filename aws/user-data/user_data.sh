#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1


# Configure cloudwatch
cat <<'EOF' >>/opt/aws/amazon-cloudwatch-agent/bin/keycloak-config.json
${cloudwatch_config}
EOF

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/keycloak-config.json -s

/opt/keycloak/bin/add-user-keycloak.sh -u admin -p ${keycloak_admin_password}


export PRIVATE_IP="$(curl http://169.254.169.254/latest/meta-data/local-ipv4)"
export DB_ADDR=${keycloak_db_address}
export DB_USER=${keycloak_db_user}
export DB_PASSWORD=${keycloak_db_password}
export DB_DATABASE=keycloak
export S3_PING_BUCKET=${keycloak_ping_bucket}
export AWS_ACCESS_KEY=${aws_access_key}
export AWS_SECRET=${aws_secret_key}
export KEYCLOAK_CLUSTER_NAME=${keycloak_cluster_name}
/opt/keycloak/bin/standalone.sh -c=standalone-ha.xml  -b=0.0.0.0