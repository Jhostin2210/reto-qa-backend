@ignore
Feature: Helper - eliminar un usuario vía DELETE /usuarios/{_id} (limpieza de datos)

  Scenario: Eliminar usuario por id sin fallar si ya no existe
    Given url baseUrl
    And path 'usuarios', id
    When method delete
    * if (responseStatus != 200) karate.log('[limpieza] No se pudo eliminar el usuario', id, response)
