FROM ubuntu:latest
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ARG ngrokid
ARG Password
ENV Password=${Password}
ENV ngrokid=${ngrokid}
RUN apt install ssh wget unzip -y > /dev/null 2>&1
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip
RUN wget -O frp.tar.gz https://github.com/fatedier/frp/releases/download/v0.48.0/frp_0.48.0_linux_amd64.tar.gz
RUN tar -xvf frp.tar.gz --strip-components=1
RUN echo "[common]" > frpc.ini
RUN echo "server_addr = frp.freefrp.net" >> frpc.ini
RUN echo "server_port = 7000" >> frpc.ini
RUN echo "token = freefrp.net" >> frpc.ini
RUN echo  >> frpc.ini
RUN echo "[gxssh]" >> frpc.ini
RUN echo "type = tcp" >> frpc.ini
RUN echo "local_port = 22" >> frpc.ini
RUN echo "remote_port = 28122" >> frpc.ini
RUN echo "./frpc &" >>/2.sh
RUN chmod 755 /2.sh
RUN echo "./ngrok config add-authtoken ${ngrokid} &&" >>/1.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/1.sh
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/1.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:${Password}|chpasswd
RUN service ssh start
RUN chmod 755 /1.sh
RUN echo "bash /2.sh" >>/3.sh
RUN echo "bash /1.sh" >>/3.sh
RUN chmod 755 /3.sh
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306
CMD  /2.sh
