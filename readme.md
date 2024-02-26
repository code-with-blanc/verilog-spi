## SPC - Serial to Parallel Controller

### Nomenclatura

Este projeto implementa uma Serial-Parallel Interface (SPI) que é controlada através do protocolo Serial Peripheral Interface (SPI). Assim, na documentação e no código a seguinte nomenclatura é usada:

- SPI -> O protocolo, serial peripheral interface
- SPC -> O dispositivo, serial-parallel converter

### Funcionamento / Estrutura

O módulo spi_controller recebe os sinais do barramento SPI e gera sinais de controle para o resto do dispositivo.

Este módulo implementa internamente uma máquina de estados que transita entre espera (idle), leitura dos bytes de controle do protocolo SPI e leitura do valor que deve ser produzido na saída.

Para permitir que a saída seja mantida em um valor estável enquanto o próximo valor é enviado ao controlador, um registrador (shift_register) é carregado a medida que um novo valor chega ao dispositivo. Este valor é então copiado para um registrador de saída (out_register).

```
.
.                  +----------------+    ctl_data        +----------------------+
.        mosi ---->|                |------------------->|                      |
.                  |                |                    |                      |
.        cs_n ---->|                |    ctl_shift       |    shift_register    |
.                  | spi_controller |------------------->|                      |
.         clk ---->|                |                    +----------+-----------+
.                  |                |    ctl_copy                   |
. out_data_ready <-|                |----------------+              v
.                  +----------------+                |   +----------+-----------+
.                                                    |   |                      |
.                                                    +---+     out_register     |
.                                                        |                      |
.                                                        +----------------------+
.
```

### Interface

O módulo recebe comandos SPI através das linhas sclk e mosi. A linha cs_n (ativa baixa) deve ser acionada para habilitar o recebimento de comandos pelo SPC.

O primeiro byte enviado pelo SPI é um byte de comando. O único comando disponível é WRITE, correspondente ao valor 10010001. Os bytes subsequentes são o valor que deve ser escrito à saída. Atualmente o sistema está implementado para 16bits apenas, logo 2 bytes devem ser enviados.

A linha out_data_ready fica em 0 a partir do momento que a comunicação SPI se inicia e é levada ao nível 1 quando o valor é copiado para o registrador de saída.

### TODO
- Implementar testes e lógica para reset
- Implementar testes e reforçar logica para out_data_ready
- Implementar testes e reforçar lógica para cs_n
- Parametrizar design
