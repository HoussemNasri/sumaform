{% if grains.get('monitored', false) %}

include:
  - suse_manager_server

node_exporter:
  pkg.installed:
    - name: golang-github-prometheus-node_exporter
    - require:
      - sls: suse_manager_server

node_exporter_service:
  file.managed:
    - name: /etc/systemd/system/node-exporter.service
    - contents: |
        [Unit]
        Description=node_exporter

        [Service]
        ExecStart=/usr/bin/node_exporter

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: node_exporter
  service.running:
    - name: node-exporter
    - enable: True
    - require:
      - file: node_exporter_service

postgres_exporter:
  pkg.installed:
    - name: golang-github-wrouesnel-postgres_exporter
    - require:
      - sls: suse_manager_server

postgres_exporter_service:
  file.managed:
    - name: /etc/systemd/system/postgres-exporter.service
    - contents: |
        [Unit]
        Description=postgres_exporter

        [Service]
        Environment=DATA_SOURCE_NAME=postgresql://spacewalk:spacewalk@localhost:5432/susemanager?sslmode=disable
        ExecStart=/usr/bin/postgres_exporter

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: node_exporter
  service.running:
    - name: postgres-exporter
    - enable: True
    - require:
      - file: postgres_exporter_service

jmx_exporter:
  pkg.installed:
    - name: jmx_exporter
    - require:
      - sls: suse_manager_server

jmx_exporter_configuration:
  file.managed:
    - name: /etc/jmx_exporter/jmx_exporter.yml
    - makedirs: True
    - contents: |
        hostPort: localhost:5555
        username:
        password:

        rules:
        - pattern: ".*"

jmx_exporter_service:
  file.managed:
    - name: /etc/systemd/system/jmx-exporter.service
    - contents: |
        [Unit]
        Description=jmx_exporter

        [Service]
        ExecStart=/usr/bin/java -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.port=5555 -jar /usr/share/java/jmx_prometheus_httpserver.jar 5556 /etc/jmx_exporter/jmx_exporter.yml

        [Install]
        WantedBy=multi-user.target
    - require:
      - pkg: jmx_exporter
  service.running:
    - name: jmx-exporter
    - enable: True
    - require:
      - file: jmx_exporter_service
      - file: jmx_exporter_configuration

{% endif %}
