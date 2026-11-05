@usuarios @eliminar
Feature: DELETE /usuarios/{_id} - Eliminar usuario
  Como administrador del sistema
  Quiero eliminar usuarios
  Para mantener depurada la base de datos

  Background:
    * url baseUrl
    * def idsCreados = []
    * configure afterScenario = limpiarUsuarios
    * def soporte = 'classpath:serverest/helpers/soporte-carrito.feature'

  @smoke @positivo
  Scenario: Eliminar un usuario existente retorna 200 y el usuario deja de existir
    * def creado = crearUsuario()
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response == { message: '#(mensajes.registroEliminado)' }

    Given path 'usuarios', creado.id
    When method get
    Then status 400
    And match response == { message: '#(mensajes.usuarioNoEncontrado)' }

  @negativo
  Scenario: Eliminar un ID inexistente retorna 200 sin eliminar registros
    Given path 'usuarios', DataGenerator.idInexistente()
    When method delete
    Then status 200
    And match response == { message: '#(mensajes.ningunRegistroEliminado)' }

  @negativo
  Scenario: Eliminar dos veces el mismo usuario: la segunda vez no elimina registros
    * def creado = crearUsuario()
    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response.message == mensajes.registroEliminado

    Given path 'usuarios', creado.id
    When method delete
    Then status 200
    And match response.message == mensajes.ningunRegistroEliminado

  @negativo
  Scenario: No se puede eliminar un usuario que tiene un carrito registrado
    # Precondiciones: usuario admin con sesión, un producto propio y un carrito con ese producto
    * def creado = crearUsuario({ administrador: 'true' })
    * def sesion = call read(soporte + '@login') { email: '#(creado.usuario.email)', password: '#(creado.usuario.password)' }
    * def producto = call read(soporte + '@crearProducto') { token: '#(sesion.token)' }
    * def carrito = call read(soporte + '@crearCarrito') { token: '#(sesion.token)', idProducto: '#(producto.id)' }

    # Limpieza garantizada aunque falle una validación: cancelar carrito -> eliminar producto -> eliminar usuario
    * def token = sesion.token
    * def idProducto = producto.id
    * configure afterScenario =
      """
      function() {
        karate.call(soporte + '@cancelarCarrito', { token: token });
        karate.call(soporte + '@eliminarProducto', { token: token, idProducto: idProducto });
        limpiarUsuarios();
      }
      """

    Given path 'usuarios', creado.id
    When method delete
    Then status 400
    And match response == { message: '#(mensajes.usuarioConCarrito)', idCarrinho: '#(carrito.id)' }

    # El usuario sigue existiendo
    Given path 'usuarios', creado.id
    When method get
    Then status 200
