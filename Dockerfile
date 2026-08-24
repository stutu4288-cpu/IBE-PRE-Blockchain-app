# Use Tomcat 9 with JDK 17 (Fixes Linux Cgroup v2 NullPointerException)
FROM tomcat:9.0-jdk17-openjdk-slim

# Remove default ROOT application
RUN rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/ROOT.war

# Copy compiled WAR package to ROOT.war for root path deployment
COPY dist/Proxy_Re_Encryption_Approach_to_Secure_Data_Sharing.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 and set PORT env variable for Railway healthcheck
EXPOSE 8080
ENV PORT=8080

# Start Tomcat server
CMD ["catalina.sh", "run"]
