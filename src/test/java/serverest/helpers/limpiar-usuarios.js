/**
 * Hook afterScenario: elimina todos los usuarios creados durante el escenario
 * (los IDs se acumulan en la variable "idsCreados").
 * Uso en el Background:
 *   * def idsCreados = []
 *   * configure afterScenario = limpiarUsuarios
 */
function fn() {
  var ids = karate.get('idsCreados');
  if (!ids) {
    return;
  }
  for (var i = 0; i < ids.length; i++) {
    karate.call('classpath:serverest/helpers/eliminar-usuario.feature', { id: ids[i] });
  }
}
