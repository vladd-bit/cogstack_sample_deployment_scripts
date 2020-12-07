FROM base_image_debian:latest

RUN wget "https://github.com/CogStack/CogStack-Pipeline/archive/master.zip" -O "./CogStack-Pipeline-master.zip"
RUN unzip -o "./CogStack-Pipeline-master.zip"
RUN mv "./CogStack-Pipeline-master" "./cogstack-repo-build"

WORKDIR /cogstack-repo-build

RUN ./gradlew --version
RUN ./gradlew bootJar --no-daemon

# Make new directory for cogstack-pipeline binaries
RUN mkdir /cogstack

# copy artifacts
RUN cp ./build/libs/cogstack-*.jar /cogstack
RUN cp ./scripts/*.sh /cogstack

# copy artifacts
RUN cp ./build/libs/cogstack-*.jar /cogstack
RUN cp ./scripts/*.sh /cogstack

# copy external tools configuration files
RUN cp ./extras/ImageMagick/policy.xml /etc/ImageMagick-6/policy.xml

WORKDIR /cogstack

# Remove cogstack-pipeline build dir
RUN rm -rf /cogstack-repo-build

# entry point
CMD /bin/bash