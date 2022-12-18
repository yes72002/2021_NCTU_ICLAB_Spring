# 2021_Spring_NCTU_ICLAB
NCTU 2021 Spring Integrated Circuit Design Laboratory (ICLAB)

## Course Content
Coverage and Assertion

## Design
Lab10 Exercise  
Happy Farm Coverage (From Lab09)

Assertion: (TA’s DESIGN + TA’s PATTERN+ Your CHECKER)
1. All outputs should be zero after reset.
2. If action is completed, err_msg must be 4’b0.
3. If action is “check deposit”, out_info should be 0 when out_valid is high.
4. If action isn’t “check deposit”, out_deposit should be 0 when out_valid is high.
5. Out_valid will be high for one cycle.
6. The gap length between id_valid and act_valid is at least 1 cycle.
7. When action is Seed, the gap length between cat_valid and amnt_valid is at least 1 cycle.
8. The four valid signals won’t overlap with each other.( id_valid, act_valid, cat_valid, amnt_valid )
9. Next operation will be valid 2-10 cycles after out_valid fall.
10. Latency should be less than 1200 cycle for each operation.


## Time
2021.05.12 - 2021.05.16

## Notes
+ Coverage
+ Assertion
+ imc tool



