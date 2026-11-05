/**
 * Crea un usuario vía API (precondición de un escenario) y lo registra para limpieza automática.
 * Uso:
 *   * def creado = crearUsuario()                          -> { id: '...', usuario: { nome, email, password, administrador } }
 *   * def creado = crearUsuario({ administrador: 'false' })
 */
function fn(sobrescribir) {
  var generarUsuario = karate.get('generarUsuario');
  var usuario = generarUsuario(sobrescribir);
  var resultado = karate.call('classpath:serverest/helpers/crear-usuario.feature', { usuario: usuario });
  if (karate.get('idsCreados')) {
    karate.appendTo('idsCreados', resultado.id);
  }
  return { id: resultado.id, usuario: usuario };
}
