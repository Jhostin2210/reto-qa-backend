/**
 * Builder de payloads de usuario.
 * Uso:
 *   * def usuario = generarUsuario()                         -> usuario administrador con datos aleatorios
 *   * def usuario = generarUsuario({ administrador: 'false' }) -> sobrescribe solo los campos indicados
 */
function fn(sobrescribir) {
  var DataGenerator = Java.type('serverest.helpers.DataGenerator');
  var usuario = {
    nome: DataGenerator.nombre(),
    email: DataGenerator.emailUnico(),
    password: DataGenerator.password(),
    administrador: 'true'
  };
  return sobrescribir ? karate.merge(usuario, sobrescribir) : usuario;
}
