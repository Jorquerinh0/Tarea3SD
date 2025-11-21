# Usamos una imagen base que ya sabe cómo hablar con Hadoop
FROM bde2020/hadoop-base:2.0.0-hadoop3.2.1-java8

# Variables para la versión de Pig
ENV PIG_VERSION=0.17.0
ENV PIG_HOME=/opt/pig
ENV PATH=$PIG_HOME/bin:$PATH

# Arreglo para los repositorios de Debian "Stretch" (Necesario porque es una distro antigua)
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list

# Copiamos el archivo de Pig que tienes en tu carpeta local
COPY pig-${PIG_VERSION}.tar.gz /

# Instalamos tar, descomprimimos y movemos (Todo en una sola instrucción RUN para evitar capas extra)
RUN apt-get update && \
    apt-get install -y tar && \
    tar -xzf /pig-${PIG_VERSION}.tar.gz && \
    mv pig-${PIG_VERSION} ${PIG_HOME} && \
    rm /pig-${PIG_VERSION}.tar.gz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Establecer el directorio de trabajo
WORKDIR /

# Crear el directorio /data donde montaremos nuestros archivos
RUN mkdir /data
