tm4 stop
tm4release
tm4get
cd ../hdl
tm4run 
tm4 set_clk 0 40000000
cd ../sw
./mcml_tm4 Input/Realmci/Real_25M.mci
mv Real.mco Real_25M.mco
