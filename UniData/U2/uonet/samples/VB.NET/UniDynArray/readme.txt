This sample shows how UniDynArray Object will be created

This sample contains the source code for the UniDynArray Tutorial.


Building and Running the Sample Within Visual Studio
=======================================================

To build and run the UniDynArray sample 

1. Open the solution (UniDynArray.sln).

2. In Solution Explorer, right-click the UniDynArray project and click Properties. 

3. Right-click the "Reference: and then select "Add Reference..." menu item. 

4. You will see Add Reference Dialog Box. Press "Browse..." Button. Locate UODOTNET.DLL assembly in your computer. 
   Generally it is found in C:\IBM\UNIDK\UODOTNET\BIN\UODOTNET.DLL


5. Click OK. 

6. Use visual editor to edit "UniDynArraySample.vb" file for correct Hostname, UserID, Password,  Account, ServiceType.

7. From the Debug menu, click Start Without Debugging. 



Building and Running the Sample from the Command Line

To build and run the UniDynArray sample 
=======================================

1. Run Visual Studio .NET 2003 Command Prompt. Generally it is found in start->programs->Microsoft Visual Studio 2003->
   Visual Studio .NET Tools->Visual Studio .NET 2003 Command Prompt.

2. Goto Samples Directory. For example: "cd C:\IBM\UNIDK\UODOTNET\Samples\VB.NET\UniDynArray"

3. Use any editor to edit "UniDynArraySample.vb" file for correct Hostname, UserID, Password,  Account, ServiceType.

4. To compile the sample program, type the following at the command prompt: 
vbc.exe UniDynArraySample.vb /reference:C:\IBM\UNIDK\UODOTNET\BIN\UODOTNET.DLL
where :
vbc.exe is VB.NET compiler

5. After successful compilation it will produce UniDynArray.exe  executable.

6. Type UniDynArray.exe and press Enter. Follow the output.

