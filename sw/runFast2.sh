tm4 stop
tm4release
tm4get
cd ../hdl
tm4run 
tm4 set_clk 0 40000000
cd ../sw
./mcml_tm4 Input/Real2mci/Real2_100M.mci
mv Real.mco Real2_100M.mco
