package serverest.usuarios;

import com.intuit.karate.junit5.Karate;

/**
 * Runner para ejecutar desde el IDE (clic en "Run" sobre cada método).
 * No lo toma "mvn test" (solo corre *Test.java); para CI se usa serverest.ServeRestTest.
 */
class UsuariosRunner {

    @Karate.Test
    Karate todos() {
        return Karate.run().relativeTo(getClass());
    }

    @Karate.Test
    Karate listar() {
        return Karate.run("listar-usuarios").relativeTo(getClass());
    }

    @Karate.Test
    Karate registrar() {
        return Karate.run("registrar-usuario").relativeTo(getClass());
    }

    @Karate.Test
    Karate buscarPorId() {
        return Karate.run("buscar-usuario-por-id").relativeTo(getClass());
    }

    @Karate.Test
    Karate actualizar() {
        return Karate.run("actualizar-usuario").relativeTo(getClass());
    }

    @Karate.Test
    Karate eliminar() {
        return Karate.run("eliminar-usuario").relativeTo(getClass());
    }

    @Karate.Test
    Karate cicloDeVida() {
        return Karate.run("ciclo-vida-usuario").relativeTo(getClass());
    }
}
