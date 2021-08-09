# Adjust maven memory settings
export MAVEN_OPTS="-Xmx1024m"

########
# OAuth
########
# Sample oauth generation with key and secret 
alias oauth-<env>='java -jar <path_of_jar>/auth-header-1.4.jar -k <key> -s <secret> -c'

