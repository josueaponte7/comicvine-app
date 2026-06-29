# comicvine_app — Explorador de personajes de cómic

App Flutter que consulta la API de ComicVine a través de un proxy en Cloudflare
Worker, de modo que la clave de API nunca vive en el cliente ni en el repositorio.
Lista personajes, muestra su detalle, permite buscar, y traduce las descripciones
al español on-device con ML Kit.

## Qué demuestra

- Arquitectura cliente-proxy: la API key se guarda en un Cloudflare Worker, nunca en la app ni en git
- Consumo de API REST con renderizado de contenido HTML en la vista de detalle
- Búsqueda con debounce (espera a que el usuario deje de teclear antes de consultar)
- Traducción on-device al español con google_mlkit_translation, sin enviar texto a ningún servidor
- Español como idioma por defecto en toda la app

## Stack

- Flutter / Dart
- Cloudflare Workers (proxy y custodia de la API key)
- API de ComicVine
- google_mlkit_translation (traducción on-device)

## Cómo ejecutarlo

1. Tener Flutter instalado (https://docs.flutter.dev/get-started/install)
2. Desplegar el Cloudflare Worker con tu propia API key de ComicVine como variable de entorno
3. Apuntar la app a la URL de tu Worker
4. flutter pub get
5. flutter run