/*
 * This file is part of OpenModelica.
 *
 * Copyright (c) 1998-2014, Open Source Modelica Consortium (OSMC),
 * c/o Linköpings universitet, Department of Computer and Information Science,
 * SE-58183 Linköping, Sweden.
 *
 * All rights reserved.
 *
 * THIS PROGRAM IS PROVIDED UNDER THE TERMS OF GPL VERSION 3 LICENSE OR
 * THIS OSMC PUBLIC LICENSE (OSMC-PL) VERSION 1.2.
 * ANY USE, REPRODUCTION OR DISTRIBUTION OF THIS PROGRAM CONSTITUTES
 * RECIPIENT'S ACCEPTANCE OF THE OSMC PUBLIC LICENSE OR THE GPL VERSION 3,
 * ACCORDING TO RECIPIENTS CHOICE.
 *
 * The OpenModelica software and the Open Source Modelica
 * Consortium (OSMC) Public License (OSMC-PL) are obtained
 * from OSMC, either from the above address,
 * from the URLs: http://www.ida.liu.se/projects/OpenModelica or
 * http://www.openmodelica.org, and in the OpenModelica distribution.
 * GNU version 3 is obtained from: http://www.gnu.org/copyleft/gpl.html.
 *
 * This program is distributed WITHOUT ANY WARRANTY; without
 * even the implied warranty of  MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE, EXCEPT AS EXPRESSLY SET FORTH
 * IN THE BY RECIPIENT SELECTED SUBSIDIARY LICENSE CONDITIONS OF OSMC-PL.
 *
 * See the full OSMC Public License conditions for more details.
 *
 */

encapsulated uniontype NFBinding

public
  import Expression = NFExpression;
  import NFInstNode.InstNode;
  import Type = NFType;
  import NFPrefixes.Variability;
  import ErrorTypes;
  import Mutable;
  import Subscript = NFSubscript;

protected
  import Binding = NFBinding;
  import Dump;
  import Error;

public
  constant Binding EMPTY_BINDING = UNBOUND();

  type EachType = enumeration(
    NOT_EACH,
    EACH
  );

  type EvalState = enumeration(
    NOT_EVALUATED,
    EVALUATING,
    EVALUATED
  );

  type Source = enumeration(
    BINDING   "The binding comes from a binding equation.",
    TYPE      "The binding comes from a type.",
    MODIFIER  "The binding comes from a modifier.",
    GENERATED "The binding was generated by the frontend."
  );

  record UNBOUND
  end UNBOUND;

  record RAW_BINDING
    Absyn.Exp bindingExp;
    InstNode scope;
    list<Subscript> subs;
    EachType eachType;
    Source source;
    SourceInfo info;
  end RAW_BINDING;

  record UNTYPED_BINDING
    Expression bindingExp;
    Boolean isProcessing;
    InstNode scope;
    EachType eachType;
    Source source;
    SourceInfo info;
  end UNTYPED_BINDING;

  record TYPED_BINDING
    Expression bindingExp;
    Type bindingType;
    Variability variability;
    EachType eachType;
    Mutable<EvalState> evalState;
    Boolean isFlattened;
    Source source;
    SourceInfo info;
  end TYPED_BINDING;

  record FLAT_BINDING
    Expression bindingExp;
    Variability variability;
    Source source;
  end FLAT_BINDING;

  record CEVAL_BINDING
    "Used by the constant evaluation for generated bindings (e.g. record
     bindings constructed from the record fields) that should be discarded
     during flattening."
    Expression bindingExp;
  end CEVAL_BINDING;

  record INVALID_BINDING
    Binding binding;
    list<ErrorTypes.TotalMessage> errors;
  end INVALID_BINDING;

  record WILD end WILD;

