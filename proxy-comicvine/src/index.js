// Proxy para la API de Comic Vine.
// La app Flutter llama a este Worker; el Worker añade la clave y reenvía a Comic Vine.

const COMICVINE_BASE = "https://comicvine.gamespot.com/api";

// CORS abierto: inofensivo para móvil, útil si algún día pruebas desde Flutter web o el navegador.
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
};

export default {
  async fetch(request, env, ctx) {
    // Petición de sondeo CORS del navegador
    if (request.method === "OPTIONS") {
      return new Response(null, { headers: CORS_HEADERS });
    }

    // Proxy de solo lectura: únicamente GET
    if (request.method !== "GET") {
      return json({ error: "Método no permitido" }, 405);
    }

    // Si la clave no está configurada en el servidor, fallamos claro y pronto
    if (!env.COMICVINE_API_KEY) {
      return json({ error: "Falta configurar la clave en el servidor" }, 500);
    }

    const incoming = new URL(request.url);

    // Misma ruta que pidió la app, misma query, + nuestra clave y format=json
    const target = new URL(COMICVINE_BASE + incoming.pathname);
    for (const [key, value] of incoming.searchParams) {
      target.searchParams.set(key, value);
    }
    target.searchParams.set("api_key", env.COMICVINE_API_KEY);
    target.searchParams.set("format", "json");

    try {
      const cvResponse = await fetch(target.toString(), {
        headers: {
          // Comic Vine rechaza peticiones sin User-Agent propio
          "User-Agent": "comicvine-flutter-app/1.0",
        },
      });

      const body = await cvResponse.text();
      return new Response(body, {
        status: cvResponse.status,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      });
    } catch (err) {
      return json({ error: "No se pudo contactar a Comic Vine", detalle: String(err) }, 502);
    }
  },
};

// Pequeño ayudante para devolver JSON con CORS
function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
  });
}