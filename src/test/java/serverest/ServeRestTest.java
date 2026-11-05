package serverest;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Runner principal de la suite (lo ejecuta "mvn test").
 *
 * - Ejecuta en paralelo todos los .feature de serverest/usuarios.
 * - Los helpers marcados con @ignore no se ejecutan como pruebas.
 * - Hilos configurables: -Dthreads=N (por defecto 4).
 * - Filtrar por tags: -Dkarate.options="--tags @smoke"
 * - Reportes: target/karate-reports/karate-summary.html
 */
class ServeRestTest {

    @Test
    void ejecutarSuiteUsuarios() {
        Results results = Runner.path("classpath:serverest/usuarios")
                .tags("~@ignore")
                .outputCucumberJson(true)
                .outputJunitXml(true)
                .parallel(Integer.getInteger("threads", 4));

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
