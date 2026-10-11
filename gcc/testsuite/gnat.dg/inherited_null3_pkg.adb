package body Inherited_Null3_Pkg is
   protected body Instance is
      function Valid return Boolean is
      begin
         Checks := Checks + 1;
         return Expected;
      end Valid;
   end Instance;
end Inherited_Null3_Pkg;
