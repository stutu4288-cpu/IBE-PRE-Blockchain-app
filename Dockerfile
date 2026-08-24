FROM tomcat:9.0-jdk17

# Explicitly disable cgroup container metrics inspection to guarantee 100% startup compatibility across all cloud kernels
ENV JAVA_OPTS="-XX:-UseContainerSupport -Djava.awt.headless=true"

# Remove default ROOT application
RUN rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/ROOT.war

# Copy compiled WAR package to ROOT.war for root path deployment
COPY dist/Proxy_Re_Encryption_Approach_to_Secure_Data_Sharing.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
ENV PORT=8080

CMD ["catalina.sh", "run"]
