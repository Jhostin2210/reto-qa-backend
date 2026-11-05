function fn() {
  // Ambiente: se elige con -Dkarate.env=qa|local (por defecto: qa)
  var env = karate.env || 'qa';

  var urls = {
    qa: 'https://serverest.dev',
    local: 'http://localhost:3000'
  };

  // -DbaseUrl=... tiene prioridad sobre el ambiente (útil para apuntar a otra instancia)
  var baseUrl = karate.properties['baseUrl'] || urls[env];
  if (!baseUrl) {
    throw 'Ambiente no soportado: ' + env + '. Usa qa o local, o define -DbaseUrl=...';
  }

  karate.configure('connectTimeout', 15000);
  karate.configure('readTimeout', 30000);
  karate.configure('ssl', true);
  karate.configure('headers', { Accept: 'application/json' });

  return {
    env: env,
    baseUrl: baseUrl,

    // Datos de prueba
    DataGenerator: Java.type('serverest.helpers.DataGenerator'),
    generarUsuario: read('classpath:serverest/helpers/usuario-builder.js'),
    mensajes: read('classpath:serverest/data/mensajes.json'),

    // Helpers de API reutilizables
    crearUsuario: read('classpath:serverest/helpers/crear-usuario.js'),
    limpiarUsuarios: read('classpath:serverest/helpers/limpiar-usuarios.js')
  };
}
