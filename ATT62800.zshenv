# Adjust maven memory settings
export MAVEN_OPTS="-Xmx1024m"

# Checkout Third.properties files from git
alias third='git checkout *THIRD*'

########
# OAuth
########
# Registries Dev
alias oauth-dev='java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k db2b285e-02e6-43db-b2ae-361aba8da88f -s uxwVsNBEChEh37J1YHSH02duJ19Pq45T -c'

# Registries Staging
alias oauth-staging='java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k d911f1bb-11a6-4080-bd30-3f68e13c1b7b -s z-XWO0nFlXBVFoFfLVdEncNDSUbIEHUv -c -p https://api.sandboxcernercare.com/oauth/access'

# Registries Prod
alias oauth-prod="java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k d29a8822-cf68-4654-85fe-37f4c9816c55 -s prYuQhuuBw68uLIFsKNwUbHYrGHsjIk_ -p https://api.cernercare.com/oauth/access -c"

# Programs Staging
alias programs-oauth-staging='java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k db1e10e3-2eb8-4e58-89a8-8a7b4a49e791 -s _WtZ2yK9jL6UBUeNgpqkVDUWkgZYFxLa -c -p https://api.sandboxcernercare.com/oauth/access'

# Programs Development
alias programs-oauth-dev='java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k 165ab3dd-d743-4224-b48e-132e73b6ccd4 -s Jr52mWiW4T8PiA8PfYpuiYxIjuW59eMX -c -p https://api.devcernercare.com/oauth/access'

# Programs local
alias programs-oauth-local='java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k 296f2007-4fb1-400a-a1e5-cef8a4dcf53d -s 0Mvl1zIMX2b7J-9RM5CRE1B0LRUsI8Hl -c -p https://api.devcernercare.com/oauth/access'

# Programs prod
alias programs-oauth-prod="java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k 6c786918-78c3-4ace-96d9-b0468485bb8e -s uYn1g38VVIYWbQx4BPh3B7zdHqKDmWe7 -p https://api.cernercare.com/oauth/access -c"

# Associate authorization service staging
alias assoc-auth-service-oauth-staging='java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k 460cfd03-b6be-460b-833c-5aba231f296f -s aC-caWrULG0hj_Nrg1wgmwbyynaNUb4d -c -p https://api.sandboxcernercare.com/oauth/access'

# Associate authorization service dev
alias assoc-auth-service-oauth-dev='java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k 25797696-6d98-4954-bbeb-b7fab9e101e4 -s V7bYk9W0DM7_LHoYsXsZXb6Z14J8jmyq -c -p https://api.devcernercare.com/oauth/access'

# Document reference service staging
alias doc-ref-oauth-staging="java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k 43879730-9aa0-4008-8fbf-154e0f0001d0 -s M_-kz-X8u3BT90tAhF2cSf-rsutDY64A -c -p https://api.sandboxcernercare.com/oauth/access"

# Document reference service dev
alias doc-ref-oauth-dev="java -jar /Users/lg070675/Downloads/auth-header-1.4.jar -k 328bb642-123a-4329-bacf-1d02243089d5 -s m5790WZl6OWYMV4tm5x5W8Hci4QaWLWC -c"
