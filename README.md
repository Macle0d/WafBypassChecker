# WafByPassChecker

`WafByPassChecker` es una herramienta diseñada para probar bypasses en Web Application Firewalls (WAF) mediante el uso de IPs directas y modificaciones del archivo `/etc/hosts`. Esta herramienta permite identificar si el WAF está protegiendo el sitio objetivo al interactuar directamente con su IP real.

## Requisitos

Antes de usar la herramienta, asegúrate de cumplir con los siguientes requisitos:

- **Sistema Operativo**: Linux / macOS.
- **Dependencias**:
  - bash
  - [wafw00f](https://github.com/EnableSecurity/wafw00f)
- **Permisos de escritura en `/etc/hosts`**: Requerido para realizar pruebas manuales de bypass.

## Instalación

1. Clona este repositorio:
   ```bash
   git clone https://github.com/Macle0d/WafByPassChecker.git
   cd WafByPassChecker
   ```

2. Asegúrate de que el archivo es ejecutable:
   ```bash
   chmod +x WafByPassChecker.sh
   ```

3. Verifica que tienes `wafw00f` instalado:
   ```bash
   pip install wafw00f
   ```

## Uso

```bash
bash WafByPassChecker.sh -u <URL> [opciones]
```

### Opciones
- `-u, --url <URL>`: Especifica la URL del sitio objetivo.
- `-ip, --ip <IP>`: Dirección IP real del sitio.
- `-f, --file <archivo>`: Archivo con una lista de IPs (una por línea).
- `-exploit`: Realiza la comprobación del posible Bypass.

### Ejemplos de uso

- Probar una URL específica y su IP real:
  ```bash
  bash WafByPassChecker.sh -u "https://www.ejemplo.com" -ip 1.2.3.4
  ```

- Probar una URL con una lista de IPs desde un archivo:
  ```bash
  bash WafByPassChecker.sh -u "https://www.ejemplo.com" -f ips.txt
  ```

## Prueba Manual (bypass con `/etc/hosts`)

En algunos casos, puedes realizar un bypass manual modificando el archivo `/etc/hosts` para redirigir el dominio objetivo a una IP específica. A continuación se describe cómo hacerlo:

1. Edita el archivo `/etc/hosts`:
   ```bash
   sudo nano /etc/hosts
   ```

2. Agrega la IP y dominio al final del archivo. Por ejemplo:
   ```
   1.2.3.4 www.ejemplo.com
   ```

3. Guarda los cambios y verifica si el bypass funciona usando `wafw00f`:
   ```bash
   wafw00f https://www.ejemplo.com
   ```

## Salida Esperada

La herramienta mostrará si el WAF está activo al acceder directamente a la IP real del sitio. En caso de éxito, podrás ver resultados indicando que el WAF no protege el recurso bajo la IP específica.

## Licencia

Este proyecto está bajo la licencia [GNU](LICENSE). Puedes usarlo, modificarlo y distribuirlo según los términos de la licencia.

---

## Contribuciones

Si deseas contribuir a este proyecto:
1. Haz un fork del repositorio.
2. Crea una nueva rama:
   ```bash
   git checkout -b feature/nueva-funcion
   ```
3. Realiza tus cambios y súbelos:
   ```bash
   git commit -m "Añadir nueva funcionalidad"
   git push origin feature/nueva-funcion
   ```
4. Abre un Pull Request.

---

## Contacto

Si tienes dudas, problemas o sugerencias, no dudes en abrir un Issue en este repositorio o contactarme directamente en [https://github.com/Macle0d](https://github.com/Macle0d).

## Autor
- Omar Peña - [@Macle0d](https://github.com/Macle0d) - [@p3nt3ster](https://x.com/p3nt3ster)
