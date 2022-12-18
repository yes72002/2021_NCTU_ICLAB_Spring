# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Design
Midterm project  
Advanced Microcontroller Bus Architecture (AMBA)

| Input | Description |
| --- | --- |
| clk | Clock. |
| rst_n | Asynchronous active-low reset. |

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

| APB interface + busy | Description |
| --- | --- |
| PADDR | This is the APB address bus. |
| PSELx | The APB bridge unit generates this signal to each peripheral bus slave. |
| PENABLE | This signal indicates the second and subsequent cycles of an APB transfer. |
| PWRITE | This signal indicates an APB write access when HIGH and and APB read access when LOW. |
| PWDATA | This bus is driven by the peripheral bus bridge unit during write cycles when PWRITE is HIGH. |
| PREADY | The slave uses this signal to extend an APB transfer. |
| PRDATA | The selected slave drives this bus during read cycles when PWRITE is LOW. |


## Time
2021.04.07 - 2021.04.25

## Notes
+ Advanced Microcontroller Bus Architecture (AMBA)
+ AXI 4 protocol
+ Handshake process
+ DRAM, SRAM

