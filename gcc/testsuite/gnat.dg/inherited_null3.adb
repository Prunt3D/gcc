-- { dg-do run }
-- { dg-options "-gnat2022 -gnata" }

--  A static dispatch table must still invoke the inherited null procedure's
--  contract, with the correct interface view of the object.

with Ada.Assertions;
with Inherited_Null3_Pkg; use Inherited_Null3_Pkg;

procedure Inherited_Null3 is
   procedure Dispatch (Object : in out Parent'Class) is
   begin
      Finalize (Object);
   end Dispatch;

   Object : Instance;
begin
   Dispatch (Object);
   if Checks = 0 then
      raise Program_Error;
   end if;

   Expected := False;
   begin
      Dispatch (Object);
      raise Program_Error;
   exception
      when Ada.Assertions.Assertion_Error => null;
   end;
end Inherited_Null3;
