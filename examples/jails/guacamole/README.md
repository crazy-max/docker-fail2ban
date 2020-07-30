## Guacamole

Create the logback configuration in `./config/guacamole/logback.xml` :

```
<configuration>
        <!-- Appender for debugging -->
        <appender name="GUAC-DEBUG" class="ch.qos.logback.core.ConsoleAppender">
                <encoder>
                        <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
                </encoder>
        </appender>
        <!-- Appender for debugging in a file-->
        <appender name="GUAC-DEBUG_FILE" class="ch.qos.logback.core.FileAppender">
                <file>/usr/local/tomcat/logs/guacd.log</file>
                <encoder>
                        <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n</pattern>
                </encoder>
        </appender>
        <!-- Log at DEBUG level -->
        <root level="debug">
                <appender-ref ref="GUAC-DEBUG"/>
                <appender-ref ref="GUAC-DEBUG_FILE"/>
        </root>
</configuration>
```

Create this compose file for guacamole :

```
version: "2"

services:
  guacamole:
    image: oznu/guacamole
    volumes:
      - ./config:/config
      - /var/log/guacamole:/usr/local/tomcat/logs
    ports:
      - 8080:8080
```

Guacamole will write logs into `/usr/local/tomcat/logs` and bind the folder to `/var/log/guacamole` on the host.

## Fail2ban container

* Copy files from [filter.d](filter.d) and [jail.d](jail.d) to `./data` in their respective folders.
