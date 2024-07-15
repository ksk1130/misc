aws redshift create-cluster \
--db-name dev \
--cluster-identifier redshift-cluster-1 \
--cluster-type single-node \
--node-type dc2.large \
--master-username awsuser \
--master-user-password Awsuser0! \
--port 5439 \
--cluster-parameter-group-name default.redshift-1.0 \
--cluster-subnet-group-name cluster-subnet-group-1 \
--enhanced-vpc-routing \
--availability-zone ap-northeast-1c \
--no-publicly-accessible \
--vpc-security-group-ids sg-0b59b0e12f4129096 \
--iam-roles arn:aws:iam::999999999999:role/RedshiftSpectrumRole

