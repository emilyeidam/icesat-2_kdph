# icesat-2_kdph
Code uploaded by Dr. Emily Eidam (emily.eidam@oregonstate.edu), November 2023. Comments are provided in the code. Code should be attributed to author as appropriate under the GNU GPLv3 license.

Files included:

proc01_convert_hd5_to_atl_mat_forGitHub.m
proc02_manually_select_water_forGitHub.m
proc03_clipwater_correctdepths_bin_flagAPIR_forGitHub.m
proc04_calc_kd_forGitHub.m

Files are designed to be run in order for .h5 files contained in their default folders (folders starting with "2" which are created when the EarthData downloads are unzipped). Whole segments or spatially subsetted segments may be used (I recommend the latter). 

The first file is dependent on the following function which is also included:
readATL03_github.m

These files were created in support of a manuscript submitted for review in November 2023:
Eidam, E., Bisson, K., Wang, C., Walker, C., Gibbons, A. In review. ICESat-2 and ocean particulates: Building a roadmap for calculating Kd from space-based lidar photon profiles. 
