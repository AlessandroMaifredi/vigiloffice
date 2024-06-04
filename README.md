# VIGILOFFICE

The project deals with the management of an office environment in terms of lighting and ventilation.
It also allows for the management of anti-intrusion alarms or the exceeding of thresholds for certain variables.

The project is divided into three folders, one for each node. The nodes are: **lampNode** and **hvacNode** (slave nodes) and **masterNode**.

The nodes communicate via MQTT through a system of auto-discovery and handshaking.

The master node exposes a web server to manage all the devices.