-- { dg-do run }
-- { dg-options "-gnat2022 -fdump-ipa-cgraph" }

--  Use the inherited null procedure directly in the interface dispatch table.
--  No zero-offset thunk should be generated for it.

procedure Inherited_Null1 is
   package Types is
      type Parent is synchronized interface;
      procedure Finalize (This : in out Parent) is null;

      protected type Instance is new Parent with
      end Instance;
   end Types;

   package body Types is
      protected body Instance is
      end Instance;
   end Types;

   procedure Dispatch (Object : in out Types.Parent'Class) is
   begin
      Types.Finalize (Object);
   end Dispatch;

   Object : Types.Instance;
begin
   Types.Finalize (Object);
   Dispatch (Object);
end Inherited_Null1;

-- { dg-final { scan-ipa-dump-not "fixed offset 0 virtual value 0 indirect_offset 0" "cgraph" } }
