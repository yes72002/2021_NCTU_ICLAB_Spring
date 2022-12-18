# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
APRII: Things to do after layout

## Design
Lab12 Exercise  
Artificial Neural Network APRII
In this lab you are going to finish the backend flow (APR) for this design and do the power verification.

| Input | Description |
| --- | --- |
| clk | Clock. |
| rst_n | Asynchronous active-low reset. |
| IN_VALID_1 | High when ALPHA_I, A_I and D_I is valid. |
| IN_VALID_2 | High when THETA_JOINT_1, THETA_JOINT_2 and THETA_JOINT_3 is valid. |
| ALPHA_I | 𝛼𝑖: link twist |
| A_I | 𝑎𝑖: link length |
| D_I | 𝑑𝑖: offset along previous z-axis to the common normal |
| THETA_JOINT_1 | 𝜃1 [𝑡𝑗]: joint angle of the first joint (angle of the first motor of the gimbal stabilizer) of time instant 𝑡𝑗 |
| THETA_JOINT_2 | 𝜃2 [𝑡𝑗]: joint angle of the second joint (angle of the second motor of the gimbal stabilizer) of time instant 𝑡𝑗 |
| THETA_JOINT_3 | 𝜃3 [𝑡𝑗]: joint angle of the third joint (angle of the third motor of the gimbal stabilizer) of time instant 𝑡𝑗 |
| THETA_JOINT_4 | 𝜃4 [𝑡𝑗]: joint angle of the fourth joint (angle of the fourth motor of the gimbal stabilizer) of time instant 𝑡𝑗 |

| Output | Description |
| --- | --- |
| OUT_VALID | High when OUT_X, OUT_Y and OUT_Z is valid. |
| OUT_X | 𝑥𝑜𝑢𝑡: x-component of the position in the reference frame |
| OUT_Y | 𝑦𝑜𝑢𝑡: y-component of the position in the reference frame |
| OUT_Z | 𝑧𝑜𝑢𝑡: z-component of the position in the reference frame |


## Time
2021.06.02 - 2021.06.06

## Notes
+ APRII: Things to do after layout
+ Power Verification
+ Innovus tool


