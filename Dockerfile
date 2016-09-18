FROM ubuntu:14.04

# install nodejs 4.x
RUN apt-get update && apt-get install -yqq curl && \
  curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - && \
  apt-get install -y nodejs && \
  rm -rf /etc/apt/sources.list.d/*

#install git

RUN apt-get update && apt-get install -yqq wget libcurl4-gnutls-dev \
  libexpat1-dev gettext libz-dev libssl-dev autoconf make && \
  wget https://codeload.github.com/git/git/tar.gz/v2.9.3 && \
  tar -zxf v2.9.3 && \
  cd git-2.9.3 && \
  make configure && \
  ./configure --prefix=/usr && \
  make all && \
  make install && \
  rm -rf ../v2.9.3 ../git-2.9.3
  
# install chromium and xvfd

RUN apt-get update && apt-get install -y xvfb chromium-browser \
  openjdk-7-jre-headless \
  fonts-ipafont-gothic \
  xfonts-100dpi \
  xfonts-75dpi \
  xfonts-cyrillic \
  xfonts-scalable \
  && rm -rf /var/lib/apt/lists/*

ADD xvfb.sh /etc/init.d/xvfb
ADD entrypoint.sh /entrypoint.sh

# following command may not work, which means envirement may not exist, please use proper command replace
ENV DISPLAY :99.0
ENV CHROME_BIN=/usr/bin/chromium-browser

RUN chmod a+x /etc/init.d/xvfb
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# for jenkins
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
  

  