# Comic Vine App

App móvil en Flutter para explorar personajes de cómics (Marvel, DC y más) usando la API de [Comic Vine](https://comicvine.gamespot.com/api/). Lista, búsqueda y ficha de detalle, **en español por defecto** gracias a traducción que corre en el propio dispositivo.

El proyecto es un *monorepo* con dos piezas: un **proxy** desplegado en Cloudflare Workers y la **app Flutter** que lo consume.

## Capturas

> _Añade aquí tus capturas (lista y detalle). Por ejemplo:_
>
> `![Lista de personajes](docs/lista.png)` · `![Detalle](docs/detalle.png)`

## Qué hace

- **Lista de personajes** con imagen, nombre y resumen.
- **Búsqueda por nombre** con *debounce* (no satura la API: espera a que dejes de escribir antes de consultar).
- **Ficha de detalle** con imagen grande y descripción completa.
- **Español por defecto.** Los textos llegan en inglés desde la API y se traducen en el teléfono. En el detalle, un botón permite alternar al texto original.
- **Imágenes cacheadas** para que la lista no recargue ni parpadee al hacer scroll.

## Decisiones de arquitectura

Dos decisiones explican el porqué del proyecto más allá de "una app que llama a una API".

### 1. Proxy para no exponer la clave de la API

La API de Comic Vine se autentica con una clave que viaja en cada petición. Meter esa clave dentro de la app es el error clásico: cualquiera que descompile el APK la extrae y consume la cuota a tu nombre.

En lugar de eso, la app **nunca ve la clave**. Habla con un Cloudflare Worker propio que actúa de intermediario: recibe la petición, le inyecta la clave (guardada como *secret* cifrado en Cloudflare, fuera del código y fuera de git), añade el `User-Agent` que Comic Vine exige, resuelve CORS y reenvía la llamada. La app solo conoce la URL del proxy.

```
App Flutter  ──►  Cloudflare Worker  ──►  Comic Vine API
              (sin clave)        (inyecta clave + User-Agent)
```

### 2. Traducción *on-device*, sin servidor ni coste

Comic Vine es una wiki en inglés; no tiene versión en español ni parámetro de idioma. En vez de pagar un servicio de traducción o añadir latencia con una llamada extra, la traducción corre **en el propio teléfono** con ML Kit de Google.

- Gratis, sin clave, sin servidor.
- Funciona *offline* una vez descargado el modelo de idioma (la primera vez baja ~30 MB).
- Estrategia *lazy*: en la lista se traduce solo el resumen corto (rápido); la descripción larga se traduce al abrir el detalle de ese personaje. Así el usuario nunca espera por texto que aún no está mirando.

## Stack

| Capa | Tecnología |
|------|-----------|
| App | Flutter / Dart |
| Red | `http` |
| Imágenes | `cached_network_image` |
| HTML | `flutter_html` |
| Traducción | `google_mlkit_translation` (on-device) |
| Proxy | Cloudflare Workers (JavaScript) |
| API | Comic Vine |

## Estructura

```
comicvine-app/
├── proxy-comicvine/      # Cloudflare Worker (proxy de la API)
│   └── src/index.js
└── comicvine_app/        # App Flutter
    └── lib/
        ├── models/       # Character
        ├── services/     # cliente de API + traducción
        └── screens/      # lista + detalle
```

## Cómo ejecutarlo

### Proxy (Cloudflare Worker)

```bash
cd proxy-comicvine
npm install

# Clave para pruebas locales (no se sube a git)
echo "COMICVINE_API_KEY=TU_CLAVE" > .dev.vars
npm run dev          # local

# Despliegue
npx wrangler secret put COMICVINE_API_KEY   # carga la clave cifrada en la nube
npm run deploy
```

Consigue tu clave gratis en https://comicvine.gamespot.com/api/ (requiere cuenta y verificar el correo).

### App (Flutter)

```bash
cd comicvine_app
flutter pub add http cached_network_image flutter_html google_mlkit_translation
flutter run
```

> **Android:** requiere `minSdk 23` o superior (lo pide ML Kit). Ya está configurado en `android/app/build.gradle.kts`.

En `lib/services/comicvine_service.dart`, ajusta `_baseUrl` a la URL de tu propio Worker.

## Notas

- La clave de Comic Vine **nunca** está en el repositorio: vive como *secret* en Cloudflare y, en local, en `.dev.vars` (ignorado por git).
- Uso no comercial, según los términos de la API de Comic Vine.

---

Hecho por [josueaponte7](https://github.com/josueaponte7).
