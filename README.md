# second-assignment-2024
**CORE:**

The idea is to build an adaptive sensor network which is aware of a new node coming into the network. Each new network must contain at least two MCUs, which can be a NodeMCU and/or MKR. Use the first assignment as a starting point. The idea is that one node of the network may act as the master node and the others as the slave node. The master node is already registered in the sensor network while the slave is to be dynamically added to the sensor network. The sensor network communications should be handled by using MQTT. The master node may act as the root user of the sensor network: it may collect the messages coming from all the nodes in the network (in this case one) and it may log these messages on a suitable database (MySQL or InfluxDB).


**ADD-ONS**

Set up a remote control of the monitoring system (start, stop, etc.) through a web page. All the sensed values and alerting events values must be shown. Sensors need to communicate alerts based on Web of Things technologies such as REST HTTP, JSON or MQTT. 

**INGREDIENTS:**

- Micros of your choice, suggested: NodeMCU and MKR1000
- Sensors or actuators of your choice.

**EXPECTED DELIVERABLES:**

- Github code upload at:
- Powerpoint presentation of 10 mins (5 mins per person)
