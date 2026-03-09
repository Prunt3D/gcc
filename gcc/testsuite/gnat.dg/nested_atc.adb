--  { dg-do run }

procedure Nested_ATC is
   task A is
      entry A;
   end A;

   protected B is
      entry B;
   end B;

   task body A is
   begin
      delay 3.0;
      accept A;
   end A;

   protected body B is
      entry B when False is
      begin
         raise Constraint_Error;
      end B;
   end B;
begin
   select
      A.A;
   then abort
      select
         B.B;
      then abort
         B.B;
      end select;
      raise Constraint_Error;
   end select;
end Nested_ATC;
