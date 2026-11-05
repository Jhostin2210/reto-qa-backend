@ignore
Feature: Helpers de soporte para el escenario "usuario con carrito"
  Se llaman por tag, p. ej.: call read('classpath:serverest/helpers/soporte-carrito.feature@login') { ... }

  Background:
    * url baseUrl

  @login
  Scenario: Iniciar sesión y obtener el token
    Given path 'login'
    And request { email: '#(email)', password: '#(password)' }
    When method post
    Then status 200
    * def token = response.authorization

  @crearProducto
  Scenario: Crear un producto (requiere token de administrador)
    Given path 'produtos'
    And header Authorization = token
    And request { nome: '#(DataGenerator.nombreProducto())', preco: 100, descricao: 'Producto creado por la suite Karate', quantidade: 5 }
    When method post
    Then status 201
    * def id = response._id

  @crearCarrito
  Scenario: Crear un carrito con un producto
    Given path 'carrinhos'
    And header Authorization = token
    And request { produtos: [{ idProduto: '#(idProducto)', quantidade: 1 }] }
    When method post
    Then status 201
    * def id = response._id

  @cancelarCarrito
  Scenario: Cancelar la compra (elimina el carrito y repone stock)
    Given path 'carrinhos', 'cancelar-compra'
    And header Authorization = token
    When method delete
    * if (responseStatus != 200) karate.log('[limpieza] No se pudo cancelar el carrito', response)

  @eliminarProducto
  Scenario: Eliminar un producto
    Given path 'produtos', idProducto
    And header Authorization = token
    When method delete
    * if (responseStatus != 200) karate.log('[limpieza] No se pudo eliminar el producto', idProducto, response)
