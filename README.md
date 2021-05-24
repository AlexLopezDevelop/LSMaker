# LSMaker APP Docs

# Introducción

Esta documentación se ha realizado con el fin de poder tener una base desde la que poder partir para saber el funcionamiento de la conexión entre la app iOS/Android y el LSMaker via Bluetooth

# Configuración

## Establecer conexión

Para poder conectarse al LSMaker via bluetooth se necesita usar una librería que gestione dicha comunicación, en el caso de iOS se usa CoreBluetooth que es la librería nativa de Apple y en el caso de Android se usa BluetoothGatt que también es la librería nativa de Google.

 

[Apple Developer Documentation](https://developer.apple.com/documentation/corebluetooth)

[](https://developer.android.com/reference/android/bluetooth/BluetoothGatt)

Una vez se disponga de una libraría bluetooth, para poder mantener la conexión entre la App y el LSMaker es necesario es saber los UUID para el envío de información. 

[UUID](https://www.notion.so/670b59fb4d7c4282bf37198fcac5acc5)

## Enviar información

Para un mejor entendimiento usaremos de ejemplo el código de iOS.

Usando la librería CoreBluetooth una vez se selecciona el dispositivo al que se quiere conectar, se ejecuta la función *didDiscoverServices* que es la encargada de buscar la característica/servicio a la que se quiere conectar.

```swift
func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            print("Service found with UUID: " + service.uuid.uuidString)

            //device information service
            if (service.uuid.uuidString == rxServiceUUID?.uuidString) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
```

Accedemos a todos los servicios que tiene el dispositivo *peripheral.services* y buscamos el que necesitemos en este caso sería el *rxServiceUUID*.

Una vez se encuentra el servicio llamamos a la función *discoverCharacteristics* que es la que se encarga de enviarle la información al LSMaker.

```swift
func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if (service.uuid.uuidString == rxServiceUUID?.uuidString) {
            if let characteristic = service.characteristics?.first(where: { (c) -> Bool in
                c.uuid.uuidString == rxCharUUID?.uuidString
            }) {

                lsmakerBluetooth.initialize(peripheral: peripheral, characteristic: characteristic)

                let lsMakerAcceleration: UInt8 = 0x15

                let queue = DispatchQueue(label: "lsmaker.control.thread")

                queue.async { [self] in
                    while connection {
                        lsmakerBluetooth.move(
                                speed: drivingDataManager.speed,
                                acceleration: lsMakerAcceleration,
                                turn: drivingDataManager.turn)
                        usleep(2000)
                    }
                }
            }
        }
    }
```

Como ya se ha dicho esta función sera la encargada de mantener la conexión y estar enviando la información al LSMaker. Para un mejor entendimiento iremos paso a paso que hace este código.

Primeramente volvemos a revisar qué es el servicio correcto. Posteriormente obtenemos el servicio para posteriormente usarlo.

```swift
if (service.uuid.uuidString == rxServiceUUID?.uuidString) {
            if let characteristic = service.characteristics?.first(where: { (c) -> Bool in
                c.uuid.uuidString == rxCharUUID?.uuidString
            })
```

Inicializamos el objeto quien se encargara de proporcionar los datos que se actualizan en cualquier otra vista de la app. 

```swift
lsmakerBluetooth.initialize(peripheral: peripheral, characteristic: characteristic)
```

```swift
class BluetoothService {
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?

    func initialize(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        self.peripheral = peripheral
        self.characteristic = characteristic
    }

    func move(speed: UInt8, acceleration: UInt8, turn: UInt8) {
        let value: [UInt8] = [
            0x00, // header
            0x00, // opcode
            speed, // speed
            acceleration, // acceleration
            turn // turn
        ]

        if let lsmakerCharacteristic = characteristic {
            peripheral?.writeValue(Data(value), for: lsmakerCharacteristic, type: .withoutResponse)
        }
    }
}
```

Cómo podemos ver en el ejemplo podríamos directamente enviarle los datos dentro de la función  pero paparte de ser una mala práctica. No podríamos actualizar el valor desde otra parte de la App, ya que siempre se enviaría el mismo valor. Aun así ayuda para poder probar de que se a realizado la conexión correctamente.

```swift
let lsMakerAcceleration: UInt8 = 0x15 //bad
```

Aqui simplemente creamos un hilo independiente al principal, que se encargue de mantener la conexión y estar enviando los datos, ya que en el caso de estar en el mismo hilo principal la app se quedaría parada hasta que acabe la conexión.

```swift
let queue = DispatchQueue(label: "lsmaker.control.thread")
	queue.async { [self] in
```

Este bucle es el encargado de constantemente enviarle datos al LSMaker, por lo que mientras haya conexión se estará ejecutando y enviara los valores de velocidad, aceleración y giro que tenga la clase lsmakerBluetooth en ese momento.

Importante poner un delay ya que si se envía tanta información el procesador del LSMaker se colapsa

```swift
while connection {
	lsmakerBluetooth.move(
	   speed: drivingDataManager.speed,
     acceleration: lsMakerAcceleration,
     turn: drivingDataManager.turn
	)
  usleep(2000)
}
```

## Parámetros a enviar

En este caso se han de enviar 3 parámetros para el movimiento:

[Movimiento](https://www.notion.so/92eb18f3c93b49c880d2ba437c72a976)

Para crear el byte, seria añadirle 0x al valor. 

Ejemplo: Si quiero una velocidad de 50 el valor a enviar seria: 0x50

Todos estos parámetros han de ir en un array a la hora de enviarlo con un header y opcode que por defecto son siempre 0x00:

```jsx
let valueToSend: [UInt8] = [
            0x00, // header
            0x00, // opcode
            speed, // Velocidad
            acceleration, // Aceleración 
            turn // Giro
        ]
```
