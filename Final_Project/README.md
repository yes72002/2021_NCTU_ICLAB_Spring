# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Design
Final project  
Customized ISA Processor (CPU)

| Input | Description |
| --- | --- |
| clk | Clock. |
| rst_n | Asynchronous active-low reset. |

| Output | Description |
| --- | --- |
| IO_stall | Pull high when core is busy. It should be low for one cycle whenever you finished an instruction. |

| Write Address Channel | Description |
| --- | --- |
| AWID | Write address ID.|
| AWADDR | Write address. |
| AWLEN | Nurst length. |
| AWSIZE | Burst size. |
| AWBURST | Burst type. |
| AWVALID | Write address valid. |
| AWREADY | Write ddress ready. |

| Write Data Channel | Description |
| --- | --- |
| WDATA | Write data. |
| WLAST | Write last. |
| WVALID | Write valid. |
| WREADY | Write ready. |

| Write Response Channel | Description |
| --- | --- |
| BID | Response ID. |
| BRESP | Write response. |
| BVALID | Write response valid. |
| BREADY | Response ready. |

| Read Address Channel | Description |
| --- | --- |
| ARID | Read address ID.|
| ARADDR | Read address. |
| ARLEN | Nurst length. |
| ARSIZE | Burst size. |
| ARBURST | Burst type. |
| ARVALID | Read address valid. |
| ARREADY | Read ddress ready. |

| Read Data Channel | Description |
| --- | --- |
| RID | Read ID tag. |
| RDATA | Read data. |
| RRESP | Read response. |
| RLAST | Read last. |
| RVALID | Read valid. |
| RREADY | Read ready. |

## Time
2021.06.02 - 2021.06.20

## Notes
+ Customized ISA Processor (CPU)
+ AXI 4 protocol
+ Handshake process
+ DRAM, SRAM, cache
+ Instruction set
+ MIPS
+ APR
+ Post-layout gate-level simulation

