# ------ BUILDER ------
FROM registry.access.redhat.com/ubi8:8.8-854 as builder

# API URL which will be handed down to the flutter web
# app at build time - if we need to provide it at a later
# stage (for example container has already been build), we
# can provide a ConfigMap / PersistantVolume with a file
# called config at assets/env/ contianing those args
ARG API_URL

# System setup
RUN dnf upgrade --refresh -y && \
    dnf install git -y && \
    dnf install unzip -y

# Set the working directory
WORKDIR /src

# Copy all files over to the workdir of the build process
COPY . .

# Used for the flutter configs (will otherwise be created by
# the SDK)
RUN mkdir /.config && \
    mkdir /.pub-cache && \
    mkdir /.dart-tool

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
RUN git config --system --add safe.directory /usr/local/flutter
ENV PATH="$PATH:/usr/local/flutter/bin"

# Adjust permission to allow non-root user
RUN chgrp -R 0 /src && \
    chmod -R g=u /src && \
    chgrp -R 0 /.config && \
    chmod -R g=u /.config && \
    chgrp -R 0 /.pub-cache && \
    chmod -R g=u /.pub-cache && \
    chgrp -R 0 /.dart-tool && \
    chmod -R g=u /.dart-tool && \
    chgrp -R 0 /usr/local/flutter && \
    chmod -R g=u /usr/local/flutter


USER 1000

# Set flutter to not use dev analytics
RUN flutter config --no-analytics

# Switch to stable branch and upgrade
RUN flutter channel stable
RUN flutter upgrade

# Get all flutter dependencies
RUN flutter pub get

# Build static web files (always canvaskit renderer)
RUN flutter build web --web-renderer canvaskit --dart-define API_URL=${API_URL}

# ------ RUNNER ------
FROM registry.access.redhat.com/ubi8/nginx-120:1-106

# Copy static files to folder where nginx will serve them
COPY --from=builder /src/build/web .

# Change group and access rights so these folders / executables can
# be used as non root for security reasons
# RUN chgrp -R 0 /var/cache/nginx && \
#     chmod -R g=u /var/cache/nginx

# RUN chgrp -R 0 /etc/nginx/conf.d && \
#     chmod -R g=u /etc/nginx/conf.d

# Change user to non root
USER 1000

CMD nginx -g "daemon off;"