// name: DimUnknown13
// keywords:
// status: incorrect
//
//

model DimUnknown13
  Real c[:] = fill(0, size(c, 1));
end DimUnknown13;

// Result:
// Error processing file: DimUnknown13.mo
// [flattening/modelica/scodeinst/DimUnknown13.mo:8:3-8:34:writable] Error: Dimension 1 of c, ':', could not be evaluated due to a cyclic dependency.
//
// # Error encountered! Exiting...
// # Please check the error message and the flags.
//
// Execution failed!
// endResult
