FROM ubuntu
LABEL maintainer="Eduardo.Oliveira"
#Instalar dependencias
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y tzdata \
    && apt-get install python -y \   
    && apt-get install apache2 -y \
    && apt-get install curl -y \
    && apt-get install unzip -y \
    && curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
    && apt-get clean all 

#Credencial
RUN cd /root && mkdir .aws 
COPY credentials /root/.aws/

#ALterar mensagem
RUN aws s3 ls --profile lorente > /var/www/html/index.html
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

#Iniciar apache
RUN echo 'service apache2 start' > /root/iniciar-apache2.sh \
    && chmod 755 /root/iniciar-apache2.sh \
    && /root/./iniciar-apache2.sh
 
#Expor a porta
EXPOSE 80

WORKDIR /root

ENTRYPOINT ["/usr/sbin/apache2ctl","-D","FOREGROUND"]