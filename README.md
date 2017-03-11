This tool helps to add license declaration for a batch of files. The declaration will be added in the head of source files, or behind shebang if it exists. Declaration contents need to be defined in corresponding files under folder *./declare*. 

Usage:

`addDeclare.tcl -*lang* *path_to_src_folder*`

The declaration will be added to all the files of language *lang* (*lang* as file name extention) under the input folder.

currently supported languages : java, c, cpp, py, r, tcl.

Licence : WTFPL

