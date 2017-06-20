# Webserver container with CGI python script
# Using RHEL 7 base image and Apache Web server
# Version 1

# Pull the rhel image from the local repository
FROM rhel7:latest

MAINTAINER LINDY TENG

# Label
LABEL io.openshift.expose-services="8080:http" \
        io.openshift.tags="builder,html,httpd"

# Create /web filesystem
RUN mkdir -p /web/httpd/logs
VOLUME ["/web"]

# Add httpd package and mod_ssl
RUN yum install -y httpd mod_ssl && \
    # clean yum cache files, as they are not needed and will only make the image bigger in the end
    yum clean all -y

# Defines the location of the S2I
# Although this is defined in openshift/base-centos7 image it's repeated here
# to make it clear why the following COPY operation is happening
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i
# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY ./.s2i/bin/ /usr/local/s2i

# Copy the httpd configuration file
COPY ./etc/ /opt/app-root/etc

# Drop the root user and make the content of /opt/app-root owned by user 1001
RUN chown -R 1001:1001 /opt/app-root

# Set the default user for the image, the user itself was created in the base image
USER 1001

# Specify the ports the final image will expose
EXPOSE 80

# Softlink the log to /web/httpd/logs
#RUN rm -rf /var/log/httpd
#RUN umask 000; ln -s /web/httpd/logs /var/log/httpd; umask 022
#RUN rm -rf /etc/httpd/logs
#RUN umask 000; ln -s /web/httpd/logs /etc/httpd/logs; umask 022

# Create an index.html file
RUN echo "The Web Server is Running!" >> /var/www/html/index.html

# Start the service
CMD ["/usr/libexec/s2i/usage"]
