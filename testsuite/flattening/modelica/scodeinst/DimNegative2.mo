// name: DimNegative1
// keywords:
// status: correct
//

model DimNegative2
  Real x[-1] if false;
end DimNegative2;

// Result:
// class DimNegative2
// end DimNegative2;
// endResult
