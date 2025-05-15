FROM debian:bookworm-slim

LABEL maintainer="Hossam Hammady <github@hammady.net>"

# Install dependencies including ca-certificates
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      libgd-gd2-perl libgd-text-perl \
      libdbd-mysql-perl libdbi-perl \
      libconfig-yaml-perl \
      make gcc g++ \
      unzip \
      curl \
      ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Zopfli
RUN update-ca-certificates && \
    curl -L -o /tmp/zopfli.zip https://github.com/google/zopfli/archive/master.zip && \
    unzip /tmp/zopfli.zip -d /tmp && \
    make -C /tmp/zopfli-master zopflipng && \
    cp /tmp/zopfli-master/zopflipng /usr/local/bin/ && \
    rm -rf /tmp/zopfli*

WORKDIR /app

# Install Mojolicious
RUN curl -L https://cpanmin.us | perl - -M https://cpan.metacpan.org -n Mojolicious

# Copy application files
COPY config /app/config
COPY lib /app/lib
COPY res /app/res
COPY script /app/script
COPY Makefile.PL /app/Makefile.PL

# Build and install the application
RUN cd /app && \
    perl Makefile.PL && \
    make && \
    make install

# Update database configuration
RUN sed -i 's/localhost/mysql/' /app/config/database.yaml

CMD ["/app/script/generate.pl", "help"]