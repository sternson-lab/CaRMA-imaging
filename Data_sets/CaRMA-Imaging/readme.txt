tbNID.mat is the table of meta information about the 319 neurons for the CaRMA imaging analyses. It has 2 variables.
	ANMID:  the animal ID from which animal the neuron was imaged. value: 1 to 3.
	NID: the neuron ID within all identified cells from a animal. The NID is for the neuron that could be tracked along all experiments.

tbFISH_AllTypes_v2.mat provides the multiplex FISH signals of these 319 neurons. It has 3 variables. Each variable is a table.
	tbFISH_AllTypes_Raw: the table of raw FISH signals.
	tbFISH_AllTypes_N01: normalized expression level of FISH signals. Each signal was linearly normalized to [0 1] within a animal
	tbFISH_AllTypes_ReLu_Log_N01: normalized expression level of FISH signals. Each signal was normalized to [0 1] by the equation in fig. S29.
xxx_V, xxx_M and xxx_S in each table are the voxels, mean intensity and total intensity of FISH signal of gene xxx.

stResp_Behavs_Base.mat provides the neuronal responses in all 11 behavioral states as well as in baseline periods of different experiments. It has 2 variables.
	clBeh_Phases: the names of the 11 behavioral states.
	stResp_Behavs: a structure contains neuronal responses. It has 3 fields.
		.ROC: responses normalized by auROC. It has 4 fields
		           .tbResp_Behavs: neuronal responses at each image frame in 11 behavioral states
		           .tbResp_Behavs_Bin: 26-bin  neuronal responses in 11 behavioral states
		           .tbResp_Behavs_Base: neuronal responses at each image frame in baseline periods  of 6 behavioral experiments
		           .tbResp_Behavs_Bin_Base: 26-bin neuronal responses at each image frame in baseline periods  of 6 behavioral experiments
		.N01: responses linearly normalized to [0 1]. It has 4 fields as .ROC, but with different normalization.
		.Cls: class ID of molecular cluster 