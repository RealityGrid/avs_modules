flibrary RealityGridMods <
   build_dir="iac_proj/reg_steer",
   out_hdr_file="reg_gen.hxx",
   out_src_file="reg_gen.cxx",
   link_files="-L$(REG_XML_LIBDIR) -L$(REG_STEER_HOME)/lib32 -lReG_Steer -lxml2",
   cxx_src_files="ReGSteerMod.cxx",
   cxx_hdr_files="ReGSteerMod.hxx avs/event.h fld/Xfld.h",
   hdr_dirs="$(REG_STEER_HOME)/include",
   cxx_name="" > {

   // define the config parameters group
   group RealityGridSteeringParams<NEportLevels={0,1}> {
      string reg_sgs_name;
      string reg_sgs_address;
      string iotype_label;
      int connected;
      float pollInterval;
      int numSlices;
   };

   // define the data slice group
   group RealityGridDataSlice<NEportLevels={0,1},NEcolor0=16711680,NEcolor1=65280,NEnumColors=2> {
      enum type {
	 choices = {"char", "int", "float", "double"};
      };
      int size;
      prim data[size];
   };
   
   // define the low level steering module
   module RealityGridSteeringMod<
      src_file="RealityGridSteeringMod.cxx",
      cxx_members="      ReGSteerMod* modInst;
      float oldPollInterval;
      friend void poller(RealityGrid_RealityGridSteeringMod*);
      ~RealityGrid_RealityGridSteeringMod();\n"
      > {
	 cxxmethod init(
	    configuration+read+write+req,
	    start+notify+read
	 );
	 cxxmethod update(
	    configuration+notify+read+req
	 );
	 RealityGridSteeringParams &configuration<NEportLevels={2,0}>;
	 int initialized;
	 int start;
	 int connected;
	 int nudge;
	 int slices;
	 
	 // data output array
	 RealityGridDataSlice outData<NEportLevels={0,2}>[slices];
   }; // RealityGridSteeringMod

   // define the low level slice compositor module
   module RealityGridDataSliceCompositorMod<
      src_file="RealityGridDataSliceCompositorMod.cxx"
      > {
	 cxxmethod join(
	    inData+notify+read+req,
	    numSlices+read,
	    outCharData+write,
	    outIntData+write,
	    outFloatData+write,
	    outDoubleData+write
	 );

	 // input data
	 RealityGridDataSlice &inData<NEportLevels={2,0}>[];

	 // the number of data slices of data
	 int numSlices => array_size(inData);
	 
	 // output data
	 char outCharData<NEportLevels={0,2}>[];
	 int outIntData<NEportLevels={0,2}>[];
	 float outFloatData<NEportLevels={0,2}>[];
	 double outDoubleData<NEportLevels={0,2}>[];
   }; // RealityGridDataSliceCompositorMod

   // define the lbe3D reader module
   module RealityGridLBE3DReaderMod<
      src_file="RealityGridLBE3DReaderMod.cxx",
      cxx_members="      void volumeOutput(double*, int);\n"
      > {
	 cxxmethod read(
	    inData+notify+read+req,
	    numSlices+read,
	    minLabel+write,
	    maxLabel+write,
	    outDims+write,
	    outData+write,
	    outShortData+write,
	    outByteData+write
	 );

	 cxxmethod readField(
	    inField+notify+read+req,
	    configuration+read+req,
	    minLabel+write,
	    maxLabel+write,
	    outDims+write,
	    outData+write,
	    outShortData+write,
	    outByteData+write
	 );
	 
	 // inputs
	 RealityGridSteeringParams &configuration<NEportLevels={2,0}>;
	 RealityGridDataSlice &inData<NEportLevels={2,0}>[];
	 Mesh_Struct+Node_Data &inField<NEportLevels={2,0}>;
	 
	 // the number of data slices of data
	 int numSlices => array_size(inData);

	 // produce volume data output?
	 int volOutput;
	 double minLabel;
	 double maxLabel;

	 // outputs
	 int outDims<NEportLevels={0,2}>[3];
	 double outData<NEportLevels={0,2}>[];
	 short outShortData<NEportLevels={0,2}>[];
	 byte outByteData<NEportLevels={0,2}>[];
	 
   }; // RealityGridLBE3DReaderMod

   // define the NAMD reader module
   module RealityGridNAMDReaderMod<
      src_file="RealityGridNAMDReaderMod.cxx"
      > {
	 cxxmethod read(
	    inData+notify+read+req,
	    numSlices+read,
	    timestep+write,
	    simParams+write,
	    numAtoms+write,
	    atomCoords+write
	 );

	 // inputs
	 RealityGridSteeringParams &configuration<NEportLevels={2,0}>;
	 RealityGridDataSlice &inData<NEportLevels={2,0}>[];
	 
	 // the number of data slices of data
	 int numSlices => array_size(inData);

	 string filename;
	 
	 // sim info
	 int timestep;
	 float simParams[9];
	 
	 // outputs
	 int numAtoms;
	 float atomCoords[numAtoms][3];
	 
   }; // RealityGridNAMDReaderMod
};
