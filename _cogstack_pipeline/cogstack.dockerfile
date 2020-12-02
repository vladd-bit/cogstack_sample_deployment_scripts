FROM base_image_debian_dev:latest

RUN wget "https://github.com/CogStack/CogStack-Pipeline/archive/1.3.1.zip"
RUN unzip "./1.3.1.zip" 
RUN mv "./CogStack-Pipeline-1.3.1" "./cogstack-repo-build"

RUN rm "./1.3.1.zip"

WORKDIR /cogstack-repo-build

RUN ./gradlew --version
RUN ./gradlew bootJar --no-daemon

# Make new directory for cogstack-pipeline binaries
RUN mkdir /cogstack-pipeline

RUN ls
RUN ls ./build/libs/
# copy artifacts
RUN cp ./build/libs/cogstack-*.jar /cogstack-pipeline
RUN cp ./scripts/*.sh /cogstack-pipeline

# copy external tools configuration files
RUN cp ./extras/ImageMagick/policy.xml /etc/ImageMagick-6/policy.xml

WORKDIR /cogstack-pipeline

RUN touch cogstack_job_config

# Remove cogstack-pipeline build dir
RUN rm -rf /cogstack-repo-build

# entry point
CMD /bin/bash