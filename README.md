# Configuración de Ubuntu Server como Router

## Autor

- [q3it](https://www.blogger.com/profile/16118326082555553765)

## Resumen

Es posible que no seas consciente de que tu máquina Ubuntu puede ser algo más que una computadora personal; también puede funcionar como un potente `router`. Ya sea que necesite compartir una conexión a Internet, gestionar el tráfico entre diferentes redes o implementar funciones avanzadas de enrutado. Antes de que entremos en la configuración, vamos a entender brevemente el enrutado. El `Routing` es el proceso de dirigir el tráfico de la red entre diferentes redes o subredes. Un `router` es un dispositivo que conecta múltiples redes y rutas de datos entre ellas. Su máquina Ubuntu puede servir como router aprovechando sus interfaces de red y configurando tablas de rutas.

En las [referencias](#referencias), encontrará enlaces a sitios de `Internet` que pueden ayudar.

## Escenario

<p align="center">
<img src="/img/Screen.png">
</p>

Se crearán dos máquinas virtuales: Una con Ubuntu server que nos servirá como router linux y, otra con Debian que será el cliente. En el diagrama de red tendrémos una idea de como se van a comunicar las máquinas.

Debian estará en una red interna que se conectará a Ubuntu Server y para ello Debian tendrá un adaptador de red sin conexión a internet. Ubuntu Server por su lado se le configurará un adaptador como red interna y otro que hará de router para tener acceso a internet.

## Administración del servidor

El servidor `Ubuntu` utilizá los siguientes parámetros de configuración de red:

* Dirección `IP` del servidor con conexión wan: `192.168.210.145`
* Dirección `IP` del servidor con conexión lan: `192.168.277.134`
* Puerta de enlace del servidor: `192.168.277.1`
* Red interna: `192.168.277.0/24`
* Red externa: `192.168.210.0/24`

### Ajustes de los parámetros de red Debian

[Debian](https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhTqECpqbbyS1RKFglOBmRjqbWk5ezZwjN66GNOBcbunTNNUmmxDECOeU-VoJCQDHO2I7-ZpVOBaqi7LJAJbCnpuTWT7uQ3Yc-GCdwu38oetqohQSdBBGQV7Z2RD8ItLYKpRoeDUBtSAPWWZXb1kwu2xoFxKKh3FsVyg5dswMTECNw7Akh3ITgOIyN4wRs/s795/Selecci%C3%B3n_001.png)

### Ajustes de los parámetros de red Ubuntu Server

```ruby
nano /etc/netplan/50-cloud-init.yaml

network:
    ethernets:
        ens160:
            dhcp4: true
        ens256:
            dhcp4: true
    version: 2
```

```ruby
nano /etc/sysctl.conf

# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.

# Uncomment the next line to enable packet forwarding for IPv4
# net.ipv4.ip_forward=0
```

### Configuración

Los ficheros de configuración de red de `Ubuntu Server` cuelgan del directorio principal `/etc/`. Estos son: `netplan/50-cloud-init.yaml` (modificación de IP's) y `sysctl.conf` (permite el reenvío de paquetes).

1. Editar fichero de red.

```ruby
nano /etc/netplan/50-cloud-init.yaml

network:
    ethernets:
        ens160:
            dhcp4: true
        ens256:
            addresses: [192.168.227.133/24]
            nameservers:
                addresses: [1.1.1.1, 8.8.8.8]
    version: 2
```

2. Permitir el redireccionamiento.

```ruby
nano /etc/sysctl.conf

# /etc/sysctl.conf - Configuration file for setting system variables
# See /etc/sysctl.d/ for additional system variables.
# See sysctl.conf (5) for information.

# Uncomment the next line to enable packet forwarding for IPv4
 net.ipv4.ip_forward=1
```

- Para aplicar los cambios de redireccionamiento ejecutamos en consola...

```ruby
sysctl -p /etc/sysctl.conf
```

- Comprobamos en consola...

```ruby
cat /proc/sys/net/ipv4/ip_forward
```

3. Consultamos las reglas IPTABLES en consola.

- Normalmente estas reglas están en ACCEPT.

```ruby
iptables -L
```

- Vemos la tabla nat, y si está vacia creamos la regla.

```ruby
iptables -L -nv -t nat
```

- Creamos la regla `postrouting`

```ruby
iptables -t nat -A POSTROUTING -o ens160 -j MASQUERADE
```

## Comprobar

- Desde la máquina `Debian` lanzamos un ping.

```ruby
ping 8.8.8.8
ping google.com
```
- Consultamos nuevamente la tabla nat.

```ruby
iptables -L -nv -t nat
```

## Iptables.

- Para que no se pierdan los cambios hechos en `iptables` una vez reiniciado el servidor instalamos la siguiente herramienta.

```ruby
apt install iptables-persistent
```

- Salvamos los cambios ejecutando en consola...

```ruby
netfilter-persistent save
```

## Conclusiones

Gracias a las característica que dispone Ubuntu server, tendremos la capacidad de implementar servicios de enrutamiento en nuestras computadoras y compartir datos entre ella.

## Referencias

* [Router Wiki](https://es.wikipedia.org/wiki/R%C3%BAter)
* [Ubuntu Server](https://ubuntu.com/server/docs)
* [Router en Ubuntu](https://www.thequbit.net/2024/09/router-ubuntu.html)
