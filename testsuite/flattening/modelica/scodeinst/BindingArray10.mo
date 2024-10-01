// name: BindingArray10
// keywords:
// status: correct
//

model BindingArray10
  Real x[:] = ones(3);
  annotation(__OpenModelica_commandLineOptions="--newBackend");
end BindingArray10;

// Result:
// class BindingArray10
//   Real[3] x = array(1.0 for $i1 in 1:3);
// end BindingArray10;
// endResult
