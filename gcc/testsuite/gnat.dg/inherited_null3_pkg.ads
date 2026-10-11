package Inherited_Null3_Pkg is
   Checks   : Natural := 0;
   Expected : Boolean := True;

   type Other is synchronized interface;
   procedure Action (This : in out Other) is null;

   type Parent is synchronized interface;
   function Valid (This : Parent) return Boolean is abstract;
   procedure Finalize (This : in out Parent) is null
     with Post'Class => Valid (Parent'Class (This));

   protected type Instance is new Other and Parent with
      overriding function Valid return Boolean;
   end Instance;
end Inherited_Null3_Pkg;
