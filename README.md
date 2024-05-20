# VIGILOFFICE

Use-case: Ufficio con gestione dell'ambiente di lavoro + parcheggio


Tutti i nodi usano autoconnect per attaccarsi a internet 
Quando un nodo slave si connette scrive sul topic /welcome per condividere la sua esistenza indicando quali funzionalità possiede.


## Master:
	- 1 lcd
	- 1 rtc
	- 1 buzzer
	- (1 led)
 - Espone il web server
 - gestisce gli allarmi (accensione/spegnimento - scheduling) {EVENTUALLY: notifiche tramite medium da decidere (mail)}
 - mostra i dati su LCD
 - led per mostrare funzionamento??
 

## Slaves:

### Lampadina:
	- Sensore di movimento
	- Sensore di luce
	- Led rgb
	- Sensore di fiamma?	

	### Ventilazione intelligente:
	- Temp/hum
	- Ventola (simulazione)
	- Ricevitore IR?

### ??Parcheggio??
	- Sensore di prossimità / avoidance
	- Sensore di fiamma
	- LED per occupazione del posteggio
	- Sensore di allagamento
	- Buzzer per allarme vicinanza


## MQTT
	Vigiloffice
			/welcome - per messaggio di presentazione dei nodi slave {nome,funzioni,topic su cui scrivere/ascoltare,lwt}
			/lampadina - per tutti i sensori di tipo lampadina
				/"mac-address"
					/status
						/mvmt
						/light
						/led
						/flame
					/control
						/mvmt
						/light
						/led
						/flame
				/Ventilazione - per tutti i sensori di tipo ventilazione
				/"mac-address"
					/status
						/temp
						/hum
						/fan
						/ir
					/control
						/temp
						/hum
						/fan
						/ir

## WEBSERVER
	/api/sensors/lampadina/
	/sensors/lampadina