public
  function fromAbsyn
    input Option<Absyn.Exp> bindingExp;
    input Boolean eachPrefix;
    input Boolean fromType;
    input InstNode scope;
    input SourceInfo info;
    output Binding binding;
  algorithm
    binding := match bindingExp
      local
        Absyn.Exp exp;
        EachType each_ty;
        Source source;

      case SOME(exp)
        algorithm
          each_ty := if eachPrefix then EachType.EACH else EachType.NOT_EACH;
          source := if fromType then Source.TYPE else Source.BINDING;
        then
          RAW_BINDING(exp, scope, {}, each_ty, source, info);

      else EMPTY_BINDING;
    end match;
  end fromAbsyn;

  function isBound
    input Binding binding;
    output Boolean isBound;
  algorithm
    isBound := match binding
      case UNBOUND() then false;
      case INVALID_BINDING() then false;
      else true;
    end match;
  end isBound;

  function isExplicitlyBound
    input Binding binding;
    output Boolean isBound;
  algorithm
    isBound := match binding
      case UNBOUND() then false;
      case CEVAL_BINDING() then false;
      case INVALID_BINDING() then false;
      else true;
    end match;
  end isExplicitlyBound;

  function isUnbound
    input Binding binding;
    output Boolean isUnbound;
  algorithm
    isUnbound := match binding
      case UNBOUND() then true;
      else false;
    end match;
  end isUnbound;

  function isInvalid
    input Binding binding;
    output Boolean isInvalid;
  algorithm
    isInvalid := match binding
      case INVALID_BINDING() then true;
      else false;
    end match;
  end isInvalid;

  function untypedExp
    input Binding binding;
    output Option<Expression> exp;
  algorithm
    exp := match binding
      case UNTYPED_BINDING() then SOME(binding.bindingExp);
      else NONE();
    end match;
  end untypedExp;

  function typedExp
    input Binding binding;
    output Option<Expression> exp;
  algorithm
    exp := match binding
      case TYPED_BINDING() then SOME(binding.bindingExp);
      case FLAT_BINDING() then SOME(binding.bindingExp);
      else NONE();
    end match;
  end typedExp;

  function getUntypedExp
    input Binding binding;
    output Expression exp;
  algorithm
    UNTYPED_BINDING(bindingExp = exp) := binding;
  end getUntypedExp;

  function getTypedExp
    input Binding binding;
    output Expression exp;
  algorithm
    exp := match binding
      case TYPED_BINDING() then binding.bindingExp;
      case FLAT_BINDING() then binding.bindingExp;
    end match;
  end getTypedExp;

  function setTypedExp
    input Expression exp;
    input output Binding binding;
  protected
    Type ty1, ty2;
  algorithm
    () := match binding
      case TYPED_BINDING()
        algorithm
          binding.bindingExp := exp;
        then
          ();

      case FLAT_BINDING()
        algorithm
          binding.bindingExp := exp;
        then
          ();
    end match;
  end setTypedExp;

  function hasExp
    input Binding binding;
    output Boolean hasExp;
  algorithm
    hasExp := match binding
      case UNTYPED_BINDING() then true;
      case TYPED_BINDING() then true;
      case FLAT_BINDING() then true;
      else false;
    end match;
  end hasExp;

  function getExp
    input Binding binding;
    output Expression exp;
  algorithm
    exp := match binding
      case UNTYPED_BINDING() then binding.bindingExp;
      case TYPED_BINDING() then binding.bindingExp;
      case FLAT_BINDING() then binding.bindingExp;
    end match;
  end getExp;

  function getExpOpt
    input Binding binding;
    output Option<Expression> exp;
  algorithm
    exp := match binding
      case UNTYPED_BINDING() then SOME(binding.bindingExp);
      case TYPED_BINDING() then SOME(binding.bindingExp);
      case FLAT_BINDING() then SOME(binding.bindingExp);
      else NONE();
    end match;
  end getExpOpt;

  function setExp
    input Expression exp;
    input output Binding binding;
  algorithm
    () := match binding
      case UNTYPED_BINDING()
        algorithm
          binding.bindingExp := exp;
        then
          ();

      case TYPED_BINDING()
        algorithm
          binding.bindingExp := exp;
        then
          ();

      case FLAT_BINDING()
        algorithm
          binding.bindingExp := exp;
        then
          ();

    end match;
  end setExp;

  function isRecordExp
    input Binding binding;
    output Boolean isRecordExp;
  algorithm
    isRecordExp := match binding
      case TYPED_BINDING() then Expression.isRecord(binding.bindingExp);
      else false;
    end match;
  end isRecordExp;

  function isCrefExp
    input Binding binding;
    output Boolean isCref;
  algorithm
    isCref := match binding
      case TYPED_BINDING() then Expression.isCref(binding.bindingExp);
      else false;
    end match;
  end isCrefExp;

  function recordFieldBinding
    input InstNode fieldNode;
    input Binding recordBinding;
    output Binding fieldBinding = recordBinding;
  protected
    Expression exp;
    Type ty;
    Variability var;
    String field_name = InstNode.name(fieldNode);
  algorithm
    fieldBinding := match fieldBinding
      case UNTYPED_BINDING()
        algorithm
          fieldBinding.bindingExp := Expression.recordElement(field_name, fieldBinding.bindingExp);
        then
          fieldBinding;

      case TYPED_BINDING()
        algorithm
          exp := Expression.recordElement(field_name, fieldBinding.bindingExp);
          ty := Expression.typeOf(exp);
          var := Expression.variability(exp);
        then
          TYPED_BINDING(exp, ty, var, fieldBinding.eachType, fieldBinding.evalState,
                        fieldBinding.isFlattened, fieldBinding.source, fieldBinding.info);

      case FLAT_BINDING()
        algorithm
          exp := Expression.recordElement(field_name, fieldBinding.bindingExp);
          var := Expression.variability(exp);
        then
          FLAT_BINDING(exp, var, fieldBinding.source);

      case CEVAL_BINDING()
        algorithm
          fieldBinding.bindingExp := Expression.recordElement(field_name, fieldBinding.bindingExp);
        then
          fieldBinding;

    end match;
  end recordFieldBinding;

  function variability
    input Binding binding;
    output Variability var;
  algorithm
    var := match binding
      case TYPED_BINDING() then binding.variability;
      case FLAT_BINDING() then binding.variability;
      else
        algorithm
          Error.assertion(false, getInstanceName() + " got unknown binding", sourceInfo());
        then
          fail();
    end match;
  end variability;

  function getInfo
    input Binding binding;
    output SourceInfo info;
  algorithm
    info := match binding
      case RAW_BINDING() then binding.info;
      case UNTYPED_BINDING() then binding.info;
      case TYPED_BINDING() then binding.info;
      else AbsynUtil.dummyInfo;
    end match;
  end getInfo;

  function getType
    input Binding binding;
    output Type ty;
  algorithm
    ty := match binding
      case UNBOUND() then Type.UNKNOWN();
      case RAW_BINDING() then Type.UNKNOWN();
      case UNTYPED_BINDING() then Type.UNKNOWN();
      case TYPED_BINDING() then binding.bindingType;
      case FLAT_BINDING() then Expression.typeOf(binding.bindingExp);
      case CEVAL_BINDING() then Expression.typeOf(binding.bindingExp);
      case INVALID_BINDING() then getType(binding.binding);
    end match;
  end getType;

  function isEach
    input Binding binding;
    output Boolean isEach;
  algorithm
    isEach := match binding
      case RAW_BINDING() then binding.eachType == EachType.EACH;
      case UNTYPED_BINDING() then binding.eachType == EachType.EACH;
      case TYPED_BINDING() then binding.eachType == EachType.EACH;
      else false;
    end match;
  end isEach;

  function isTyped
    input Binding binding;
    output Boolean isTyped;
  algorithm
    isTyped := match binding
      case TYPED_BINDING() then true;
      case FLAT_BINDING() then true;
      else false;
    end match;
  end isTyped;

  function toString
    input Binding binding;
    input String prefix = "";
    output String string;
  algorithm
    string := match binding
      case UNBOUND() then "";
      case RAW_BINDING() then prefix + Dump.printExpStr(binding.bindingExp);
      case UNTYPED_BINDING() then prefix + Expression.toString(binding.bindingExp);
      case TYPED_BINDING() then prefix + Expression.toString(binding.bindingExp);
      case FLAT_BINDING() then prefix + Expression.toString(binding.bindingExp);
      case CEVAL_BINDING() then prefix + Expression.toString(binding.bindingExp);
      case INVALID_BINDING() then toString(binding.binding, prefix);
    end match;
  end toString;

  function toFlatString
    input Binding binding;
    input String prefix = "";
    output String string;
  algorithm
    string := match binding
      case UNBOUND() then "";
      case RAW_BINDING() then prefix + Dump.printExpStr(binding.bindingExp);
      case UNTYPED_BINDING() then prefix + Expression.toFlatString(binding.bindingExp);
      case TYPED_BINDING() then prefix + Expression.toFlatString(binding.bindingExp);
      case FLAT_BINDING() then prefix + Expression.toFlatString(binding.bindingExp);
      case CEVAL_BINDING() then prefix + Expression.toFlatString(binding.bindingExp);
      case INVALID_BINDING() then toFlatString(binding.binding, prefix);
    end match;
  end toFlatString;

  function toDebugString
    input Binding binding;
    output String string;
  algorithm
    string := match binding
      case UNBOUND() then "UNBOUND";
      case RAW_BINDING() then "RAW_BINDING";
      case UNTYPED_BINDING() then "UNTYPED_BINDING";
      case TYPED_BINDING() then "TYPED_BINDING";
      case FLAT_BINDING() then "FLAT_BINDING";
      case CEVAL_BINDING() then "CEVAL_BINDING";
      case INVALID_BINDING() then "INVALID_BINDING";
    end match;
  end toDebugString;

  function isEqual
    input Binding binding1;
    input Binding binding2;
    output Boolean equal;
  algorithm
    equal := match (binding1, binding2)
      case (UNBOUND(), UNBOUND()) then true;

      // TODO: Handle propagated dims.
      case (RAW_BINDING(), RAW_BINDING())
        then AbsynUtil.expEqual(binding1.bindingExp, binding2.bindingExp);

      case (UNTYPED_BINDING(), UNTYPED_BINDING())
        then Expression.isEqual(binding1.bindingExp, binding2.bindingExp);

      case (TYPED_BINDING(), TYPED_BINDING())
        then Expression.isEqual(binding1.bindingExp, binding2.bindingExp);

      else false;
    end match;
  end isEqual;

  function toDAE
    input Binding binding;
    output DAE.Binding outBinding;
  algorithm
    outBinding := match binding
      case UNBOUND() then DAE.UNBOUND();
      case TYPED_BINDING() then makeDAEBinding(binding.bindingExp, binding.variability);
      case FLAT_BINDING() then makeDAEBinding(binding.bindingExp, binding.variability);
      case CEVAL_BINDING() then DAE.UNBOUND();
      case INVALID_BINDING()
        algorithm
          Error.addTotalMessages(binding.errors);
        then
          fail();
      else
        algorithm
          Error.assertion(false, getInstanceName() + " got untyped binding", sourceInfo());
        then
          fail();
    end match;
  end toDAE;

  function makeDAEBinding
    input Expression exp;
    input Variability var;
    output DAE.Binding binding;
  algorithm
    binding := DAE.EQBOUND(
      Expression.toDAE(exp),
      NONE(),
      Variability.variabilityToDAEConst(var),
      DAE.BINDING_FROM_DEFAULT_VALUE() // TODO: revise this.
    );
  end makeDAEBinding;

  function toDAEExp
    input Binding binding;
    output Option<DAE.Exp> bindingExp;
  algorithm
    bindingExp := match binding
      case UNBOUND() then NONE();
      case TYPED_BINDING() then SOME(Expression.toDAE(binding.bindingExp));
      case FLAT_BINDING() then SOME(Expression.toDAE(binding.bindingExp));
      case CEVAL_BINDING() then NONE();
      else
        algorithm
          Error.assertion(false, getInstanceName() + " got untyped binding", sourceInfo());
        then
          fail();
    end match;
  end toDAEExp;

  function mapExp
    input output Binding binding;
    input MapFunc mapFn;

    partial function MapFunc
      input output Expression exp;
    end MapFunc;
  protected
    Expression e1, e2;
  algorithm
    () := match binding
      case UNTYPED_BINDING(bindingExp = e1)
        algorithm
          e2 := Expression.map(e1, mapFn);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      case TYPED_BINDING(bindingExp = e1)
        algorithm
          e2 := Expression.map(e1, mapFn);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      case FLAT_BINDING(bindingExp = e1)
        algorithm
          e2 := Expression.map(e1, mapFn);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      case CEVAL_BINDING(bindingExp = e1)
        algorithm
          e2 := Expression.map(e1, mapFn);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      else ();
    end match;
  end mapExp;

  function mapExpShallow
    input output Binding binding;
    input MapFunc mapFn;

    partial function MapFunc
      input output Expression exp;
    end MapFunc;
  protected
    Expression e1, e2;
  algorithm
    () := match binding
      case UNTYPED_BINDING(bindingExp = e1)
        algorithm
          e2 := mapFn(e1);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      case TYPED_BINDING(bindingExp = e1)
        algorithm
          e2 := mapFn(e1);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      case FLAT_BINDING(bindingExp = e1)
        algorithm
          e2 := mapFn(e1);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      case CEVAL_BINDING(bindingExp = e1)
        algorithm
          e2 := mapFn(e1);

          if not referenceEq(e1, e2) then
            binding.bindingExp := e2;
          end if;
        then
          ();

      else ();
    end match;
  end mapExpShallow;

  function foldExp<ArgT>
    input Binding binding;
    input FoldFunc foldFn;
    input output ArgT arg;

    partial function FoldFunc
      input Expression exp;
      input output ArgT arg;
    end FoldFunc;
  algorithm
    arg := match binding
      case UNTYPED_BINDING() then Expression.fold(binding.bindingExp, foldFn, arg);
      case TYPED_BINDING()   then Expression.fold(binding.bindingExp, foldFn, arg);
      case FLAT_BINDING()    then Expression.fold(binding.bindingExp, foldFn, arg);
      case CEVAL_BINDING()   then Expression.fold(binding.bindingExp, foldFn, arg);
      else arg;
    end match;
  end foldExp;

  function containsExp
    input Binding binding;
    input PredFunc predFn;
    output Boolean res;

    partial function PredFunc
      input Expression exp;
      output Boolean res;
    end PredFunc;
  algorithm
    res := match binding
      case UNTYPED_BINDING() then Expression.contains(binding.bindingExp, predFn);
      case TYPED_BINDING()   then Expression.contains(binding.bindingExp, predFn);
      case FLAT_BINDING()    then Expression.contains(binding.bindingExp, predFn);
      case CEVAL_BINDING()   then Expression.contains(binding.bindingExp, predFn);
      else false;
    end match;
  end containsExp;

  function update
    input output Binding binding;
    input Expression exp;
  algorithm
    binding := match binding

      case UNBOUND()
      then TYPED_BINDING(
          bindingExp  = exp,
          bindingType = Expression.typeOf(exp),
          variability = Expression.variability(exp),
          eachType    = EachType.NOT_EACH,
          evalState   = if Expression.isConstNumber(exp)
                        then Mutable.create(EvalState.EVALUATED)
                        else Mutable.create(EvalState.NOT_EVALUATED),
          isFlattened = true,
          source      = Source.BINDING,
          info        = sourceInfo()
        );

      case UNTYPED_BINDING() algorithm
        binding.bindingExp := exp;
      then binding;

      case TYPED_BINDING() algorithm
        binding.bindingExp := exp;
      then binding;

      case FLAT_BINDING() algorithm
        binding.bindingExp := exp;
      then binding;

      case CEVAL_BINDING() algorithm
        binding.bindingExp := exp;
      then binding;

      case INVALID_BINDING() algorithm
        binding.binding := update(binding.binding, exp);
      then binding;

      case RAW_BINDING() algorithm
        Error.addMessage(Error.INTERNAL_ERROR,{getInstanceName() + " failed because a raw binding cannot be updated."});
      then fail();

      else algorithm
        Error.addMessage(Error.INTERNAL_ERROR,{getInstanceName() + " failed."});
      then fail();

    end match;
  end update;

  function setAttr
    "sets a specific attribute value and adds it if it does not exist"
    input output list<tuple<String, Binding>> ty_attr;
    input String attr_name;
    input Binding attr_value;
  algorithm
    ty_attr := match ty_attr
      local
        tuple<String, Binding> at;
        list<tuple<String, Binding>> rest;
        String name;
      case (name, _ ) :: rest guard(name == attr_name)  then (attr_name, attr_value) :: rest;
      case at :: rest                                   then at :: setAttr(rest, attr_name, attr_value);
      case {}                                           then {(attr_name, attr_value)};
    end match;
  end setAttr;

  function propagate
    "Propagates a modifier through an element, given as a list of split subscript."
    input output Binding binding;
    input list<Subscript> subs;
  algorithm
    () := match binding
      case RAW_BINDING()
        algorithm
          binding.subs := listAppend(binding.subs, subs);
          binding.source := Source.MODIFIER;
        then
          ();

      else ();
    end match;
  end propagate;

  function source
    input Binding binding;
    output Source source;
  algorithm
    source := match binding
      case RAW_BINDING() then binding.source;
      case UNTYPED_BINDING() then binding.source;
      case TYPED_BINDING() then binding.source;
      case FLAT_BINDING() then binding.source;
      else Source.BINDING;
    end match;
  end source;

  function makeTyped
    input Expression exp;
    input EachType eachType;
    input Source source;
    input SourceInfo info;
    input EvalState state = EvalState.NOT_EVALUATED;
    output Binding binding;
  algorithm
    binding := TYPED_BINDING(exp, Expression.typeOf(exp),
      Expression.variability(exp), eachType, Mutable.create(state), false, source, info);
  end makeTyped;

  function makeFlat
    input Expression exp;
    input Variability var;
    input Source source;
    output Binding binding;
  algorithm
    binding := FLAT_BINDING(exp, var, source);
  end makeFlat;

  function isEvaluated
    input Binding binding;
    output Boolean evaluated;
  algorithm
    evaluated := match binding
      case TYPED_BINDING()
        then Mutable.access(binding.evalState) == EvalState.EVALUATED;
      case CEVAL_BINDING() then true;
      else false;
    end match;
  end isEvaluated;

annotation(__OpenModelica_Interface="frontend");
end NFBinding;
