FROM openjdk:8-jdk-alpine
RUN cd / && mkdir target && chmod 777 -R /target
COPY  ./target/rest-service-0.0.1-SNAPSHOT.jar /target/
EXPOSE 3000
ENTRYPOINT ["java","-jar","/target/rest-service-0.0.1-SNAPSHOT.jar"]