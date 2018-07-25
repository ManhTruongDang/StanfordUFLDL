% minFunc
fprintf('Compiling minFunc files...\n');
% mex -outdir minFunc/compiled minFunc/mex/mcholC.c
% mex -outdir minFunc/compiled minFunc/mex/lbfgsC.c
% mex -outdir minFunc/compiled minFunc/mex/lbfgsAddC.c
% mex -outdir minFunc/compiled minFunc/mex/lbfgsProdC.c

mex -outdir D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\compiled   D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\mex\mcholC.c
mex -outdir D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\compiled   D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\mex\lbfgsC.c
mex -outdir D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\compiled   D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\mex\lbfgsAddC.c
mex -outdir D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\compiled   D:\Hoctap\MachineLearning\stanford_dl_ex-master\stanford_dl_ex-master\common\minFunc_2012\minFunc\mex\lbfgsProdC.c