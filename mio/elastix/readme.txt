These functions allows for interaction with the ElastiX program for
image registration. 

To get ElastiX running, follow these instructions


1) Download ElastiX from http://elastix.isi.uu.nl

2) Unzip and rename the downloaded folder as 'elastix'

MAC

3) Move the program folder into /usr/local/elastix, e.g. by
    'sudo mv ~/Downloads/elastix /usr/local'

4) Typing 'ls /usr/local/elastix' should now show to folder, bin and lib
 
5) To run, you need to be able to start elastix from your terminal by 
   typing 'elastix'. Do this by editing ~/.bash_profile, and add the following
   lines 

   export PATH=/usr/local/elastix/bin:/usr/local/elastix/parameters:$PATH
   export DYLD_LIBRARY_PATH=/usr/local/elastix/lib:$DYLD_LIBRARY_PATH

   The editing can be done from within Matlab by 
   typing 'edit ~/.bash_profile'
  

WINDOWS

3) Move the program folder into %userprofile%\elastix 
   (e.g., 'c:\users\johndoe')

4) Go to Control Panel -> System and Security -> System -> 
   Advanced system settings -> Environment variables

5) Edit the 'PATH' variable under 'System variables', and add 
   the path to elastix folder

6) Restart Matlab
